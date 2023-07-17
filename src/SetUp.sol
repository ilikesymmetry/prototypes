// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

abstract contract SetUp {
    error SetUpFailed(address account, bytes data);

    function _setUp(address account, bytes calldata data) internal {
        (bool success, bytes memory res) = account.call(data);
        if (!success) revert SetUpFailed(account, res);
    }
}
