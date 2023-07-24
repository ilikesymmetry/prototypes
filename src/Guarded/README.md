# Guard

Generalized guard layer for modularizing checks on operations. 

Inspired by Safe's Guard design.

## Design decisions

### 1. Guard per operation

A core contract may have multiple essential operations that define the behavior of the system. Operations may differentiate via context of a call (e.g. Mint/Transfer/Burn) or unique shape of data that defines it. The set of operations is unbounded across primtives so a `mapping(bytes32 => address)` was chosen so that each operation can have its own guarding mechanism.

A design of multiple guards per operation was entertained, but causes implementation possiblities to diverge meaningfully without strong intuition on what an optimized or generic design should include. For example, if an array of addresses are stored instead of a singular guard, should they be chained with `AND` or `OR` binary logic? How would one compose a combination of the two? With a singular guard, we maintain the ability to model these complex behavior while not sacrificing on simplicity that matches the majority of use cases.

### 2. Before and after hooks

Before hooks are preferable for making checks that can shut down execution before any state changes are made, maximizing the possible gas refund for the caller.

After hooks are practically easier to write with confident security because they let you analyze the pending final state. Before hooks sometimes are forced to predict the state change they are guarding which may be possible, but not ideal for having strong guarantees of implementing desired behavior.

Therefore, both options are provided to developers to customize which style they prefer or use both simultaneously.

### 3. Generalized bytes data interface

Different operations may have different schema shapes to define an operation. To provide a consistent pattern and interface, a reduction of schema divergence is required and using a simple `abi.encode(...args)` into a single `bytes` value is simple while maximally flexible. Guards and their callers must take additional effort to confirm they align on the proper encoding/decoding schema however.

### 4. Additional setup on guards `(optional)`

Guards may or may not be stateful. For guards that are stateful, a single `external setUp(...args)` function is encouraged for readability and consistency. When guarding an operation, users can atomically set up the Guard's state in one transaction through `guardOperationAndSetUp(bytes32 operation, address guard, data setUpData)`.
