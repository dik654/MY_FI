// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract PriceFeed {
  uint256 public lastUpdate;
  mapping(address => uint256) internal prices;

  function getAssetPrice(address asset) external view returns (uint256) {
    return prices[asset];
  }

  function setAssetPrice(address asset, uint256 price) public {
    prices[asset] = price;
    lastUpdate = block.timestamp;
  }

  function healthCheck() external view returns (bool) {
    return block.timestamp < lastUpdate + 3 hours;
  }
}