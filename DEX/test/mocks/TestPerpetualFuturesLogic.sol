// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../../src/libraries/logic/PerpetualFuturesLogic.sol";

contract TestFlashLoanLogic {
    using PerpetualFuturesLogic for DataTypes.ReserveData;

    DataTypes.ReserveData internal _reserveData;

    function increasePosition(address _account, address _token, uint256 _collateralDelta, uint256 _sizeDelta, bool _isLong) external {
        PerpetualFuturesLogic.increasePosition(_reserveData, _account, _token, _collateralDelta, _sizeDelta, _isLong);
    }

    function decreasePosition(address _account, address _token, uint256 _collateralDelta, uint256 _sizeDelta, bool _isLong, address _receiver) external returns (uint256) {
        return PerpetualFuturesLogic.decreasePosition(_reserveData, _account, _token, _collateralDelta, _sizeDelta, _isLong, _receiver);
    }

    function liquidatePosition(address _account, address _token, bool _isLong, address _feeReceiver) external {
        PerpetualFuturesLogic.liquidatePosition(_reserveData, _account, _token, _isLong, _feeReceiver);
    }
}