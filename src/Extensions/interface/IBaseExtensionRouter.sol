// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IBaseExtensionRouter {
    struct Extension {
        bytes4 selector; // 32 bits
        address implementation; // 160 bits
        uint24 index; // 24 bits
        uint40 updatedAt; // 40 bits
    }

    struct ExtensionWithSignature {
        bytes4 selector;
        address implementation;
        string signature;
    }

    event Extend(bytes4 indexed selector, address indexed oldExtension, address indexed newExtension);

    error UnauthorizedToExtend(address operator);
    error SelectorNotExtended(bytes4 selector);
    error SelectorAlreadyExtended(bytes4 selector);
    error InvalidContract(address implementation);
    error ExtensionUnchanged(address oldImplementation, address newImplementation);
    error ExtensionUpdatedAfter(bytes4 selector, uint40 updatedAt, uint40 updateThreshold);

    function extensionOf(bytes4 selector) external view returns (address implementation);
    function extensionOf(bytes4 selector, uint40 updatedBefore) external view returns (address implementation);
    function getAllExtensions() external view returns (ExtensionWithSignature[] memory extensions);
    function addExtension(bytes4 selector, address implementation) external;
    function removeExtension(bytes4 selector) external;
    function updateExtension(bytes4 selector, address implementation) external;
}
