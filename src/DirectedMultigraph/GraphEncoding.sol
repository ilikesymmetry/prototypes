// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

library GraphEncoding {
    function decodeNode(uint256 tokenId) public pure returns (uint96 graphId, address node) {
        graphId = uint96(tokenId >> 160);
        node = address(uint160(tokenId));
    }

    function encodeNode(uint96 graphId, address node) public pure returns (uint256 tokenId) {
        tokenId = (uint256(graphId) << 160) | uint256(uint160(node));
    }

    function encodeNodes(uint96[] memory graphIds, address[] memory distributors)
        public
        pure
        returns (uint256[] memory ids)
    {
        uint256 len = graphIds.length;
        require(len == distributors.length);
        ids = new uint256[](len);
        for (uint256 i; i < len; i++) {
            ids[i] = encodeNode(graphIds[i], distributors[i]);
        }
    }
}
