# Access

Opinionated access layer for extensible role systems and multi-tiered management.

Inherits [AccessControl](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/AccessControl.sol) and [Ownable2Step](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable2Step.sol).

## Design decisions

### 1. 3-tier role system: Roles, Admins, Owner

For someone to have access to an operation, they must either hold the role corresponding to that operation, be an admin of the role, or be an owner of the contract. While admins are included in the native `AccessControl`, this implementation grants admins their controlled roles automatically. This simplifies patterns of giving administrative access to someone once that enables them to do many things. Because admins are allowed to edit each other, a singular owner is still used for the top-most control over a contract. The same convenience of auto-granting all controlled roles to admins is also extended to the owner.

### 2. 2-step owner transfers

While optional, a 2-step process for `owner` transfer is enabled and recommended given the high-severity if accidentally transferred to an incorrect address. First the current owner must publish the next owner and then this pending owner must accept the transfer to complete the process.

### 3. Additional setup on granted accounts `(optional)`

When granting roles to other smart contracts, it can be useful to also call them to initialize some parameters needed for proper operation. There is an additional `grantRoleAndSetUp(bytes32 role, address account, bytes calldata data)` function for this added convenience for granting with atomicity guarantees on an account's setup.
