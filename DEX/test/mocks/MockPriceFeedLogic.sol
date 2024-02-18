// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../../src/libraries/types/Constants.sol";
import "../../src/libraries/types/DataTypes.sol";

library MockPriceFeedLogic {
    function getPrice(DataTypes.ReserveData storage self, address _token, bool _maximise) internal pure returns (uint256) {
        // oracle에서 가격 정보 받아오기
        if (!_maximise) {
            return 1 * Constants.PRICE_PRECISION; 
        } else {
            return 3 * Constants.PRICE_PRECISION;
        }
    }
}