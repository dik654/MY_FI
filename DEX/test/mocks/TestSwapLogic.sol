// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../../src/libraries/types/DataTypes.sol";
import "../../src/libraries/logic/SwapLogic.sol";

contract TestSwapLogic {
    using SwapLogic for DataTypes.ReserveData;

    DataTypes.ReserveData internal _reserveData;

    function swap(address _tokenIn, address _tokenOut, uint256 _amountIn, address _to) external returns (uint256, uint256) {
        return SwapLogic.swap(
            _reserveData, 
            _tokenIn,
            _tokenOut, 
            _amountIn, 
            _to
        );
    }
}