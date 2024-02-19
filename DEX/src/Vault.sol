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