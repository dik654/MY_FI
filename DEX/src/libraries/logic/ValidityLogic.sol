// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../types/DataTypes.sol";

library ValidityLogic {
    function validateCashReserveRatio(DataTypes.ReserveData storage self, address _token) internal view {
        require(self.tokenReserve[_token] > self.totalData.maxLimit * self.totalData.cashReserveRatio / 100);
    }
}