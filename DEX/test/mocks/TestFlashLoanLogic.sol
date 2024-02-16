// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../../src/libraries/types/DataTypes.sol";
import "../../src/libraries/logic/FlashLoanLogic.sol";

contract TestFlashLoanLogic {
    using FlashLoanLogic for DataTypes.ReserveData;

    DataTypes.ReserveData internal _reserveData;

    function executeFlashLoan(address _token, uint256 _amount, uint256 _premium, address _contract) external {
        _reserveData.executeFlashLoan(
            _token, 
            _amount, 
            _premium, 
            _contract, 
            "0x"
        );
    }
}