# Extensions

Generalized extension layer for modularizing fallback behavior.

Inspired by Diamond Proxies/ERC-2535 and Thirdweb's [Dynamic Contracts Standard](https://github.com/thirdweb-dev/dynamic-contracts/tree/main)

## Design decisions

- minimal storage: signatures on extensions, no functionsOfExtension method
- optimized storage: pack index into struct
- beacon routing by default with timestamping selectors protection mechanism

### 1. Lean implementation

[ERC-2535 Diamonds](https://eips.ethereum.org/EIPS/eip-2535) are the source inspiration for Thirdweb's [Dynamic Contracts](https://github.com/thirdweb-dev/dynamic-contracts/tree/main) which was the main reference point for this prototype. While Thirdweb's implementation is an attempt at diamond's "leanest, simplest form", I believe there is still more unnecessary weight to shed.

The most fundamental idea of the diamond pattern is that a diamond will route inbound calls to different implementation contracts, facets, and determines the appropriate facet to use via a mapping of function selectors to addresses. Anything beyond the singular `mapping(bytes4 => address) facets` storage and functions to support reading and writing to it is non-essential.

Layers of functionality beyond this have the goal of enhancing the developer experience and this is where our prototype diverges from ERC-2535 and Thirdweb by being more minimal. Our implementation only cares about a view function to get all of the extended selectors and their implementations on the diamond. We do not care about storing names of extensions, metadata URIs, function signatures, or even enabled facets. We do this primarily to save a **lot** of gas by not storing data that is non-essential to execution.

We still don't sacrifice on developer convenience of accessing metadata, but we do re-allocate most of its responsibility to extension deployers. Every extension defines its own metadata once at deployment to be shared by all consumers of it.

### 2. Optimized storage

Stripping out most of the non-essential functionality provided in other standards removes a lot of storage. In addition to struct-packing our state, we optimize further by rewriting enumeration patterns.

To support our convenience function of returning all extended selectors, we need to introduce a means to enumerate all of the selectors and their mapped extensions on a diamond. Typical implementations inherit something like Open Zeppelin's [EnumerableSet](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/structs/EnumerableSet.sol), but this adds a noticeable overhead when adding, updating, and removing extensions. Drawing from the underlying patterns of making an enumerable set, we embed the same information requirements in our existing storage to save 30% on these operations.

### 3. Beacon routing with time-based versioning protection

The basics of extension management and call routing are handled by `BaseExtensionRouter` and is perfectly viable to import directly into your individual use cases. In cases where you want to build a platform that helps other people create contracts for their use case, the `ExtensionRouter` is recommended for its additional beacon pattern. Taking inspiration from beacon proxies, an extension beacon is a contract that many other contracts point to for extension implementation addresses. The pattern helps one team update extensions on one beacon that immediately apply to all contracts following it. Individual contracts first check their own local storage for an extension of a selector, but refer to a beacon for default implementations otherwise.

When designing a beacon, it's important to enable followers to protect themselves from mismanagement. When you follow a beacon, you also store a timestamp that you trust the state of the beacon up until. This means extension additions and updates on the beacon made after your timestamp will not be considered part of your implementation. This additional security feature is optional and you can increase your risk but reduce operational overhead by setting your timestamp to the maximum `uint40`, effectively pre-approving all future changes to the beacon for use in your contract.

## Examples

- [MetadataExtension](./examples/MetadataExtension.sol): Only allow operations within a defined time window.
