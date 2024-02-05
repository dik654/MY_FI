// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../libraries/types/DataTypes.sol";
import "../libraries/logic/PriceFeedLogic.sol";

contract TestPriceFeedLogic {
    using PriceFeedLogic for DataTypes.PriceFeedData;

    DataTypes.PriceFeedData internal _priceFeedData;

    function initialize(
        address _priceFeed, 
        address _addressResolver, 
        address _weth, 
        address _dai
    ) external {
        PriceFeedLogic.initialize(
            _priceFeedData, 
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
        return PriceFeedLogic.getPrice(
            _priceFeedData,
            _token,
            _maximise
        );
    }

    function getPrimaryPrice(
        address _token
    ) external view returns (uint256 price) {
        return PriceFeedLogic.getPrimaryPrice(
            _priceFeedData,
            _token
        );
    }

    function getAmmPrice(
        address _token, 
        bool _maximise, 
        uint256 _price
    ) external view returns (uint256 price) {
        return PriceFeedLogic.getAmmPrice(
            _priceFeedData,
            _token,
            _maximise,
            _price
        );
    }

    function getEthPrice() external view returns (uint256 price) {
        return PriceFeedLogic.getEthPrice(_priceFeedData);
    }

    function getPairPrice(address _token) external view returns (uint256 price) {
        return PriceFeedLogic.getPairPrice(_priceFeedData, _token);
    }
}