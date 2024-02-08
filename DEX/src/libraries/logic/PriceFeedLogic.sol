// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../../interfaces/IAddressResolver.sol";
import "../../interfaces/IFactory.sol";
import "../../interfaces/ICPMM.sol";
import "../../interfaces/IPriceFeed.sol";
import "../../libraries/types/Constants.sol";
import "../types/DataTypes.sol";

library PriceFeedLogic {
    function initialize(DataTypes.PriceFeedData storage self, address _priceFeed, address _addressResolver, address _weth, address _dai) internal {
        self.priceFeed = _priceFeed;
        self.addressResolver = _addressResolver;
        self.weth = _weth;
        self.dai = _dai;
    }
    
    function getPrice(DataTypes.PriceFeedData storage self, address _token, bool _maximise) internal view returns (uint256) {
        // oracle에서 가격 정보 받아오기
        uint256 price = getPrimaryPrice(self, _token);
        // oracle과 amm 가격 비교하여 제시
        price = getAmmPrice(self, _token, _maximise, price);
        return price;
    }

    function getPrimaryPrice(DataTypes.PriceFeedData storage self, address _token) internal view returns (uint256) {
        address priceFeed = self.priceFeed;
        require(priceFeed != address(0), "PriceFeed: invalid price feed");
        // oracle이 최신화되었는지 체크
        require(IPriceFeed(priceFeed).healthCheck(), "PriceFeed: Price feeds are not being updated");
        // coin market cap의 정밀도 6으로 나누기
        return IPriceFeed(priceFeed).getAssetPrice(_token) * (Constants.PRICE_PRECISION / Constants.COIN_MARKET_CAP_PRECISION);
    }

    function getAmmPrice(DataTypes.PriceFeedData storage self, address _token, bool _maximise, uint256 _price) internal view returns (uint256) {
        uint256 ethDai = getEthPrice(self);
        uint256 tokenEth = getPairPrice(self, _token);
        // 몇 달러의 가치가 있는지 계산
        uint256 ammPrice = ethDai * tokenEth / Constants.PRICE_PRECISION;
        // 조건에 맞는 price 제시
        if (_maximise && ammPrice > _price) {
            return ammPrice;
        } 
        
        if (!_maximise && ammPrice < _price) {
            return _price;
        }

        return _price;
    }

    function getEthPrice(DataTypes.PriceFeedData storage self) internal view returns (uint256) {
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
            return reserve1 * Constants.PRICE_PRECISION / reserve0;
        } else {
            return reserve0 * Constants.PRICE_PRECISION / reserve1;
        }
    }

    function getPairPrice(DataTypes.PriceFeedData storage self, address _token) internal view returns (uint256) {
        address weth = self.weth;
        (address token0, address token1) = _token < weth ? (_token, weth) : (weth, _token);
        address pair = IFactory(IAddressResolver(self.addressResolver).factory()).getPair(token0, token1);
        if (pair == address(0)) {
            revert("GetPairPrice: no pair on AMM");
        }

        (uint256 reserve0, uint256 reserve1, ) = ICPMM(pair).getReserves();
        if (reserve0 == 0) { return 0; }
        if (token0 == weth) {
            return reserve1 * Constants.PRICE_PRECISION / reserve0;
        } else {
            return reserve0 * Constants.PRICE_PRECISION / reserve1;
        }
    }
}