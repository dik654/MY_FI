// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../../interfaces/IERC20.sol";
import "../../interfaces/IFlashLoanReceiver.sol";
import "../types/Constants.sol";
import "../types/DataTypes.sol";


library FlashLoanLogic {
    event ExecuteFlashLoan(address _token, uint256 _amount, address _to, address _contract, bytes _data);

    function executeFlashLoan(DataTypes.ReserveData storage self, address _token, uint256 _amount, address _to, address _contract, bytes memory _data) internal {
        uint256 reserve = self.tokenReserve[_token];
        // reserve에 충분한 자금이 있는지 체크
        require(reserve - _amount > reserve * self.totalData.cashReserveRatio / 100 );
        // 컨트랙트인지 검증
        require(_to.code.length != 0, "FlashLoanLogic: Caller is not contract");
        // 인터페이스로 프로토콜에 대한 approve 공격 대비
        IFlashLoanReceiver receiverContract = IFlashLoanReceiver(_contract);
        // 사용자에게 대출
        IERC20(_token).transfer(address(receiverContract), _amount);
        // 수수료 계산
        uint256 fee = _amount * self.totalData.flashLoanBP / Constants.BASIS_POINT;
        // 사용자 로직 실행
        require(receiverContract.executeOperation(_token, _amount, fee, _contract, _data), "FlashLoanLogic: fail to execute operation");
        // 수수료를 더해서 상환
        require(IERC20(_token).allowance(address(receiverContract), address(this)) >= _amount + fee, "FlashLoanLogic: not enough allowance");
        require(IERC20(_token).transferFrom(address(receiverContract), address(this), _amount + fee), "FlashLoanLogic: repayment fail");
        // reserve 업데이트
        self.tokenReserve[_token] += fee;
        // 이벤트
        emit ExecuteFlashLoan(_token, _amount, _to, _contract, _data);
    }
}