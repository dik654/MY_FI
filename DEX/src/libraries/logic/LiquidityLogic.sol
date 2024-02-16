// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../../interfaces/IERC20.sol";
import "../../interfaces/IDERC20.sol";
import "./PriceFeedLogic.sol";
import "./ValidityLogic.sol";
import "../types/Constants.sol";
import "../types/DataTypes.sol";

library LiquidityLogic {
    event AddLiquidity(address indexed _token, uint256 _amount, address _to);
    event RemoveLiquidity(address indexed _token, uint256 _amount, address _to);

    function addLiquidity(DataTypes.ReserveData storage self, address _token, uint256 _amount, address _to) internal returns (uint256) {
    require(_amount > 0, "LiquidityLogic: add zero liquidity");
        // 토큰 전송
        IERC20(_token).transferFrom(msg.sender, address(this), _amount);
        ValidityLogic.validateReserveMaxLimit(self, _token, _amount);
        // reserve에 토큰 개수만큼 추가 (totalSupply)
        self.tokenReserve[_token] += _amount;

        // 수수료를 제외한 양 계산
        uint256 amount = _amount - (_amount * self.totalData.txFeeBP / Constants.BASIS_POINT);
        // depositToken 민팅
        IDERC20(self.depositTokenAddress[_token]).mint(_to, amount);

        // 이벤트
        emit AddLiquidity(_token, amount, _to);
        // deposit token 개수만큼 리턴
        return amount;
    }

    function removeLiquidity(DataTypes.ReserveData storage self, address _token, uint256 _amount, address _to) internal returns (uint256) {
        require(_amount > 0, "RemoveLiquidity: remove zero liquidity");
        // deposit token 제거
        IDERC20(self.depositTokenAddress[_token]).burn(msg.sender, _amount);
        // 수수료를 제외한 양 계산
        uint256 amount = _amount - (_amount * self.totalData.txFeeBP / Constants.BASIS_POINT);
        // 수수료를 제외한, 꺼낸 토큰만큼 reserve에 적용
        self.tokenReserve[_token] -= amount;
        
        // 유저에게 토큰 전송
        require(IERC20(_token).transfer(_to, amount), "RemoveLiquidity: transfer fail");

        emit RemoveLiquidity(_token, amount, _to);
        return amount;
        // return 0;
    }


}