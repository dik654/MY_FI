// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test, console2} from "forge-std/Test.sol";
import "./mocks/TestFlashLoanLogic.sol";
import "./mocks/MockReceiverContract.sol";

contract FlashLoanLogicTest is Test {
    MockReceiverContract mockReceiverContract;
    function setUp() public {
        mockReceiverContract = new MockReceiverContract();
    }

    function testExecuteFlashLoan() public {
        TestFlashLoanLogic testFlashLoanLogic = new TestFlashLoanLogic();
    }
}