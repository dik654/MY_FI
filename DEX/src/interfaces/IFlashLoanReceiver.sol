// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IFlashLoanReceiver {
  function executeOperation(
    address asset,
    uint256 amount,
    uint256 premium,
    address to,
    address initiator,
    bytes calldata params
  ) external returns (bool);
}