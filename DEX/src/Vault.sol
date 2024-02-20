// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/console.sol";
import "./libraries/types/DataTypes.sol";
import "./libraries/logic/SwapLogic.sol";
import "./libraries/logic/LiquidityLogic.sol";
import "./libraries/logic/FlashLoanLogic.sol";
import "./libraries/logic/PerpetualFuturesLogic.sol";
import "./libraries/logic/PriceFeedLogic.sol";
import "./libraries/utils/ReentrancyGuard.sol";
import "./interfaces/IAddressResolver.sol";

contract Vault is ReentrancyGuard {
    using LiquidityLogic for DataTypes.ReserveData;
    using PerpetualFuturesLogic for DataTypes.ReserveData;
    using FlashLoanLogic for DataTypes.ReserveData;
    using PriceFeedLogic for DataTypes.PriceFeedData;

    DataTypes.ReserveData internal _reserveData;

    modifier onlyOwner {
        if (msg.sender != IAddressResolver(_reserveData.priceFeedData.addressResolver).admin()) {
            revert("AddressResolver: not owner");
        }
        _;
    }

    constructor(
        address _priceFeed, 
        address _addressResolver, 
        address _weth, 
        address _dai
    ) {
        PriceFeedLogic.initialize(
            _reserveData, 
            _priceFeed, 
            _addressResolver,
            _weth,
            _dai
        );
    }

    function initialize(uint256 _flashLoanBP, uint256 _txFeeBP, uint256 _maxLimit, uint256 _crr) external onlyOwner {
        _reserveData.totalData.flashLoanBP = _flashLoanBP;
        _reserveData.totalData.txFeeBP = _txFeeBP;
        _reserveData.totalData.maxLimit = _maxLimit;
        _reserveData.totalData.cashReserveRatio = _crr;
    }

    function getPrice(
        address _token, 
        bool _maximise
    ) external view returns (uint256 price) {
        return PriceFeedLogic.getPrice(
            _reserveData,
            _token,
            _maximise
        );
    }

    function getTotalData() external view returns (uint256 flashLoanBP, uint256 txFeeBP, uint256 maxLimit, uint256 crr) {
        flashLoanBP = _reserveData.totalData.flashLoanBP;
        txFeeBP = _reserveData.totalData.txFeeBP;
        maxLimit = _reserveData.totalData.maxLimit;
        crr = _reserveData.totalData.cashReserveRatio;
    }

    function getPoolData(address _token) external view returns (uint256 tokenReserve, address depositTokenAddress, uint256 minProfitBasisPoints, uint256 feeReserves) {
        tokenReserve = _reserveData.tokenReserve[_token];
        depositTokenAddress = _reserveData.depositTokenAddress[_token];
        minProfitBasisPoints = _reserveData.minProfitBasisPoints[_token];
        feeReserves = _reserveData.feeReserves[_token];
    }

    function getLongTokenPositionData(address _token) external view returns (uint256 reservedAmounts, uint256 guaranteedUsd, uint256 cumulativeFundingRates, uint256 lastFundingTimes) {
        reservedAmounts = _reserveData.tokenPositionData.reservedAmounts[_token][true];
        guaranteedUsd = _reserveData.tokenPositionData.guaranteedUsd[_token][true];
        cumulativeFundingRates = _reserveData.cumulativeFundingRates[_token][true];
        lastFundingTimes = _reserveData.lastFundingTimes[_token][true];
    }

    function getShortTokenPositionData(address _token) external view returns (uint256 reservedAmounts, uint256 guaranteedUsd, uint256 cumulativeFundingRates, uint256 lastFundingTimes) {
        reservedAmounts = _reserveData.tokenPositionData.reservedAmounts[_token][false];
        guaranteedUsd = _reserveData.tokenPositionData.guaranteedUsd[_token][false];
        cumulativeFundingRates = _reserveData.cumulativeFundingRates[_token][false];
        lastFundingTimes = _reserveData.lastFundingTimes[_token][false];
    }

    function getPositionData(address _account,address _token, bool _isLong) external view returns (uint256 size, uint256 collateral, uint256 averagePrice, uint256 entryFundingRate, uint256 reserveAmount, int256 realisedPnl, uint256 lastIncreasedTime) {
        bytes32 key = keccak256(abi.encodePacked(
            _account,
            _token,
            _isLong
        ));
        size = _reserveData.positions[key].size;
        collateral = _reserveData.positions[key].size;
        averagePrice = _reserveData.positions[key].averagePrice;
        entryFundingRate = _reserveData.positions[key].entryFundingRate;
        reserveAmount = _reserveData.positions[key].reserveAmount;
        realisedPnl = _reserveData.positions[key].realisedPnl;
        lastIncreasedTime = _reserveData.positions[key].lastIncreasedTime;
    }

    // -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= //

    function addLiquidity(address _token, uint256 _amount, address _to) external nonReentrant returns (uint256) {
        return LiquidityLogic.addLiquidity(
            _reserveData, 
            _token, 
            _amount, 
            _to
        );
    }

    function removeLiquidity(address _token, uint256 _amount, address _to) external nonReentrant returns (uint256) {
        return LiquidityLogic.removeLiquidity(
            _reserveData,
            _token,
            _amount,
            _to
        );
    }

    // -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= //

    function swap(address _tokenIn, address _tokenOut, uint256 _amountIn, address _to) external nonReentrant returns (uint256, uint256) {
        return SwapLogic.swap(
            _reserveData, 
            _tokenIn,
            _tokenOut, 
            _amountIn, 
            _to
        );
    }

    // -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= //

    function increasePosition(DataTypes.PositionAdjustmentParams memory PositionAdjustmentParams) external nonReentrant {
        _reserveData.increasePosition(PositionAdjustmentParams);
    }

    function decreasePosition(DataTypes.PositionAdjustmentParams memory PositionAdjustmentParams) external nonReentrant returns (uint256) {
        return _reserveData.decreasePosition(PositionAdjustmentParams);
    }

    function liquidatePosition(DataTypes.PositionAdjustmentParams memory PositionAdjustmentParams) external nonReentrant {
        _reserveData.liquidatePosition(PositionAdjustmentParams);
    }

    // -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= //

    function executeFlashLoan(address _token, uint256 _amount, address _to, address _contract, bytes memory _data) external nonReentrant {
        FlashLoanLogic.executeFlashLoan(
            _reserveData, 
            _token, 
            _amount, 
            _to, 
            _contract, 
            _data
        );
    }
}