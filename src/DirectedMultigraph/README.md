# Directed Multigraph

Opinionated extension of ERC1155 for modeling graph problems via [directed multigraphs](https://en.wikipedia.org/wiki/Multigraph).

Potentially useful for endorsement graphs like Coordinape or other complex multiplayer games.

Map to ERC1155 interface by organizing the layout of `tokenId` in a specific manner. First, we introduce a "distributor" address as the origin of an edge in our graph into the `tokenId`. With 96 bits leftover in `tokenId`, include a `uint96 graphId` to superimpose multiple graphs per distributor-owner pair, hence "multigraph". Together, a `tokenId` is the combination of a `distributor` (`address`) and a `graphId` (`uint96`). All combined, a directed multigraph of ERC1155 re-conceptualizes ownership from `balanceOf(uint256 tokenId, address owner)` to `balanceOf(uint96 graphId, address distributor, address owner)` and replicates this pattern into the other standard functionality. Learn more about the translation between `graphId` + `distributor` and a traditional `tokenId` within the [GraphEncoding library](./GraphEncoding.sol).

## Example use

Your organization wants to create a peer-to-peer endorsement system and deploys a new `DirectedMultigraph`. Monthly, all members are granted allocation to distribute to other members where each month is given an incrementing `graphId` starting at `1`, `2`, and so on.

For this first month, `graphId` of `1`, you endorse Alice 10 points and Bob 5. The act of endorsing mints each of them your personal ERC1155 token for that month's round with a `tokenId` of `{graphId}{yourAddress}`. The metadata of the NFT, discovered through `tokenURI` or `nodeURI`, describes that it is an endorsement from you on `graphId` number `1`. There are more details and metadata to uncover about the underlying graph by calling `graphURI(graphId)` and the endorsements specific to Alice and Bob at `edgeURI(graphId, yourAddress, alice)` and `edgeURI(graphId, yourAddress, bob)` respectively. These new `*URI(...)` functions are added to accomodate adding metadata to the new models introduced in the Directed Multigraph pattern.

While OpenSea and other typical NFT dApps will likely only know to render the contents of `tokenURI`, which represents your endorsement on this first month, an increasing number of dApps will become aware of this standard and will also know to render the contents of `graphURI` and `edgeURI` to construct a full picture of these actions. By creating a standard interface for engaging in graph-like patterns, we can lean into the interoperability thesis of web3 and build highly inter-relational experiences across applications.

## Design decisions

### 1. Backwards compatibility with ERC1155

Standards for graphs do not seem to exist in EVM consciousness, which leaves an opportunity to create something fundamentally new. However, it is ideal to build on top of each other where possible and fundamentally, ERC1155 converges to nearly equivalent storage patterns for graph design and covers a subset of metadata needs, which is nearly begging us to simply extend it. By extending ERC1155, we give ourselves an opportunity to create product-led-growth for graph-like tokens where users can be delighted to see traces of reputation in their wallets immediately after adopting and can become curious by seeing the contents in others' wallets.

Hopefully the minor alterations and wrapping of ERC1155 comes intuitive to others and this can motivate followers and contributors on a path to an EIP.

### 2. No new events

New events were not added intentionally to not create ambiguity or asynchronization risk with the core ERC1155 `TransferSingle` and `TransferBatch` events. This places a larger burden on indexers to intuit and parse `tokenId` in these events into the `graphId` and `distributor` according to our specification. However, there is an additional benefit that all 4 core properties are `indexed` when normally only 3 `indexed` arguments are allowed at a time, enabled by virtue of compressing two items into `tokenId`.

### 3. Pending: Approval compliance

**A) Partially-violate ERC1155 by flipping approval direction** `(latest)`

- owners do not control their tokens, distributors do and distributors can approve other addresses to manage their distributions
- tradeoffs: risk breaking standard, creating unexpected dApp behavior, and annoying people
- pros: simple implementation re-use for our new context
- cons: not fully backwards compatible with existing ERC1155 systems, feels similar to SBTs breaking ERC721 transfer utility

**B) Work within ERC1155 and compromise intuition and implementations**

- to adhere to ERC1155, Approval(to, from, true) is emitted when minting an edge
- just because `from` has approval does not mean we MUST let them move tokens though, so we can restrict just for their controlled edges
- tradeoffs: add gas overhead, not able to let operators control directing for origins
- pros: fully backwards compatible with ERC1155
- cons: unintuitive design, gas overhead, limits potential of primitive
