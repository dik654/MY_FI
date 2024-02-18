// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

library DataTypes {
  struct PriceFeedData {
    address priceFeed;
    address addressResolver;
    address weth;
    address dai;
  }

  struct UserData {
    mapping(address => uint256) balance;
  }

  struct TotalData {
    uint256 flashLoanBP;
    uint256 txFeeBP;
    uint256 totalValue;
    uint256 maxLimit;
    uint256 cashReserveRatio;
    uint256 executionFee;
  }

  struct ReserveData {
    PriceFeedData priceFeedData;
    TotalData totalData;
    mapping(address => uint256) tokenReserve;
    mapping(address => address) depositTokenAddress;
    mapping(address => uint256) minProfitBasisPoints;
    mapping(address => uint256) feeReserves;
    mapping(address => mapping(bool => uint256)) cumulativeFundingRates;
    mapping(address => mapping(bool => uint256)) lastFundingTimes;
    mapping(address => UserData) userData;
    mapping(bytes32 => PositionData) positions;
    TokenPositionData tokenPositionData;
  }

  struct PositionData {
    uint256 size;
    uint256 collateral;
    uint256 averagePrice;
    uint256 entryFundingRate;
    uint256 reserveAmount;
    int256 realisedPnl;
    uint256 lastIncreasedTime;
  }

  struct TokenPositionData {
    mapping (address => mapping(bool => uint256)) reservedAmounts;
    mapping (address => mapping(bool => uint256)) guaranteedUsd;
  }

  struct PositionAdjustmentParams {
    address account;
    address token;
    uint256 collateralDelta;
    uint256 sizeDelta;
    bool isLong;
    address receiver;
  }
}