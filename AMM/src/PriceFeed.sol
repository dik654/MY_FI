// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IPriceFeed} from './interfaces/IPriceFeed.sol';

contract PriceFeed is IPriceFeed {
  uint256 public lastUpdate;
  mapping(address => uint256) internal prices;

  function getAssetPrice(address asset) external view override returns (uint256) {
    return prices[asset];
  }

  function setAssetPrice(address asset, uint256 price) external override {
    prices[asset] = price;
    lastUpdate = block.timestamp;
    emit AssetPriceUpdated(asset, price, block.timestamp);
  }

  function healthCheck() external view returns (bool) {
    return block.timestamp < lastUpdate + 1 hours;
  }
}