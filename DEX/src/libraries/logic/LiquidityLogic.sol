// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../../interfaces/IERC20.sol";
import "./PriceFeedLogic.sol";
import "../types/DataTypes.sol";

library LiquidityLogic {
    struct userData {
        mapping(address => uint256) balance;
    }

    struct reserveData {
        DataTypes.PriceFeedData priceFeedData;
        mapping(address => uint256) tokenReserve;
        mapping(address => uint256) tokenValue;
        mapping(address => userData) userData;
        uint256 maxLimit;
        uint256 minValue;
        uint256 executionFee;
    }


    function addLiquidity(reserveData storage self, address _token, address _to) internal returns (uint256) {
        uint256 updatedBalance = IERC20(_token).balanceOf(address(this));
        uint256 delta = updatedBalance - self.userData[msg.sender].balance[_token];
        require(delta > 0, "LiquidityLogic: add zero liquidity");

        uint256 price = PriceFeedLogic.getPrice(self.priceFeedData, _token, false);
        uint256 deltaValue = delta * price;
        require(deltaValue > self.minValue, "LiquidityLogic: must add more than min usd value"); 
        require(self.tokenValue[_token] + deltaValue <= self.maxLimit, "LiquidityLogic: exceed maximum reserve limit");

        // executionFee만큼 msg.value로 전송했는지
        // 남은 나머지는 반환

        // reserve에 토큰 개수만큼 추가 (totalSupply)
        // balance에 토큰 개수만큼 추가 (유저의 토큰 balance)
        // 토큰에 해당하는 Deposit token을 증가(시간이 지남에 따라 증가됨)

        // 이벤트
        // deposit token 개수만큼 리턴
    }

    function removeLiquidity() internal {

    }

}