// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.19;

/**
 * @dev Interface of the ERC-20 standard as defined in the ERC.
 */
interface IDERC20 {
    function mint(address to, uint256 amount) external;
    function burn(address from, uint256 amount) external;
}