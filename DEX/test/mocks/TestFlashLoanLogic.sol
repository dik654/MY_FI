// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../../src/libraries/types/DataTypes.sol";
import "../../src/libraries/logic/FlashLoanLogic.sol";

contract TestFlashLoanLogic {
    using FlashLoanLogic for DataTypes.ReserveData;

    DataTypes.ReserveData internal _reserveData;

    function initialize(address _token, uint256 _amount, uint256 _maxLimit, uint256 _crr, uint256 _flashLoanBP) external {
        _reserveData.tokenReserve[_token] = _amount;
        _reserveData.totalData.maxLimit = _maxLimit;
        _reserveData.totalData.cashReserveRatio = _crr;
        _reserveData.totalData.flashLoanBP = _flashLoanBP;
    }

    function getTokenReserve(address _token) external view returns (uint256) {
        return _reserveData.tokenReserve[_token];
    }

    function executeFlashLoan(address _token, uint256 _amount, address _to, address _contract) external {
        _reserveData.executeFlashLoan(
            _token, 
            _amount, 
            _to, 
            _contract, 
            "0x"
        );
    }
}