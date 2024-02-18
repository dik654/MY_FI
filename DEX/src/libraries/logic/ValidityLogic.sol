// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../types/DataTypes.sol";

library ValidityLogic {
    function validateCashReserveRatio(DataTypes.ReserveData storage self, address _token, uint256 _delta) internal view {
        require(self.tokenReserve[_token] - _delta > self.totalData.maxLimit * self.totalData.cashReserveRatio / 100, "ExecuteFlashLoan: fail to validate CRR");
    }

    function validateReserveMaxLimit(DataTypes.ReserveData storage self, address _token, uint256 _delta) internal view {
        require(self.tokenReserve[_token] + _delta <= self.totalData.maxLimit, "validateReserveMaxLimit: exceed token limit");
    }
}