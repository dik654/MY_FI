// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../../src/libraries/types/DataTypes.sol";
import "../../src/libraries/logic/LiquidityLogic.sol";

contract TestLiquidityLogic {
    using LiquidityLogic for DataTypes.ReserveData;

    DataTypes.ReserveData internal _reserveData;

    function addLiquidity(address _token, uint256 _amount, address _to) external returns (uint256) {
        return LiquidityLogic.addLiquidity(
            _reserveData, 
            _token, 
            _amount, 
            _to
        );
    }

    function removeLiquidity(address _token, uint256 _amount, address _to) external returns (uint256) {
        return LiquidityLogic.removeLiquidity(
            _reserveData,
            _token,
            _amount,
            _to
        );
    }
}