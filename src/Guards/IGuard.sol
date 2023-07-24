// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IGuard {
    function checkBefore(address operator, bytes calldata data) external view returns (bool);
    function checkAfter(address operator, bytes calldata data) external view returns (bool);
}
