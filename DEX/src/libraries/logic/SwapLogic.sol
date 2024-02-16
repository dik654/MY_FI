// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../../interfaces/IERC20.sol";
import "./PriceFeedLogic.sol";
import "./ValidityLogic.sol";
import "../types/Constants.sol";
import "../types/DataTypes.sol";

library SwapLogic {
    using PriceFeedLogic for DataTypes.ReserveData;

    event Swap(address _tokenIn, address _tokenOut, uint256 _amountIn, address _to);

    function swap(DataTypes.ReserveData storage self, address _tokenIn, address _tokenOut, uint256 _amountIn, address _to) internal returns (uint256 amountIn, uint256 amountOut) {
        // 토큰 넣기
        require(IERC20(_tokenIn).transferFrom(msg.sender, address(this), _amountIn), "SwapLogic: transferFrom tokenIn fail");
        // 바꾸려는 amount가 0보다 큰지
        require(_amountIn > 0, "SwapLogic: amountIn must bigger than 0");
        // 받을 수 있는 토큰 개수 계산
        uint256 priceIn = self.getPrice(_tokenIn, false);
        uint256 priceOut = self.getPrice(_tokenOut, true);
        amountIn = _amountIn - (_amountIn * self.totalData.txFeeBP / Constants.BASIS_POINT);
        amountOut = (amountIn * priceIn) / priceOut;
        
        // 토큰을 받았을 때 해당 reserve에 지급준비금보다 많이 들어있는지 체크
        ValidityLogic.validateCashReserveRatio(self, _tokenOut, amountOut);
        // 토큰 받기
        require(IERC20(_tokenOut).transfer(_to, amountOut), "SwapLogic: transfer fail");
        emit Swap(_tokenIn, _tokenOut, _amountIn, _to);
    }
}