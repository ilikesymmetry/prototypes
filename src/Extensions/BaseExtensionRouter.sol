// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IBaseExtensionRouter} from "./interface/IBaseExtensionRouter.sol";
import {IExtension} from "./interface/IExtension.sol";
import {Address} from "lib/openzeppelin-contracts/contracts/utils/Address.sol";

abstract contract BaseExtensionRouter is IBaseExtensionRouter {
    Extension[] internal _extensions;
    mapping(bytes4 => Extension) internal _selectors;

    /*==================
        CALL ROUTING
    ==================*/

    fallback() external payable virtual {
        address implementation = extensionOf(msg.sig);
        _delegate(implementation);
    }

    receive() external payable virtual {}

    /// @dev delegateCalls an `implementation` smart contract.
    function _delegate(address implementation) internal virtual {
        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize())

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

            // Copy the returned data.
            returndatacopy(0, 0, returndatasize())

            switch result
            // delegatecall returns 0 on error.
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    /*===========
        VIEWS
    ===========*/

    function hasExtended(bytes4 selector) public view virtual returns (bool) {
        return _selectors[selector].implementation != address(0);
    }

    function extensionOf(bytes4 selector) public view virtual returns (address implementation) {
        return extensionOf(selector, 2 ** 40 - 1); // max uint40
    }

    function extensionOf(bytes4 selector, uint40 updatedAtThreshold)
        public
        view
        virtual
        returns (address implementation)
    {
        Extension memory extension = _selectors[selector];
        if (extension.implementation == address(0)) revert SelectorNotExtended(selector);
        if (extension.updatedAt > updatedAtThreshold) {
            revert ExtensionUpdatedAfter(selector, extension.updatedAt, updatedAtThreshold);
        }
        return extension.implementation;
    }

    function getAllExtensions() public view virtual returns (ExtensionWithSignature[] memory extensions) {
        uint256 len = _extensions.length;
        extensions = new ExtensionWithSignature[](len);
        for (uint256 i; i < len; i++) {
            Extension memory extension = _extensions[i + 1];
            extensions[i] = ExtensionWithSignature(
                extension.selector,
                extension.implementation,
                IExtension(extension.implementation).signatureOf(extension.selector)
            );
        }
        return extensions;
    }

    /*=============
        SETTERS
    =============*/

    modifier canExtend() {
        if (!_canExtend(msg.sender)) revert UnauthorizedToExtend(msg.sender);
        _;
    }

    function addExtension(bytes4 selector, address implementation) public canExtend {
        _addExtension(selector, implementation);
    }

    function removeExtension(bytes4 selector) public canExtend {
        _removeExtension(selector);
    }

    function updateExtension(bytes4 selector, address implementation) public canExtend {
        _updateExtension(selector, implementation);
    }

    /*===============
        INTERNALS
    ===============*/

    function _addExtension(bytes4 selector, address implementation) internal {
        if (!Address.isContract(implementation)) revert InvalidContract(implementation);
        Extension memory oldExtension = _selectors[selector];
        if (oldExtension.implementation != address(0)) revert SelectorAlreadyExtended(selector);

        Extension memory extension =
            Extension(selector, implementation, uint24(_extensions.length), uint40(block.timestamp)); // new length will be `len + 1`, so this extension has index `len`

        _selectors[selector] = extension;
        _extensions.push(extension); // set new extension at index and increment length

        emit Extend(selector, address(0), implementation);
    }

    function _removeExtension(bytes4 selector) internal {
        Extension memory oldExtension = _selectors[selector];
        if (oldExtension.implementation == address(0)) revert SelectorNotExtended(selector);

        uint256 lastIndex = _extensions.length - 1;
        // if removing extension not at the end of the array, swap extension with last in array
        if (oldExtension.index < lastIndex) {
            Extension memory lastExtension = _extensions[lastIndex];
            lastExtension.index = oldExtension.index;
            _selectors[lastExtension.selector] = lastExtension;
            _extensions[oldExtension.index] = lastExtension;
        }
        delete _selectors[selector];
        _extensions.pop(); // delete extension in last index and decrement length

        emit Extend(selector, oldExtension.implementation, address(0));
    }

    function _updateExtension(bytes4 selector, address implementation) internal {
        require(Address.isContract(implementation));
        Extension memory oldExtension = _selectors[selector];
        if (implementation == oldExtension.implementation) {
            revert ExtensionUnchanged(oldExtension.implementation, implementation);
        }

        Extension memory newExtension =
            Extension(selector, implementation, uint24(oldExtension.index), uint40(block.timestamp));
        _selectors[selector] = newExtension;
        _extensions[oldExtension.index] = newExtension; // directly update index to leave _extensions.length unchanged

        emit Extend(selector, oldExtension.implementation, implementation);
    }

    /*===================
        AUTHORIZATION
    ===================*/

    function _canExtend(address operator) internal virtual returns (bool) {}
}
