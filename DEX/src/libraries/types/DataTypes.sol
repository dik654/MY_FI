// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

library DataTypes {
  struct PriceFeedData {
    address priceFeed;
    address addressResolver;
    address weth;
    address dai;
  }
}