// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../types/DataTypes.sol";

library SwapLogic {
    // function updateCumulativeFundingRate(address _collateralToken, address _indexToken) public {
    //     bool shouldUpdate = vaultUtils.updateCumulativeFundingRate(_collateralToken, _indexToken);
    //     if (!shouldUpdate) {
    //         return;
    //     }

    //     if (lastFundingTimes[_collateralToken] == 0) {
    //         lastFundingTimes[_collateralToken] = block.timestamp.div(fundingInterval).mul(fundingInterval);
    //         return;
    //     }

    //     if (lastFundingTimes[_collateralToken].add(fundingInterval) > block.timestamp) {
    //         return;
    //     }

    //     uint256 fundingRate = getNextFundingRate(_collateralToken);
    //     cumulativeFundingRates[_collateralToken] = cumulativeFundingRates[_collateralToken].add(fundingRate);
    //     lastFundingTimes[_collateralToken] = block.timestamp.div(fundingInterval).mul(fundingInterval);

    //     emit UpdateFundingRate(_collateralToken, cumulativeFundingRates[_collateralToken]);
    // }
    
    // function _swap() internal {
    //     updateCumulativeFundingRate(_tokenIn, _tokenIn);
    //     updateCumulativeFundingRate(_tokenOut, _tokenOut);

    //     uint256 amountIn = _transferIn(_tokenIn);
    //     _validate(amountIn > 0, 27);

    //     uint256 priceIn = getMinPrice(_tokenIn);
    //     uint256 priceOut = getMaxPrice(_tokenOut);

    //     uint256 amountOut = amountIn.mul(priceIn).div(priceOut);
    //     amountOut = adjustForDecimals(amountOut, _tokenIn, _tokenOut);

    //     // adjust usdgAmounts by the same usdgAmount as debt is shifted between the assets
    //     uint256 usdgAmount = amountIn.mul(priceIn).div(PRICE_PRECISION);
    //     usdgAmount = adjustForDecimals(usdgAmount, _tokenIn, usdg);

    //     uint256 feeBasisPoints = vaultUtils.getSwapFeeBasisPoints(_tokenIn, _tokenOut, usdgAmount);
    //     uint256 amountOutAfterFees = _collectSwapFees(_tokenOut, amountOut, feeBasisPoints);

    //     _increaseUsdgAmount(_tokenIn, usdgAmount);
    //     _decreaseUsdgAmount(_tokenOut, usdgAmount);

    //     _increasePoolAmount(_tokenIn, amountIn);
    //     _decreasePoolAmount(_tokenOut, amountOut);

    //     _validateBufferAmount(_tokenOut);

    //     _transferOut(_tokenOut, amountOutAfterFees, _receiver);

    //     emit Swap(_receiver, _tokenIn, _tokenOut, amountIn, amountOut, amountOutAfterFees, feeBasisPoints);

    //     return amountOutAfterFees;
    // }
}