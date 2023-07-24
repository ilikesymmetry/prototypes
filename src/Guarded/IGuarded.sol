// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IGuarded {
    event Guarded(bytes32 indexed operation, address indexed guard);

    error GuardRejected(bytes32 operation, address operator, address guard, bytes data);

    function guardOperation(bytes32 operation, address newGuard) external;
    function guardOperationAndSetUp(bytes32 operation, address newGuard, bytes calldata data) external;
    function checkGuardBefore(bytes32 operation, bytes calldata data) external view returns (address guard);
    function checkGuardAfter(bytes32 operation, bytes calldata data) external view returns (address guard);
}
