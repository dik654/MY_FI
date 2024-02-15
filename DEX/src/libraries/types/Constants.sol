// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

library Constants {
    uint256 internal constant COIN_MARKET_CAP_PRECISION = 1e6;
    uint256 internal constant PRICE_PRECISION = 1e30;
    uint256 internal constant ONE_USD = PRICE_PRECISION;
    uint256 internal constant BASIS_POINT = 10000;
    uint256 internal constant MIN_PROFIT_TIME = 600;
    uint256 internal constant MARGIN_FEE_BASIS_POINTS = 10;
    uint256 internal constant LIQUIDATION_FEE_USD = 10;
    uint256 internal constant MAX_LEVERAGE = 50 * 10000;
}