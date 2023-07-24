// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IGuard} from "../IGuard.sol";

/// @notice Example Guard for setting valid time ranges for given operations
contract TimeRangeGuard is IGuard {
    event SetUp(address indexed primitive, uint48 indexed start, uint48 indexed end);

    struct TimeRange {
        uint48 start;
        uint48 end;
    }

    mapping(address => TimeRange) internal _validTimeRange;

    function setUp(uint48 start, uint48 end) external {
        _validTimeRange[msg.sender] = TimeRange(start, end);
        emit SetUp(msg.sender, start, end);
    }

    function getValidTimeRange(address primitive) public view returns (uint48 start, uint48 end) {
        TimeRange memory range = _validTimeRange[primitive];
        require(start != 0 && end != 0, "RANGE_UNDEFINED");
        return (range.start, range.end);
    }

    function checkBefore(address, bytes calldata) external view returns (bool) {
        _checkTimeRange();
        return true;
    }

    function checkAfter(address, bytes calldata) external view returns (bool) {
        _checkTimeRange();
        return true;
    }

    function _checkTimeRange() internal view {
        (uint48 start, uint48 end) = getValidTimeRange(msg.sender);
        require(block.timestamp > start, "NOT_STARTED");
        require(block.timestamp < end, "HAS_ENDED");
    }
}
