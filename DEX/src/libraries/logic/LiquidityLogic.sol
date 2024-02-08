// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../../interfaces/IERC20.sol";
import "../../interfaces/IDERC20.sol";
import "./PriceFeedLogic.sol";
import "../types/Constants.sol";
import "../types/DataTypes.sol";

library LiquidityLogic {
    event AddLiquidity(address indexed _token, uint256 _amount, address _to);
    event RemoveLiquidity(address indexed _token, uint256 _amount, address _to);

    function addLiquidity(DataTypes.ReserveData storage self, address _token, uint256 _amount, address _to) internal returns (uint256) {
    require(_amount > 0, "LiquidityLogic: add zero liquidity");
        // 토큰 전송
        IERC20(_token).transferFrom(msg.sender, address(this), _amount);
        require(self.tokenReserve[_token] + _amount <= self.totalData.maxLimit, "LiquidityLogic: exceed token limit");
        // reserve에 토큰 개수만큼 추가 (totalSupply)
        self.tokenReserve[_token] += _amount;

        uint256 amount = _amount * self.totalData.txFeeBP / Constants.BASIS_POINT;
        // depositToken 민팅
        IDERC20(self.depositTokenAddress[_token]).mint(_to, amount);

        // 이벤트
        emit AddLiquidity(_token, amount, _to);
        // deposit token 개수만큼 리턴
        return amount;
    }

    function removeLiquidity(DataTypes.ReserveData storage self, address _token, uint256 _amount, address _to) internal returns (uint256) {
        require(_amount > 0, "LiquidityLogic: remove zero liquidity");
        IDERC20(self.depositTokenAddress[_token]).burn(msg.sender, _amount);
        uint256 amount = _amount * self.totalData.txFeeBP / Constants.BASIS_POINT;
        self.tokenReserve[_token] -= amount;
        
        IERC20(_token).transfer(_to, amount);

        emit RemoveLiquidity(_token, amount, _to);
        return amount;
    }
}