// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IPerpetualFutureLogic {
    event CollectMarginFees(address token, uint256 feeUsd, uint256 feeTokens);
    event IncreasePoolAmount(address token, uint256 amount, bool isLong);
    event DecreasePoolAmount(address token, uint256 amount, bool isLong);
    event IncreaseReservedAmount(address token, uint256 amount);
    event DecreaseReservedAmount(address token, uint256 amount);
    event IncreaseGuaranteedUsd(address token, uint256 amount);
    event DecreaseGuaranteedUsd(address token, uint256 amount);
    event UpdatePnl(bytes32 key, bool hasProfit, uint256 delta);
    
    event IncreasePosition(
        bytes32 key,
        address account,
        address token,
        uint256 collateralDelta,
        uint256 sizeDelta,
        bool isLong,
        uint256 price,
        uint256 fee
    );
    event DecreasePosition(
        bytes32 key,
        address account,
        address token,
        uint256 collateralDelta,
        uint256 sizeDelta,
        bool isLong,
        uint256 price,
        uint256 fee
    );
    event LiquidatePosition(
        bytes32 key,
        address account,
        address token,
        bool isLong,
        uint256 size,
        uint256 collateral,
        uint256 reserveAmount,
        int256 realisedPnl,
        uint256 markPrice
    );
    event UpdatePosition(
        bytes32 key,
        uint256 size,
        uint256 collateral,
        uint256 averagePrice,
        uint256 entryFundingRate,
        uint256 reserveAmount,
        int256 realisedPnl,
        uint256 markPrice
    );
    event ClosePosition(
        bytes32 key,
        uint256 size,
        uint256 collateral,
        uint256 averagePrice,
        uint256 entryFundingRate,
        uint256 reserveAmount,
        int256 realisedPnl
    );

    function increasePosition(address _account, address _token, uint256 _collateralDelta, uint256 _sizeDelta, bool _isLong) external;
}