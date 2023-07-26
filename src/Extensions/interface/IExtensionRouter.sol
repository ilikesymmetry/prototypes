// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IExtensionRouter {
    event ExtensionBeaconUpdated(address indexed oldBeacon, address indexed newBeacon, uint40 lastValidUpdatedAt);

    function updateExtensionBeacon(address newBeacon, uint40 lastValidUpdatedAt) external;
}
