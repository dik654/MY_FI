// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

library FlashLoanLogic {
    function executeFlashLoan(address _token, uint256 _amount, address _to) internal {
        require(_to.code.length != 0, "FlashLoanLogic: Caller is not contract");
    }
}