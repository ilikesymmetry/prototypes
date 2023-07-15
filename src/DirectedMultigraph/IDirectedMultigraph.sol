// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// A wrapper around ERC1155 to model [directed multigraphs](https://en.wikipedia.org/wiki/Multigraph)
interface IDirectedMultigraph {
    // returns uri of graph metadata
    function graphURI(uint96 graphId) external returns (string memory);

    // returns uri of edge metadata on a graph
    function edgeURI(uint96 graphId, address distributor, address owner) external returns (string memory);

    // returns uri of node metadata on a graph
    // equivalent with tokenURI()
    function nodeURI(uint96 graphId, address node) external returns (string memory);

    // returns edge value
    // equivalent with balanceOf(tokenId, owner)
    function balanceOf(uint96 graphId, address distributor, address owner) external returns (uint256 value);

    // safeTransferFrom is not controlled by "owner"/to-node, but from-node
    // equivalent with safeTransferFrom(tokenId, from, to)
    function safeTransferFrom(uint96 graphId, address distributor, address from, address to, uint256 value)
        external
        returns (bool);

    // library, tokenId = graphId + node
    function decodeNode(uint256 tokenId) external returns (uint96 graphId, address node);
    function encodeNode(uint96 graphId, address node) external returns (uint256 tokenId);
}
