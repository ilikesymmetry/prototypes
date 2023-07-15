// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

/// @notice Opinionated extension of ERC1155 for modeling graph problems via [directed multigraphs](https://en.wikipedia.org/wiki/Multigraph).
///         Potentially useful for endorsement graphs like Coordinape or other complex multiplayer games.
interface IDirectedMultigraph {
    // metadata

    // returns uri of graph metadata
    function graphURI(uint96 graphId) external returns (string memory);

    // returns uri of edge metadata on a graph
    function edgeURI(uint96 graphId, address distributor, address owner) external returns (string memory);

    // returns uri of node metadata on a graph
    // equivalent with ERC1155.uri(id)
    function nodeURI(uint96 graphId, address node) external returns (string memory);

    // convenience parity functions

    // returns edge amount
    // equivalent with ERC1155.balanceOf(tokenId, owner)
    function balanceOf(uint96 graphId, address distributor, address owner) external returns (uint256 amount);

    // returns edge values in batch
    // equivalent with ERC1155.balanceOfBatch(owners, ids)
    function balanceOfBatch(uint96[] memory graphIds, address[] memory distributors, address[] memory owners)
        external
        returns (uint256[] memory amounts);

    // transfers are not controlled by "owner", but by "distributor" in graphs
    // equivalent with ERC1155.safeTransferFrom(tokenId, from, to, amount, data)
    function safeTransferFrom(
        uint96 graphId,
        address distributor,
        address from,
        address to,
        uint256 amount,
        bytes memory data
    ) external;

    // transfers are not controlled by "owner", but by "distributor" in graphs
    // equivalent with ERC1155.safeTransferFromBatch(from, to, ids, amounts, data)
    function safeBatchTransferFrom(
        uint96[] memory graphIds,
        address[] memory distributors,
        address from,
        address to,
        uint256[] memory amounts,
        bytes memory data
    ) external;
}
