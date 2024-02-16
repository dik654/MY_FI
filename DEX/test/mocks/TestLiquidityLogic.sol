// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../../src/libraries/types/DataTypes.sol";
import "../../src/libraries/logic/LiquidityLogic.sol";

contract TestLiquidityLogic {
    using LiquidityLogic for DataTypes.ReserveData;

    DataTypes.ReserveData internal _reserveData;

    function initialize(uint256 _maxLimit, uint256 _txFee) external {
        _reserveData.totalData.maxLimit = _maxLimit;
        _reserveData.totalData.txFeeBP = _txFee;
    }

    function mappingDepositToken(address _token, address _deposit) external {
        _reserveData.depositTokenAddress[_token] = _deposit;
    }

    function getDepositToken(address _token) external view returns (address) {
        return _reserveData.depositTokenAddress[_token];
    }

    function addLiquidity(address _token, uint256 _amount, address _to) external returns (uint256) {
        return _reserveData.addLiquidity(
            _token, 
            _amount, 
            _to
        );
    }

    function removeLiquidity(address _token, uint256 _amount, address _to) external returns (uint256) {
        return _reserveData.removeLiquidity(
            _token,
            _amount,
            _to
        );
    }
}