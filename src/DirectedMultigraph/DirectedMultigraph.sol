// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC1155} from "lib/openzeppelin-contracts/contracts/token/ERC1155/ERC1155.sol";
import {IDirectedMultigraph} from "./IDirectedMultigraph.sol";
import {GraphEncoding} from "./GraphEncoding.sol";

/// @notice Opinionated extension of ERC1155 for modeling graph problems via [directed multigraphs](https://en.wikipedia.org/wiki/Multigraph).
///         Potentially useful for endorsement graphs like Coordinape or other complex multiplayer games.
contract DirectedMultigraph is ERC1155, IDirectedMultigraph {
    constructor(string memory uri_) ERC1155(uri_) {}

    // metadata

    function graphURI(uint96 graphId) external view virtual returns (string memory) {}

    function edgeURI(uint96 graphId, address distributor, address owner)
        external
        view
        virtual
        returns (string memory)
    {}

    function nodeURI(uint96 graphId, address node) external view returns (string memory) {
        return uri(GraphEncoding.encodeNode(graphId, node));
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IDirectedMultigraph).interfaceId || super.supportsInterface(interfaceId);
    }

    // flip approval operator to distributors, not owners

    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes memory data)
        public
        override
    {
        (, address distributor) = GraphEncoding.decodeNode(id);
        require(
            distributor == _msgSender() || isApprovedForAll(distributor, _msgSender()),
            "ERC1155: caller is not token distributor or approved" // changed "owner" -> "distributor"
        );
        _safeTransferFrom(from, to, id, amount, data);
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {
        uint256 len = ids.length;
        for (uint256 i; i < len; i++) {
            (, address distributor) = GraphEncoding.decodeNode(ids[i]);
            // not gas optimized, but clear and it works for POC
            require(
                distributor == _msgSender() || isApprovedForAll(distributor, _msgSender()),
                "ERC1155: caller is not token distributor or approved" // changed "owner" -> "distributor"
            );
        }
        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    // convenience parity functions

    function balanceOf(uint96 graphId, address distributor, address owner)
        public
        view
        virtual
        returns (uint256 amount)
    {
        return balanceOf(owner, GraphEncoding.encodeNode(graphId, distributor));
    }

    function balanceOfBatch(uint96[] memory graphIds, address[] memory distributors, address[] memory accounts)
        public
        view
        virtual
        returns (uint256[] memory amounts)
    {
        return balanceOfBatch(accounts, GraphEncoding.encodeNodes(graphIds, distributors));
    }

    function safeTransferFrom(
        uint96 graphId,
        address distributor,
        address from,
        address to,
        uint256 amount,
        bytes memory data
    ) public virtual {
        safeTransferFrom(from, to, GraphEncoding.encodeNode(graphId, distributor), amount, data);
    }

    function safeBatchTransferFrom(
        uint96[] memory graphIds,
        address[] memory distributors,
        address from,
        address to,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual {
        safeBatchTransferFrom(from, to, GraphEncoding.encodeNodes(graphIds, distributors), amounts, data);
    }

    function _mint(uint96 graphId, address distributor, address to, uint256 amount, bytes memory data)
        internal
        virtual
    {
        _mint(to, GraphEncoding.encodeNode(graphId, distributor), amount, data);
    }

    function _mintBatch(
        uint96[] memory graphIds,
        address[] memory distributors,
        address to,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        _mintBatch(to, GraphEncoding.encodeNodes(graphIds, distributors), amounts, data);
    }

    function _burn(uint96 graphId, address distributor, address from, uint256 amount) internal virtual {
        _burn(from, GraphEncoding.encodeNode(graphId, distributor), amount);
    }

    function _burnBatch(uint96[] memory graphIds, address[] memory distributors, address from, uint256[] memory amounts)
        internal
        virtual
    {
        _burnBatch(from, GraphEncoding.encodeNodes(graphIds, distributors), amounts);
    }
}
