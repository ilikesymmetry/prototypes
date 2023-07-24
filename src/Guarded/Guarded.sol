// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IGuarded} from "./IGuarded.sol";
import {IGuard} from "./IGuard.sol";
import {SetUp} from "src/SetUp.sol";

abstract contract Guarded is IGuarded, SetUp {
    // default value for a guard that always rejects
    address constant MAX_ADDRESS = 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF;

    mapping(bytes32 => address) internal _guards;

    function _guardOperation(bytes32 operation, address newGuard) internal {
        _guards[operation] = newGuard;
        emit Guarded(operation, newGuard);
    }

    function guardOf(bytes32 operation) public view returns (address guard) {
        return _guards[operation];
    }

    function guardOperation(bytes32 operation, address newGuard) public virtual {
        _guardOperation(operation, newGuard);
    }

    function guardOperationAndSetUp(bytes32 operation, address newGuard, bytes calldata data) public virtual {
        _guardOperation(operation, newGuard);
        _setUp(newGuard, data);
    }

    modifier checkGuardBeforeAndAfter(bytes32 operation, bytes calldata data) {
        address guard = checkGuardBefore(operation, data);

        _;

        _checkGuardAfter(guard, operation, data);
    }

    function checkGuardBefore(bytes32 operation, bytes calldata data) public view returns (address guard) {
        guard = guardOf(operation);
        if (guard == MAX_ADDRESS || (guard != address(0) && !IGuard(guard).checkBefore(msg.sender, data))) {
            revert GuardRejected(operation, msg.sender, guard, data);
        }
    }

    function checkGuardAfter(bytes32 operation, bytes calldata data) public view returns (address guard) {
        guard = guardOf(operation);
        _checkGuardAfter(guard, operation, data);
    }

    function _checkGuardAfter(address guard, bytes32 operation, bytes calldata data) internal view {
        if (guard == MAX_ADDRESS || (guard != address(0) && !IGuard(guard).checkAfter(msg.sender, data))) {
            revert GuardRejected(operation, msg.sender, guard, data);
        }
    }
}
