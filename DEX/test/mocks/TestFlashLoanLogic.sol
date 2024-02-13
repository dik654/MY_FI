// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../../src/libraries/types/DataTypes.sol";
import "../../src/libraries/logic/FlashLoanLogic.sol";

contract TestFlashLoanLogic {
    using FlashLoanLogic for DataTypes.ReserveData;

    DataTypes.ReserveData internal _reserveData;

    function executeFlashLoan(address _token, uint256 _amount, address _to, address _contract, bytes memory _data) external {
        FlashLoanLogic.executeFlashLoan(
            _reserveData, 
            _token, 
            _amount, 
            _to, 
            _contract, 
            _data
        );
    }
}