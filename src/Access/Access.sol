// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {AccessControl} from "lib/openzeppelin-contracts/contracts/access/AccessControl.sol";
import {Ownable2Step} from "lib/openzeppelin-contracts/contracts/access/Ownable2Step.sol";
import {SetUp} from "src/SetUp.sol";

abstract contract Access is Ownable2Step, AccessControl, SetUp {
    bytes32 public constant ADMIN_ROLE = keccak256(abi.encodePacked("ADMIN"));

    function hasRole(bytes32 role, address account) public view override returns (bool) {
        // has role, has admin role, or is owner
        return super.hasRole(role, account) || super.hasRole(getRoleAdmin(role), account) || account == owner();
    }

    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        bytes32 adminRole = super.getRoleAdmin(role);
        return adminRole == bytes32(0x0) ? ADMIN_ROLE : adminRole;
    }

    function grantRoleAndSetUp(bytes32 role, address account, bytes calldata data) external {
        grantRole(role, account);
        _setUp(account, data);
    }

    function hashRole(string memory role) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(role));
    }
}
