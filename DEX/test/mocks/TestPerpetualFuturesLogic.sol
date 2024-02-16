// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../../src/libraries/logic/PerpetualFuturesLogic.sol";
import "../../src/libraries/types/DataTypes.sol";

contract TestPerpetualFuturesLogic {
    using PerpetualFuturesLogic for DataTypes.ReserveData;

    DataTypes.ReserveData internal _reserveData;

    function increasePosition(DataTypes.PositionAdjustmentParams memory PositionAdjustmentParams) external {
        _reserveData.increasePosition(PositionAdjustmentParams);
    }

    function decreasePosition(DataTypes.PositionAdjustmentParams memory PositionAdjustmentParams) external returns (uint256) {
        return _reserveData.decreasePosition(PositionAdjustmentParams);
    }

    function liquidatePosition(DataTypes.PositionAdjustmentParams memory PositionAdjustmentParams) external {
        _reserveData.liquidatePosition(PositionAdjustmentParams);
    }
}