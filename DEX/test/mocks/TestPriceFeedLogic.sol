// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../../src/libraries/types/DataTypes.sol";
import "../../src/libraries/logic/PriceFeedLogic.sol";

contract TestPriceFeedLogic {
    using PriceFeedLogic for DataTypes.ReserveData;

    DataTypes.ReserveData internal _reserveData;

    function initialize(
        address _priceFeed, 
        address _addressResolver, 
        address _weth, 
        address _dai
    ) external {
        _reserveData.initialize(
            _priceFeed, 
            _addressResolver,
            _weth,
            _dai
        );
    }

    function getPrice(
        address _token, 
        bool _maximise
    ) external view returns (uint256 price) {
        return _reserveData.getPrice(
            _token,
            _maximise
        );
    }

    function getPrimaryPrice(
        address _token
    ) external view returns (uint256 price) {
        return _reserveData.getPrimaryPrice(
            _token
        );
    }

    function getAmmPrice(
        address _token, 
        bool _maximise, 
        uint256 _price
    ) external view returns (uint256 price) {
        return _reserveData.getAmmPrice(
            _token,
            _maximise,
            _price
        );
    }

    function getEthPrice() external view returns (uint256 price) {
        return PriceFeedLogic.getEthPrice(_reserveData);
    }

    function getPairPrice(address _token) external view returns (uint256 price) {
        return PriceFeedLogic.getPairPrice(_reserveData, _token);
    }
}