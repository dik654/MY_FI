// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./interfaces/IAddressResolver.sol";
import "./interfaces/IFactory.sol";
import "./interfaces/ICPMM.sol";
import "./interfaces/IPriceFeed.sol";

library PriceFeedLogic {
    uint256 public immutable PRICE_PRECISION = 1e30;
    address public immutable DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address public immutable USDT = 0x6B175474E89094C44Da98b254EedeAC495271d0F;

    function getPrice(address _token, bool _maximise, bool _includeAmmPrice) public view returns (uint256) {
        uint256 price = getPrimaryPrice(_token, _maximise);
        price = getAmmPrice(_token, _maximise, price);

        if (IPoolStorage(poolStorage).strictStableTokens(_token)) {
            uint256 delta = price > ONE_USD ? price.sub(ONE_USD) : ONE_USD.sub(price);
            if (delta <= maxStrictPriceDeviation) {
                return ONE_USD;
            }

            // if _maximise and price is e.g. 1.02, return 1.02
            if (_maximise && price > ONE_USD) {
                return price;
            }

            // if !_maximise and price is e.g. 0.98, return 0.98
            if (!_maximise && price < ONE_USD) {
                return price;
            }

            return ONE_USD;
        }

        return price;
    }

    function getPrimaryPrice(address _token, bool _maximise) public view returns (uint256) {
        require(priceFeedAddress != address(0), "PriceFeed: invalid price feed");
        require(IPriceFeed(priceFeed).healthCheck(), "PriceFeed: Price feeds are not being updated");
        return IPriceFeed(priceFeed).getAssetPrice(_token);
    }

    function getAmmPrice(address _token) public override view returns (uint256) {
        uint256 eth = getEthPrice(WETH);
        uint256 tokenPrice = getPairPrice(_token);
        return tokenPrice * eth / PRICE_PRECISION;
    }

    function getEthPrice(address _addressResolver) public view returns (uint256) {
        (address token0, addresstoken1) = WETH < DAI ? (WETH, DAI) : (DAI, WETH);
        address pair = IFactory(IAddressResolver(_addressResolver).factory()).getPair(token0, token1);

        if (pair == address(0)) {
            revert("GetPairPrice: no pair on AMM");
        }

        (uint256 reserve0, uint256 reserve1, ) = ICPMM(pair).getReserves();
        if (reserve0 == 0) { return 0; }
        if (token0 == DAI) {
            return reserve1 * PRICE_PRECISION / reserve0;
        } else {
            return reserve0 * PRICE_PRECISION / reserve1;
        }
        return 0;
    }

    function getPairPrice(address _addressResolver, address _token) public view returns (uint256) {
        (address token0, address token1) = _token < WETH ? (_token, WETH) : (WETH, _token);
        address pair = IFactory(IAddressResolver(_addressResolver).factory()).getPair(token0, token1);
        if (pair == address(0)) {
            revert("GetPairPrice: no pair on AMM");
        }

        (uint256 reserve0, uint256 reserve1, ) = ICPMM(pair).getReserves();
        if (reserve0 == 0) { return 0; }
        if (token0 == DAI) {
            return reserve1 * PRICE_PRECISION / reserve0;
        } else {
            return reserve0 * PRICE_PRECISION / reserve1;
        }
        return 0;
    }

}