// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../types/DataTypes.sol";
import "./PriceFeedLogic.sol";

library PerpetualFuturesLogic {
    function increasePosition(DataTypes.ReserveData storage self, address _account, address _token, bool _isLong) internal {
        bytes32 key = getPositionKey(_account, _token, _isLong);
        DataTypes.PositionData storage position = self.positions[key];

        uint256 price = PriceFeedLogic.getPrice(self.priceFeedData, _token, _isLong);

    }

    function getPositionKey(address _account,address _token, bool _isLong) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(
            _account,
            _token,
            _isLong
        ));
    }
}