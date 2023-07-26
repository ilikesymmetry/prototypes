// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Extension} from "../Extension.sol";

library MetadataRouterStorage {
    bytes32 public constant STORAGE_POSITION = keccak256("extensions.metadataRouter.storage");

    struct Data {
        address metadataRouter;
    }

    function read() internal pure returns (Data storage data) {
        bytes32 position = STORAGE_POSITION;
        assembly {
            data.slot := position
        }
    }
}

interface IMetadataRouter {
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

contract MetadataRouterExtension is Extension {
    /*===============
        EXTENSION
    ===============*/

    function getAllSelectors() public pure override returns (bytes4[] memory selectors) {
        selectors = new bytes4[](1);
        selectors[0] = this.tokenURI.selector;
        return selectors;
    }

    function signatureOf(bytes4 selector) public pure override returns (string memory) {
        if (selector == this.tokenURI.selector) {
            return "tokenURI(uint256)";
        } else {
            return "";
        }
    }

    function contractURI() external pure override returns (string memory uri) {
        return "";
    }

    /*===============
        FUNCTIONS
    ===============*/

    function tokenURI(uint256 tokenId) external view returns (string memory) {
        return IMetadataRouter(_getMetadataRouter()).tokenURI(tokenId);
    }

    /*===============
        INTERNALS
    ===============*/

    function _getMetadataRouter() internal view returns (address) {
        MetadataRouterStorage.Data storage data = MetadataRouterStorage.read();
        return data.metadataRouter;
    }
}
