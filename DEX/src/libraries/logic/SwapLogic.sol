// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../../interfaces/IERC20.sol";
import "./PriceFeedLogic.sol";
import "./ValidityLogic.sol";
import "../types/Constants.sol";
import "../types/DataTypes.sol";

library SwapLogic {
    event Swap(address _tokenIn, address _tokenOut, uint256 _amountIn, address _to);

    function swap(DataTypes.ReserveData storage self, address _tokenIn, address _tokenOut, uint256 _amountIn, address _to) internal returns (uint256 amountIn, uint256 amountOut) {
        IERC20(_tokenIn).transferFrom(msg.sender, address(this), _amountIn);
        uint256 priceIn = PriceFeedLogic.getPrice(self.priceFeedData, _tokenIn, false);
        uint256 priceOut = PriceFeedLogic.getPrice(self.priceFeedData, _tokenOut, true);
        amountIn = _amountIn * self.totalData.txFeeBP / Constants.BASIS_POINT;
        amountOut = (amountIn * priceIn) / priceOut;
        
        ValidityLogic.validateCashReserveRatio(self, _tokenOut);
        IERC20(_tokenOut).transfer(_to, amountOut);
        emit Swap(_tokenIn, _tokenOut, _amountIn, _to);
    }
}