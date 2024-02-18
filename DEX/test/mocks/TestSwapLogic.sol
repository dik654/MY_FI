// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../../src/libraries/types/DataTypes.sol";
import "./SwapLogic.sol";

contract TestSwapLogic {
    using SwapLogic for DataTypes.ReserveData;

    DataTypes.ReserveData internal _reserveData;

    function initialize(address _token, uint256 _amount, uint256 _maxLimit, uint256 _crr, uint256 _txFee) external {
        _reserveData.tokenReserve[_token] = _amount;
        _reserveData.totalData.maxLimit = _maxLimit;
        _reserveData.totalData.cashReserveRatio = _crr;
        _reserveData.totalData.txFeeBP = _txFee;
    }

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