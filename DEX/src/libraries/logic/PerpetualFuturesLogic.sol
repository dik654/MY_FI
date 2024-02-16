// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../types/DataTypes.sol";
import "../types/Constants.sol";
import "./PriceFeedLogic.sol";
import "./PerpetualFuturesUtils.sol";

library PerpetualFuturesLogic {
    using PerpetualFuturesUtils for DataTypes.ReserveData;
    using PriceFeedLogic for DataTypes.ReserveData;

    function increasePosition(DataTypes.ReserveData storage self, DataTypes.PositionAdjustmentParams memory params) internal {
        bytes32 key = PerpetualFuturesUtils.getPositionKey(params.account, params.token, params.isLong);
        DataTypes.PositionData storage position = self.positions[key];

        uint256 price = self.getPrice(params.token, params.isLong);

        // positionUtils.updateAveragePrice();
        // 평균 가격 최신화
        if (position.size == 0) {
            position.averagePrice = price;
        }

        // 포지션 변경시 바뀌는 평균가격 최신화
        if (position.size > 0 && params.sizeDelta > 0) {
            position.averagePrice = self.getNextAveragePrice(params.token, position.size, position.averagePrice, params.isLong, price, params.sizeDelta, position.lastIncreasedTime);
        }

        
        // 레버리지 수수료 계산
        uint256 fee = self.collectMarginFees(params.token, params.sizeDelta, position.size, position.entryFundingRate);
        // 이번 트랜잭션에 넣은 담보 토큰 개수
        require(IERC20(params.token).transferFrom(msg.sender, address(this), params.collateralDelta), "IncreasePosition: transfer colletral token fail");
        self.tokenReserve[params.token] += params.collateralDelta;
        // 이번 트랜잭션에 넣은 담보 토큰의 가격 
        uint256 collateralDeltaUsd = self.tokenToUsd(params.token, params.collateralDelta, false);

        // 포지션 담보에 이번 트랜잭션에 넣은 담보 토큰의 가격을 더해서 업데이트
        position.collateral += collateralDeltaUsd;
        // 포지션 담보가 레버리지 수수료를 감당할 수 있는지 확인
        require(position.collateral >= fee, "IncreasePosition: collateral can't find fee");

        // 감당 가능하다면 수수료만큼 포지션 담보에서 빼기
        position.collateral -= fee;
        // 포지션 시작 수수료 최신화 
        position.entryFundingRate = self.cumulativeFundingRates[params.token];
        // 포지션의 크기 최신화
        position.size += params.sizeDelta;
        // 포지션 마지막 증가 시간 최신화
        position.lastIncreasedTime = block.timestamp;

        require(position.size > 0, "IncreasePosition: size must bigger than 0");
        PerpetualFuturesUtils.validatePosition(position.size, position.collateral);
        self.validateLiquidation(params.account, params.token, params.isLong, true);

        // 포지션으로 들어가는 담보 토큰은 reserve로 추가
        uint256 reserveDelta = self.usdToToken(params.token, params.sizeDelta, false);
        position.reserveAmount += reserveDelta;
        self.increaseReservedAmount(params.token, reserveDelta, params.isLong);

        // 수수료는 담보에서 빠져나갔으니 (포지션 크기 - 담보)인 순수익에 fee만큼을 더해준다 (포지션의 전체 가치(size)에서 담보(collateral)를 뺀 값)
        self.increaseGuaranteedUsd(params.token, params.sizeDelta + fee, params.isLong);
        self.decreaseGuaranteedUsd(params.token, collateralDeltaUsd, params.isLong);
        // 담보도 pool의 일부이므로 추가한다
        self.increasePoolAmount(params.token, params.collateralDelta, params.isLong);
        // fee는 pool에서 빠지는 값이므로 뺴준다
        self.decreasePoolAmount(params.token, self.usdToToken(params.token, fee, true), params.isLong);

        emit IPerpetualFutureLogic.IncreasePosition(key, params.account, params.token, collateralDeltaUsd, params.sizeDelta, params.isLong, price, fee);
        emit IPerpetualFutureLogic.UpdatePosition(key, position.size, position.collateral, position.averagePrice, position.entryFundingRate, position.reserveAmount, position.realisedPnl, price);
    }

    function decreasePosition(DataTypes.ReserveData storage self, DataTypes.PositionAdjustmentParams memory params) internal returns (uint256) {
        bytes32 key = PerpetualFuturesUtils.getPositionKey(params.account, params.token, params.isLong);
        DataTypes.PositionData storage position = self.positions[key];
        require(position.size > 0, "DecreasePosition: size is 0");
        require(position.size >= params.sizeDelta, "DecreasePosition: decrease size over exist size");
        require(position.collateral >= params.collateralDelta, "DecreasePosition: decrease collateral over exist collateral");

        uint256 collateral = position.collateral;
        {
            // 포지션 내의 reserve 감소시키기
            uint256 reserveDelta = position.reserveAmount * params.sizeDelta / position.size;
            position.reserveAmount = position.reserveAmount - reserveDelta;
            // 토큰 전체의 포지션 reserve 감소시키기
            self.decreaseReservedAmount(params.token, reserveDelta, params.isLong);
        }

        // 담보 감소시키기
        (uint256 usdOut, uint256 usdOutAfterFee) = self.reduceCollateral(params.account, params.token, params.collateralDelta, params.sizeDelta, params.isLong);

        // 모두 빼는게 아니라면
        if (position.size != params.sizeDelta) {
            position.entryFundingRate = self.cumulativeFundingRates[params.token];
            // 전체 크기에서 빼려는 크기만큼을 빼고
            position.size = position.size - params.sizeDelta;
            uint256 changedCollateral = position.collateral;

            PerpetualFuturesUtils.validatePosition(position.size, changedCollateral);
            self.validateLiquidation(params.account, params.token, params.isLong, true);

            // 롱이라면
            // 보장 USD - 빼려는 크기 + 변화한 담보(_reduceCollateral로 position.collateral이 변화되었음)
            self.increaseGuaranteedUsd(params.token, collateral - changedCollateral, params.isLong);
            self.decreaseGuaranteedUsd(params.token, params.sizeDelta, params.isLong);

            uint256 price = self.getPrice(params.token, params.isLong);
            emit IPerpetualFutureLogic.DecreasePosition(key, params.account, params.token, params.collateralDelta, params.sizeDelta, params.isLong, price, usdOut - usdOutAfterFee);
            emit IPerpetualFutureLogic.UpdatePosition(key, position.size, changedCollateral, position.averagePrice, position.entryFundingRate, position.reserveAmount, position.realisedPnl, price);
        } else {
            // 모두 빼는거라면
            // 보장 USD - 전체 크기 + 전체 담보 (포지션의 전체 가치(size)에서 담보(collateral)를 뺀 값)
            self.increaseGuaranteedUsd(params.token, collateral, params.isLong);
            self.decreaseGuaranteedUsd(params.token, params.sizeDelta, params.isLong);

            uint256 price = self.getPrice(params.token, params.isLong);
            emit IPerpetualFutureLogic.DecreasePosition(key, params.account, params.token, params.collateralDelta, params.sizeDelta, params.isLong, price, usdOut - usdOutAfterFee);
            emit IPerpetualFutureLogic.ClosePosition(key, position.size, position.collateral, position.averagePrice, position.entryFundingRate, position.reserveAmount, position.realisedPnl);
            // 모두 꺼냈으니 포지션 데이터 삭제
            delete self.positions[key];
        }

        if (usdOut > 0) {
            if (params.isLong) {
                // 꺼내는 만큼 pool에서도 빼기
                uint256 amount = self.usdToToken(params.token, usdOut, true);
                self.decreasePoolAmount(params.token, amount, params.isLong);
            }
            // 계산이 완료되어 수수료를 제외한 꺼낸 양만큼 receiver에게 전송
            uint256 amountOutAfterFees = self.usdToToken(params.token, usdOutAfterFee, true);
            require(IERC20(params.token).transfer(params.receiver, amountOutAfterFees), "DecreasePosition: fail to send token");
            self.tokenReserve[params.token] -= amountOutAfterFees;
            return amountOutAfterFees;
        }

        return 0;
    }

    function liquidatePosition(DataTypes.ReserveData storage self, DataTypes.PositionAdjustmentParams memory params) internal {
        bytes32 key = PerpetualFuturesUtils.getPositionKey(params.account, params.token, params.isLong);
        DataTypes.PositionData memory position = self.positions[key];
        require(position.size > 0, "LiquidatePosition: size is 0");

        (uint256 liquidationState, uint256 marginFees) = self.validateLiquidation(params.account, params.token, params.isLong, false);
        require(liquidationState != 0, "LiquidatePosition: liqudation is not valid");
        if (liquidationState == 2) {
            // 담보변화량은 0으로 두고 size를 변화시켜서 레버리지 범위를 변경한다
            decreasePosition(self, params);
            return;
        }

        // 마진 수수료의 usd 가치만큼 feeReserves에 추가 
        uint256 feeTokens = self.usdToToken(params.token, marginFees, true);
        self.feeReserves[params.token] = self.feeReserves[params.token] + feeTokens;
        emit IPerpetualFutureLogic.CollectMarginFees(params.token, marginFees, feeTokens);

        // reserve pool에서 reserve amount만큼 빼기
        self.decreaseReservedAmount(params.token, position.reserveAmount, params.isLong);
        if (params.isLong) {
            // guaranteedUsd에서 (크기 - 담보)만큼 빼기
            self.decreaseGuaranteedUsd(params.token, position.size - position.collateral, params.isLong);
            // pool에서 usd 가치만큼 빼기
            self.decreasePoolAmount(params.token, self.usdToToken(params.token, marginFees, true), params.isLong);
        }

        uint256 markPrice = self.getPrice(params.token, params.isLong);
        emit IPerpetualFutureLogic.LiquidatePosition(key, params.account, params.token, params.isLong, position.size, position.collateral, position.reserveAmount, position.realisedPnl, markPrice);

        // 숏이고 담보가 마진 수수료를 감당할 수 있다면
        if (!params.isLong && marginFees < position.collateral) {
            // 수수료를 제외한 남은 담보만큼 pool에 증가시키기
            uint256 remainingCollateral = position.collateral - marginFees;
            self.increasePoolAmount(params.token, self.usdToToken(params.token, remainingCollateral, true), params.isLong);
        }

        // 포지션 정보 삭제
        delete self.positions[key];

        // 청산 실행자에게 청산 수수료를 전달
        self.decreasePoolAmount(params.token, self.usdToToken(params.token, Constants.LIQUIDATION_FEE_USD, true), params.isLong);
        require(IERC20(params.token).transfer(params.receiver, self.usdToToken(params.token, Constants.LIQUIDATION_FEE_USD, true)), "LiquidatePosition: fail to send token");
        self.tokenReserve[params.token] -= self.usdToToken(params.token, Constants.LIQUIDATION_FEE_USD, true);
    }
}