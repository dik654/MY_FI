// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../../interfaces/IPerpetualFutureLogic.sol";
import "../../interfaces/IERC20.sol";
import "../types/DataTypes.sol";
import "../types/Constants.sol";
import "./PriceFeedLogic.sol";

library PerpetualFuturesUtils {
    struct ReduceCollateralParams {
        uint256 fee;
        bool hasProfit;
        uint256 adjustedDelta;
        uint256 usdOut;
        uint256 usdOutAfterFee;
        uint256 tokenAmount;
    }

    function getPositionKey(address _account,address _token, bool _isLong) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(
            _account,
            _token,
            _isLong
        ));
    }

    function getPosition(DataTypes.ReserveData storage self, address _account, address _token, bool _isLong) internal view returns (DataTypes.PositionData memory) {
        bytes32 key = getPositionKey(_account, _token, _isLong);
        return self.positions[key];
    }

    function getNextAveragePrice(DataTypes.ReserveData storage self, address _indexToken, uint256 _size, uint256 _averagePrice, bool _isLong, uint256 _nextPrice, uint256 _sizeDelta, uint256 _lastIncreasedTime) public view returns (uint256) {
        // 변화량을 확인하여 변화량이 이득인지 손해인지 체크
        (bool hasProfit, uint256 delta) = getDelta(self, _indexToken, _size, _averagePrice, _isLong, _lastIncreasedTime);
        uint256 nextSize = _size + _sizeDelta;
        uint256 divisor;
        // long이라면
        if (_isLong) {
            divisor = hasProfit ? nextSize + delta : nextSize - delta;
        } else {
            divisor = hasProfit ? nextSize - delta : nextSize + delta;
        }
        // (nextPrice * nextSize)/ (nextSize +- delta)
        return _nextPrice * nextSize / divisor;
    }

    function getDelta(DataTypes.ReserveData storage self, address _token, uint256 _size, uint256 _averagePrice, bool _isLong, uint256 _lastIncreasedTime) internal view returns (bool, uint256) {
        // 평균 가격이 0이라면 초기값이므로 종료
        require(_averagePrice > 0, "no average price");
        // 이득이 있는지 체크해야하므로 long일 경우 
        // 여러 데이터 중 최소 가격을 가져와서 이득인지 체크할 준비
        uint256 price = PriceFeedLogic.getPrice(self, _token, _isLong);
        uint256 priceDelta = _averagePrice > price ? _averagePrice - price : price - _averagePrice;
        uint256 delta = _size * priceDelta / _averagePrice;

        bool hasProfit;

        // long일 경우
        if (_isLong) {
            // 가격이 작성해뒀던 평균가보다 크다면 이득
            hasProfit = price > _averagePrice;
        // short일 경우
        } else {
            // 가격이 작성해뒀던 평균가보다 작다면 이득
            hasProfit = _averagePrice > price;
        }

        // 일정 시간이 지나야 최소 이득을 얻을 수 있음
        uint256 minBps = block.timestamp > _lastIncreasedTime + Constants.MIN_PROFIT_TIME ? 0 : self.minProfitBasisPoints[_token];
        // 이득이지만 크기의 최소 이득 이하라면 delta는 0
        if (hasProfit && delta * Constants.PRICE_PRECISION <= _size * minBps) {
            delta = 0;
        }

        // 이득 여부, 크기 * 가격 변화량 / 저장된 가격
        return (hasProfit, delta);
    }

    function collectMarginFees(DataTypes.ReserveData storage self, address _token, uint256 _sizeDelta, uint256 _size, uint256 _entryFundingRate) internal returns (uint256) {
        uint256 feeUsd = getPositionFee(_sizeDelta);

        // 포지션 총 크기 * fundingRate
        uint256 fundingFee = getFundingFee(self, _token, _size, _entryFundingRate);
        feeUsd = feeUsd + fundingFee;

        uint256 feeTokens = usdToToken(self, _token, feeUsd, true);
        self.feeReserves[_token] = self.feeReserves[_token] + feeTokens;

        emit IPerpetualFutureLogic.CollectMarginFees(_token, feeUsd, feeTokens);
        return feeUsd;
    }

    function getPositionFee(uint256 _sizeDelta) internal pure returns (uint256) {
        if (_sizeDelta == 0) { return 0; }
        // 포지션 총 크기 변화량 - 레버리지 수수료
        uint256 afterFeeUsd = _sizeDelta * (Constants.BASIS_POINT - Constants.MARGIN_FEE_BASIS_POINTS) / Constants.BASIS_POINT;
        return _sizeDelta - afterFeeUsd;
    }

    function getFundingFee(DataTypes.ReserveData storage self,address _token, uint256 _size, uint256 _entryFundingRate) internal view returns (uint256) {
        if (_size == 0) { return 0; }
        // 오랫동안 포지션을 유지함에 따라 생기는 funding rate를 계산하여 fee에 적용
        uint256 fundingRate = self.cumulativeFundingRates[_token] - _entryFundingRate;
        if (fundingRate == 0) { return 0; }

        // 포지션 총 크기 * fundingRate
        return _size * fundingRate / 1000000;
    }

    function usdToToken(DataTypes.ReserveData storage self, address _token, uint256 _usdAmount, bool _maximise) internal view returns (uint256) {
        if (_usdAmount == 0) { return 0; }
        return (_usdAmount * Constants.PRICE_PRECISION / PriceFeedLogic.getPrice(self, _token, _maximise));
    }

    function tokenToUsd(DataTypes.ReserveData storage self, address _token, uint256 _tokenAmount, bool _maximise) internal view returns (uint256) {
        if (_tokenAmount == 0) { return 0; }
        uint256 price = PriceFeedLogic.getPrice(self , _token, _maximise);
        return _tokenAmount * price / Constants.PRICE_PRECISION;
    }

    function validatePosition(uint256 _size, uint256 _collateral) internal pure {
        if (_size == 0) {
            require(_collateral == 0, "PerpetualFuturesUtils: size is 0, collateral is not 0");
            return;
        }
        require(_size >= _collateral, "PerpetualFuturesUtils: collateral is bigger than size");
    }

    function validateLiquidation(DataTypes.ReserveData storage self, address _account, address _token, bool _isLong, bool _raise) internal view returns (uint256, uint256) {
        // 포지션 가져오기
        DataTypes.PositionData memory position = getPosition(self, _account, _token, _isLong);

        // 이득 여부, 변화량 = 크기 * 변화량 / 저장된 가격
        (bool hasProfit, uint256 delta) = getDelta(self, _token, position.size, position.averagePrice, _isLong, position.lastIncreasedTime);
        // margin fee = funding fee + position fee
        uint256 marginFees = getFundingFee(self, _token, position.size, position.entryFundingRate);
        marginFees = marginFees + getPositionFee(position.size);

        // 손해이고 변화량이 담보보다 크다면
        if (!hasProfit && position.collateral < delta) {
            if (_raise) { revert("PerpetualFuturesUtils: losses exceed collateral"); }
            return (1, marginFees);
        }   

        uint256 remainingCollateral = position.collateral;
        // 손해라면 (담보 - 변화량)으로 남은 담보 계산
        if (!hasProfit) {
            remainingCollateral = position.collateral - delta;
        }

        // 남은 담보가 마진 수수료를 감당하지 못한다면
        if (remainingCollateral < marginFees) {
            // 엄격 모드일 경우 예외처리
            if (_raise) { revert("PerpetualFuturesUtils: fees exceed collateral"); }
            // 아니라면 청산 가능 true, 남은 담보의 크기 리턴
            return (1, remainingCollateral);
        }

        // 포지션의 손실이 담보를 초과하거나, 남은 담보가 마진 요구사항을 충족시키지 못하는 경우 (강제 청산)
        // 남은 담보가 마진 수수료 + 유동성 수수료보다 작다면
        if (remainingCollateral < marginFees + Constants.LIQUIDATION_FEE_USD) {
            // 엄격 모드일 경우 예외처리
            if (_raise) { revert("PerpetualFuturesUtils: liquidation fees exceed collateral"); }
            // 아니라면 청산 가능 true, 남은 담보의 크기 리턴
            return (1, marginFees);
        }

        // 포지션의 레버리지가 허용된 최대 레버리지를 초과하는 경우 (조정)
        // 최대 레버리지율울 넘어서는지 체크
        if (remainingCollateral * Constants.MAX_LEVERAGE < position.size * Constants.BASIS_POINT) {
            // 엄격 모드일 경우 예외처리
            if (_raise) { revert("Vault: maxLeverage exceeded"); }
            // 아니라면 청산 가능 true, 남은 담보의 크기 리턴
            return (2, marginFees);
        }

        return (0, marginFees);
    }

    function reduceCollateral(DataTypes.ReserveData storage self, address _account, address _token, uint256 _collateralDelta, uint256 _sizeDelta, bool _isLong) internal returns (uint256, uint256) {
        ReduceCollateralParams memory params;
        bytes32 key = getPositionKey(_account, _token, _isLong);
        DataTypes.PositionData storage position = self.positions[key];
        

        params.fee = collectMarginFees(self, _token, _sizeDelta, position.size, position.entryFundingRate);

        {
        (params.hasProfit, params.adjustedDelta) = getDelta(self, _token, position.size, position.averagePrice, _isLong, position.lastIncreasedTime);
        // get the proportional change in pnl
        params.adjustedDelta = _sizeDelta * params.adjustedDelta / position.size;
        }

        // transfer profits out
        if (params.hasProfit && params.adjustedDelta > 0) {
            params.usdOut = params.adjustedDelta;
            position.realisedPnl = position.realisedPnl + int256(params.adjustedDelta);

            // pay out realised profits from the pool amount for short positions
            if (!_isLong) {
                params.tokenAmount =(params.adjustedDelta * Constants.PRICE_PRECISION / PriceFeedLogic.getPrice(self, _token, true));
                decreasePoolAmount(self, _token, params.tokenAmount, _isLong);
            }
        }

        if (!params.hasProfit && params.adjustedDelta > 0) {
            position.collateral = position.collateral - params.adjustedDelta;

            // transfer realised losses to the pool for short positions
            // realised losses for long positions are not transferred here as
            // _increasePoolAmount was already called in increasePosition for longs
            if (!_isLong) {
                params.tokenAmount = usdToToken(self, _token, params.adjustedDelta, true);
                increasePoolAmount(self, _token, params.tokenAmount, _isLong);
            }

            position.realisedPnl = position.realisedPnl - int256(params.adjustedDelta);
        }

        // reduce the position's collateral by _collateralDelta
        // transfer _collateralDelta out
        if (_collateralDelta > 0) {
            params.usdOut = params.usdOut + _collateralDelta;
            position.collateral -= _collateralDelta;
        }

        // if the position will be closed, then transfer the remaining collateral out
        if (position.size == _sizeDelta) {
            params.usdOut += position.collateral;
            position.collateral = 0;
        }

        // if the usdOut is more than the fee then deduct the fee from the usdOut directly
        // else deduct the fee from the position's collateral
        uint256 usdOutAfterFee = params.usdOut;
        if (params.usdOut > params.fee) {
            usdOutAfterFee = params.usdOut - params.fee;
        } else {
            position.collateral -= params.fee;
            if (_isLong) {
                params.tokenAmount = usdToToken(self, _token, params.fee, true);
                decreasePoolAmount(self, _token, params.tokenAmount, _isLong);
            }
        }

        emit IPerpetualFutureLogic.UpdatePnl(key, params.hasProfit, params.adjustedDelta);

        return (params.usdOut, usdOutAfterFee);
    }

    function increasePoolAmount(DataTypes.ReserveData storage self, address _token, uint256 _amount, bool _isLong) internal {
        self.tokenPositionData.poolAmounts[_token][_isLong] = self.tokenPositionData.poolAmounts[_token][_isLong] + _amount;
        uint256 balance = IERC20(_token).balanceOf(address(this));
        require(self.tokenPositionData.poolAmounts[_token][_isLong] <= balance, "PerpetualFuturesUtils:");
        emit IPerpetualFutureLogic.IncreasePoolAmount(_token, _amount, _isLong);
    }

    function decreasePoolAmount(DataTypes.ReserveData storage self, address _token, uint256 _amount, bool _isLong) internal {
        self.tokenPositionData.poolAmounts[_token][_isLong] = self.tokenPositionData.poolAmounts[_token][_isLong] - _amount;
        require(self.tokenPositionData.reservedAmounts[_token][_isLong] <= self.tokenPositionData.poolAmounts[_token][_isLong], "PerpetualFuturesUtils:");
        emit IPerpetualFutureLogic.DecreasePoolAmount(_token, _amount, _isLong);
    }

    function increaseReservedAmount(DataTypes.ReserveData storage self, address _token, uint256 _amount, bool _isLong) internal {
        self.tokenPositionData.reservedAmounts[_token][_isLong] = self.tokenPositionData.reservedAmounts[_token][_isLong] + _amount;
        require(self.tokenPositionData.reservedAmounts[_token][_isLong] <= self.tokenPositionData.poolAmounts[_token][_isLong], "PerpetualFuturesUtils:");
        emit IPerpetualFutureLogic.IncreaseReservedAmount(_token, _amount);
    }

    function decreaseReservedAmount(DataTypes.ReserveData storage self, address _token, uint256 _amount, bool _isLong) internal {
        self.tokenPositionData.reservedAmounts[_token][_isLong] = self.tokenPositionData.reservedAmounts[_token][_isLong] - _amount;
        emit IPerpetualFutureLogic.DecreaseReservedAmount(_token, _amount);
    }

    function increaseGuaranteedUsd(DataTypes.ReserveData storage self, address _token, uint256 _usdAmount, bool _isLong) internal {
        self.tokenPositionData.guaranteedUsd[_token][_isLong] = self.tokenPositionData.guaranteedUsd[_token][_isLong] + _usdAmount;
        emit IPerpetualFutureLogic.IncreaseGuaranteedUsd(_token, _usdAmount);
    }

    function decreaseGuaranteedUsd(DataTypes.ReserveData storage self, address _token, uint256 _usdAmount, bool _isLong) internal {
        self.tokenPositionData.guaranteedUsd[_token][_isLong] = self.tokenPositionData.guaranteedUsd[_token][_isLong] - _usdAmount;
        emit IPerpetualFutureLogic.DecreaseGuaranteedUsd(_token, _usdAmount);
    }
}