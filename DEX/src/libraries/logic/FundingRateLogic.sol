// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../types/DataTypes.sol";
import "../types/Constants.sol";
import "./FundingRateLogic.sol";

library FundingRateLogic {
    event UpdateFundingRate(address token, uint256 fundingRate);

    function updateCumulativeFundingRate(DataTypes.ReserveData storage self, address _collateralToken, bool _isLong) internal {
        if (self.lastFundingTimes[_collateralToken][_isLong] == 0) {
            self.lastFundingTimes[_collateralToken][_isLong] = block.timestamp / Constants.FUNDING_INTERVAL * Constants.FUNDING_INTERVAL;
            return;
        }

        if (self.lastFundingTimes[_collateralToken][_isLong] + Constants.FUNDING_INTERVAL > block.timestamp) {
            return;
        }

        uint256 fundingRate = getNextFundingRate(self, _collateralToken, _isLong);
        self.cumulativeFundingRates[_collateralToken][_isLong] = self.cumulativeFundingRates[_collateralToken][_isLong] + fundingRate;
        self.lastFundingTimes[_collateralToken][_isLong] = block.timestamp / Constants.FUNDING_INTERVAL * Constants.FUNDING_INTERVAL;

        emit UpdateFundingRate(_collateralToken, self.cumulativeFundingRates[_collateralToken][_isLong]);
    }

    function getNextFundingRate(DataTypes.ReserveData storage self, address _token, bool _isLong) internal view returns (uint256) {
        if (self.lastFundingTimes[_token][_isLong] + Constants.FUNDING_INTERVAL > block.timestamp) { return 0; }

        uint256 intervals = (block.timestamp - self.lastFundingTimes[_token][_isLong]) / Constants.FUNDING_INTERVAL;
        uint256 poolAmount = self.tokenReserve[_token];
        if (poolAmount == 0) { return 0; }

        uint256 _fundingRateFactor = 10;
        return _fundingRateFactor * self.tokenPositionData.reservedAmounts[_token][_isLong] * intervals / poolAmount;
    }
}