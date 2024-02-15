// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../types/DataTypes.sol";
import "../types/Constants.sol";
import "./PriceFeedLogic.sol";
import "./PerpetualFuturesUtils.sol";

library PerpetualFuturesLogic {
    function increasePosition(DataTypes.ReserveData storage self, address _account, address _token, uint256 _collateralDelta, uint256 _sizeDelta, bool _isLong) internal {
        bytes32 key = PerpetualFuturesUtils.getPositionKey(_account, _token, _isLong);
        DataTypes.PositionData storage position = self.positions[key];

        uint256 price = PriceFeedLogic.getPrice(self.priceFeedData, _token, _isLong);

        // 평균 가격 최신화
        if (position.size == 0) {
            position.averagePrice = price;
        }

        // 포지션 변경시 바뀌는 평균가격 최신화
        if (position.size > 0 && _sizeDelta > 0) {
            position.averagePrice = PerpetualFuturesUtils.getNextAveragePrice(self, _token, position.size, position.averagePrice, _isLong, price, _sizeDelta, position.lastIncreasedTime);
        }

        // 레버리지 수수료 계산
        uint256 fee = PerpetualFuturesUtils.collectMarginFees(self, _token, _sizeDelta, position.size, position.entryFundingRate);
        // 이번 트랜잭션에 넣은 담보 토큰 개수
        require(IERC20(_token).transferFrom(msg.sender, address(this), _collateralDelta), "IncreasePosition: transfer colletral token fail");
        self.tokenReserve[_token] += _collateralDelta;
        // 이번 트랜잭션에 넣은 담보 토큰의 가격 
        uint256 collateralDeltaUsd = PerpetualFuturesUtils.tokenToUsd(self, _token, _collateralDelta, false);

        // 포지션 담보에 이번 트랜잭션에 넣은 담보 토큰의 가격을 더해서 업데이트
        position.collateral += collateralDeltaUsd;
        // 포지션 담보가 레버리지 수수료를 감당할 수 있는지 확인
        require(position.collateral >= fee, "IncreasePosition: collateral can't find fee");

        // 감당 가능하다면 수수료만큼 포지션 담보에서 빼기
        position.collateral -= fee;
        // 포지션 시작 수수료 최신화 
        position.entryFundingRate = self.cumulativeFundingRates[_token];
        // 포지션의 크기 최신화
        position.size += _sizeDelta;
        // 포지션 마지막 증가 시간 최신화
        position.lastIncreasedTime = block.timestamp;

        require(position.size > 0, "IncreasePosition: size must bigger than 0");
        PerpetualFuturesUtils.validatePosition(position.size, position.collateral);
        PerpetualFuturesUtils.validateLiquidation(self, _account, _token, _isLong, true);

        // 포지션으로 들어가는 담보 토큰은 reserve로 추가
        uint256 reserveDelta = PerpetualFuturesUtils.usdToToken(self, _token, _sizeDelta, false);
        position.reserveAmount += reserveDelta;
        PerpetualFuturesUtils.increaseReservedAmount(self, _token, reserveDelta, _isLong);

        // 수수료는 담보에서 빠져나갔으니 (포지션 크기 - 담보)인 순수익에 fee만큼을 더해준다 (포지션의 전체 가치(size)에서 담보(collateral)를 뺀 값)
        PerpetualFuturesUtils.increaseGuaranteedUsd(self, _token, _sizeDelta + fee, _isLong);
        PerpetualFuturesUtils.decreaseGuaranteedUsd(self, _token, collateralDeltaUsd, _isLong);
        // 담보도 pool의 일부이므로 추가한다
        PerpetualFuturesUtils.increasePoolAmount(self, _token, _collateralDelta, _isLong);
        // fee는 pool에서 빠지는 값이므로 뺴준다
        PerpetualFuturesUtils.decreasePoolAmount(self, _token, PerpetualFuturesUtils.usdToToken(self, _token, fee, true), _isLong);

        emit IPerpetualFutureLogic.IncreasePosition(key, _account, _token, collateralDeltaUsd, _sizeDelta, _isLong, price, fee);
        emit IPerpetualFutureLogic.UpdatePosition(key, position.size, position.collateral, position.averagePrice, position.entryFundingRate, position.reserveAmount, position.realisedPnl, price);
    }

    function decreasePosition(DataTypes.ReserveData storage self, address _account, address _token, uint256 _collateralDelta, uint256 _sizeDelta, bool _isLong, address _receiver) internal returns (uint256) {
        bytes32 key = PerpetualFuturesUtils.getPositionKey(_account, _token, _isLong);
        DataTypes.PositionData storage position = self.positions[key];
        require(position.size > 0, "DecreasePosition: size is 0");
        require(position.size >= _sizeDelta, "DecreasePosition: decrease size over exist size");
        require(position.collateral >= _collateralDelta, "DecreasePosition: decrease collateral over exist collateral");

        uint256 collateral = position.collateral;
        {
            // 포지션 내의 reserve 감소시키기
            uint256 reserveDelta = position.reserveAmount * _sizeDelta / position.size;
            position.reserveAmount = position.reserveAmount - reserveDelta;
            // 토큰 전체의 포지션 reserve 감소시키기
            PerpetualFuturesUtils.decreaseReservedAmount(self, _token, reserveDelta, _isLong);
        }

        // 담보 감소시키기
        (uint256 usdOut, uint256 usdOutAfterFee) = PerpetualFuturesUtils.reduceCollateral(self, _account, _token, _collateralDelta, _sizeDelta, _isLong);

        // 모두 빼는게 아니라면
        if (position.size != _sizeDelta) {
            position.entryFundingRate = self.cumulativeFundingRates[_token];
            // 전체 크기에서 빼려는 크기만큼을 빼고
            position.size = position.size - _sizeDelta;

            PerpetualFuturesUtils.validatePosition(position.size, position.collateral);
            PerpetualFuturesUtils.validateLiquidation(self, _account, _token, _isLong, true);

            // 롱이라면
            // 보장 USD - 빼려는 크기 + 변화한 담보(_reduceCollateral로 position.collateral이 변화되었음)
            PerpetualFuturesUtils.increaseGuaranteedUsd(self, _token, collateral - position.collateral, _isLong);
            PerpetualFuturesUtils.decreaseGuaranteedUsd(self, _token, _sizeDelta, _isLong);

            uint256 price = PriceFeedLogic.getPrice(self.priceFeedData, _token, _isLong);
            emit IPerpetualFutureLogic.DecreasePosition(key, _account, _token, _collateralDelta, _sizeDelta, _isLong, price, usdOut - usdOutAfterFee);
            emit IPerpetualFutureLogic.UpdatePosition(key, position.size, position.collateral, position.averagePrice, position.entryFundingRate, position.reserveAmount, position.realisedPnl, price);
        } else {
            // 모두 빼는거라면
            // 보장 USD - 전체 크기 + 전체 담보 (포지션의 전체 가치(size)에서 담보(collateral)를 뺀 값)
            PerpetualFuturesUtils.increaseGuaranteedUsd(self, _token, collateral, _isLong);
            PerpetualFuturesUtils.decreaseGuaranteedUsd(self, _token, _sizeDelta, _isLong);

            uint256 price = PriceFeedLogic.getPrice(self.priceFeedData, _token, _isLong);
            emit IPerpetualFutureLogic.DecreasePosition(key, _account, _token, _collateralDelta, _sizeDelta, _isLong, price, usdOut - usdOutAfterFee);
            emit IPerpetualFutureLogic.ClosePosition(key, position.size, position.collateral, position.averagePrice, position.entryFundingRate, position.reserveAmount, position.realisedPnl);
            // 모두 꺼냈으니 포지션 데이터 삭제
            delete self.positions[key];
        }

        if (usdOut > 0) {
            if (_isLong) {
                // 꺼내는 만큼 pool에서도 빼기
                PerpetualFuturesUtils.decreasePoolAmount(self, _token, PerpetualFuturesUtils.usdToToken(self, _token, usdOut, true), _isLong);
            }
            // 계산이 완료되어 수수료를 제외한 꺼낸 양만큼 receiver에게 전송
            uint256 amountOutAfterFees = PerpetualFuturesUtils.usdToToken(self, _token, usdOutAfterFee, true);
            require(IERC20(_token).transfer(_receiver, amountOutAfterFees), "DecreasePosition: fail to send token");
            self.tokenReserve[_token] -= amountOutAfterFees;
            return amountOutAfterFees;
        }

        return 0;
    }

    function liquidatePosition(DataTypes.ReserveData storage self, address _account, address _token, bool _isLong, address _feeReceiver) internal {
        bytes32 key = PerpetualFuturesUtils.getPositionKey(_account, _token, _isLong);
        DataTypes.PositionData memory position = self.positions[key];
        require(position.size > 0, "LiquidatePosition: size is 0");

        (uint256 liquidationState, uint256 marginFees) = PerpetualFuturesUtils.validateLiquidation(self, _account, _token, _isLong, false);
        require(liquidationState != 0, "LiquidatePosition: liqudation is not valid");
        if (liquidationState == 2) {
            // 담보변화량은 0으로 두고 size를 변화시켜서 레버리지 범위를 변경한다
            decreasePosition(self, _account, _token, 0, position.size, _isLong, _account);
            return;
        }

        // 마진 수수료의 usd 가치만큼 feeReserves에 추가 
        uint256 feeTokens = PerpetualFuturesUtils.usdToToken(self, _token, marginFees, true);
        self.feeReserves[_token] = self.feeReserves[_token] + feeTokens;
        emit IPerpetualFutureLogic.CollectMarginFees(_token, marginFees, feeTokens);

        // reserve pool에서 reserve amount만큼 빼기
        PerpetualFuturesUtils.decreaseReservedAmount(self, _token, position.reserveAmount, _isLong);
        if (_isLong) {
            // guaranteedUsd에서 (크기 - 담보)만큼 빼기
            PerpetualFuturesUtils.decreaseGuaranteedUsd(self, _token, position.size - position.collateral, _isLong);
            // pool에서 usd 가치만큼 빼기
            PerpetualFuturesUtils.decreasePoolAmount(self, _token, PerpetualFuturesUtils.usdToToken(self, _token, marginFees, true), _isLong);
        }

        uint256 markPrice = PriceFeedLogic.getPrice(self.priceFeedData, _token, _isLong);
        emit IPerpetualFutureLogic.LiquidatePosition(key, _account, _token, _isLong, position.size, position.collateral, position.reserveAmount, position.realisedPnl, markPrice);

        // 숏이고 담보가 마진 수수료를 감당할 수 있다면
        if (!_isLong && marginFees < position.collateral) {
            // 수수료를 제외한 남은 담보만큼 pool에 증가시키기
            uint256 remainingCollateral = position.collateral - marginFees;
            PerpetualFuturesUtils.increasePoolAmount(self, _token, PerpetualFuturesUtils.usdToToken(self, _token, remainingCollateral, true), _isLong);
        }

        // 포지션 정보 삭제
        delete self.positions[key];

        // 청산 실행자에게 청산 수수료를 전달
        PerpetualFuturesUtils.decreasePoolAmount(self, _token, PerpetualFuturesUtils.usdToToken(self,_token, Constants.LIQUIDATION_FEE_USD, true), _isLong);
        require(IERC20(_token).transfer(_feeReceiver, PerpetualFuturesUtils.usdToToken(self, _token, Constants.LIQUIDATION_FEE_USD, true)), "LiquidatePosition: fail to send token");
        self.tokenReserve[_token] -= PerpetualFuturesUtils.usdToToken(self, _token, Constants.LIQUIDATION_FEE_USD, true);
    }
}