// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./interfaces/IAddressResolver.sol";
import "./interfaces/IFactory.sol";
import "./interfaces/ICPMM.sol";
import "./interfaces/IPriceFeed.sol";

library PriceFeedLogic {
    uint256 public constant PRICE_PRECISION = 1e30;
    uint256 public constant ONE_USD = PRICE_PRECISION;
    struct PriceFeedData {
        address priceFeed;
        address addressResolver;
        address weth;
        address dai;
    }

    function getPrice(PriceFeedData storage self, address _token, bool _maximise) public view returns (uint256) {
        uint256 price = getPrimaryPrice(self, _token);
        price = getAmmPrice(self, _token, _maximise, price);
        return price;
    }

    function getPrimaryPrice(PriceFeedData storage self, address _token) public view returns (uint256) {
        address priceFeed = self.priceFeed;
        require(priceFeed != address(0), "PriceFeed: invalid price feed");
        require(IPriceFeed(priceFeed).healthCheck(), "PriceFeed: Price feeds are not being updated");
        return IPriceFeed(priceFeed).getAssetPrice(_token);
    }

    function getAmmPrice(PriceFeedData storage self, address _token, bool _maximise, uint256 _price) public view returns (uint256) {
        uint256 ethDai = getEthPrice(self);
        uint256 tokenEth = getPairPrice(self, _token);
        uint256 ammPrice = ethDai * tokenEth / PRICE_PRECISION;
        if (_maximise && ammPrice > _price) {
            return ammPrice;
        } 
        
        if (!_maximise && ammPrice < _price) {
            return _price;
        }

        return _price;
    }

    function getEthPrice(PriceFeedData storage self) public view returns (uint256) {
        address weth = self.weth;
        address dai = self.dai;
        (address token0, address token1) = weth < dai ? (weth, dai) : (dai, weth);
        address pair = IFactory(IAddressResolver(self.addressResolver).factory()).getPair(token0, token1);

        if (pair == address(0)) {
            revert("GetPairPrice: no pair on AMM");
        }

        (uint256 reserve0, uint256 reserve1, ) = ICPMM(pair).getReserves();
        if (reserve0 == 0) { return 0; }
        if (token0 == dai) {
            return reserve1 * PRICE_PRECISION / reserve0;
        } else {
            return reserve0 * PRICE_PRECISION / reserve1;
        }
    }

    function getPairPrice(PriceFeedData storage self, address _token) public view returns (uint256) {
        address weth = self.weth;
        (address token0, address token1) = _token < weth ? (_token, weth) : (weth, _token);
        address pair = IFactory(IAddressResolver(self.addressResolver).factory()).getPair(token0, token1);
        if (pair == address(0)) {
            revert("GetPairPrice: no pair on AMM");
        }

        (uint256 reserve0, uint256 reserve1, ) = ICPMM(pair).getReserves();
        if (reserve0 == 0) { return 0; }
        if (token0 == weth) {
            return reserve1 * PRICE_PRECISION / reserve0;
        } else {
            return reserve0 * PRICE_PRECISION / reserve1;
        }
    }
}