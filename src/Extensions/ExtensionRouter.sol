// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {BaseExtensionRouter} from "./BaseExtensionRouter.sol";
import {IBaseExtensionRouter} from "./interface/IBaseExtensionRouter.sol";
import {IExtensionRouter} from "./interface/IExtensionRouter.sol";
import {IExtension} from "./interface/IExtension.sol";

abstract contract ExtensionRouter is BaseExtensionRouter, IExtensionRouter {
    struct ExtensionBeacon {
        address router;
        uint40 lastValidUpdatedAt;
    }

    ExtensionBeacon internal extensionBeacon;

    /*===========
        VIEWS
    ===========*/

    function extensionOf(bytes4 selector) public view override returns (address implementation) {
        implementation = super.extensionOf(selector);
        if (implementation != address(0)) return implementation;

        // no local implementation, fetch from beacon
        ExtensionBeacon memory beacon = extensionBeacon;
        if (beacon.router == address(0)) revert SelectorNotExtended(selector);
        implementation = IBaseExtensionRouter(beacon.router).extensionOf(selector, beacon.lastValidUpdatedAt);
        if (implementation == address(0)) revert SelectorNotExtended(selector);

        return implementation;
    }

    function getAllExtensions() public view override returns (ExtensionWithSignature[] memory extensions) {
        ExtensionWithSignature[] memory beaconExtensions =
            IBaseExtensionRouter(extensionBeacon.router).getAllExtensions();
        ExtensionWithSignature[] memory localExtensions = super.getAllExtensions();
        uint256 lenBeacon = beaconExtensions.length;
        uint256 lenLocal = localExtensions.length;

        // calculate number of overriden selectors
        uint256 numOverrides;
        for (uint256 i; i < lenBeacon; i++) {
            if (hasExtended(beaconExtensions[i].selector)) {
                numOverrides++;
            }
        }
        // create new extensions array with total length without overriden selectors
        uint256 lenTotal = lenLocal + lenBeacon - numOverrides;
        extensions = new ExtensionWithSignature[](lenTotal);
        // add non-overriden beacon extensions to return
        uint256 j;
        for (uint256 i; i < lenBeacon; i++) {
            if (!hasExtended(beaconExtensions[i].selector)) {
                extensions[j] = beaconExtensions[i];
                j++;
            }
        }
        // add local extensions to return
        for (uint256 i; i < lenLocal; i++) {
            extensions[j] = localExtensions[i];
            j++;
        }

        return extensions;
    }

    /*=============
        SETTERS
    =============*/

    function removeExtensionBeacon() public virtual canExtend {
        _updateExtensionBeacon(address(0), 0);
    }

    function refreshExtensionBeacon(uint40 lastValidUpdatedAt) public virtual canExtend {
        address oldBeacon = extensionBeacon.router;
        _updateExtensionBeacon(oldBeacon, lastValidUpdatedAt);
    }

    function setExtensionBeacon(address newBeacon, uint40 lastValidUpdatedAt) public virtual canExtend {
        require(newBeacon != address(0));
        require(lastValidUpdatedAt > 0);
        _updateExtensionBeacon(newBeacon, lastValidUpdatedAt);
    }

    /*===============
        INTERNALS
    ===============*/

    function _updateExtensionBeacon(address newBeacon, uint40 lastValidUpdatedAt) internal {
        address oldBeacon = extensionBeacon.router;
        extensionBeacon = ExtensionBeacon(newBeacon, lastValidUpdatedAt);
        emit ExtensionBeaconUpdated(oldBeacon, newBeacon, lastValidUpdatedAt);
    }
}
