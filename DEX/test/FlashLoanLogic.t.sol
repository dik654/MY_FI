// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test, console2} from "forge-std/Test.sol";
import "./mocks/TestFlashLoanLogic.sol";
import "./mocks/MockReceiverContract.sol";
import "./mocks/MockToken.sol";

contract FlashLoanLogicTest is Test {
    MockReceiverContract mockReceiverContract;
    MockToken dai;
    address someRandomUser = vm.addr(2);

    function setUp() public {
        mockReceiverContract = new MockReceiverContract();
        dai = new MockToken("DAI", "DAI");
    }

    function testFail_ZeroAddress() public {
        TestFlashLoanLogic testFlashLoanLogic = new TestFlashLoanLogic();
        dai.mint(address(testFlashLoanLogic), 10 ether);
        testFlashLoanLogic.initialize(address(dai), 30 ether + 1, 100 ether, 20, 10);
        testFlashLoanLogic.executeFlashLoan(address(dai), 10 ether, someRandomUser, address(0));
    }

    function testFail_CantLoanExceedCRR() public {
        TestFlashLoanLogic testFlashLoanLogic = new TestFlashLoanLogic();
        dai.mint(address(testFlashLoanLogic), 10 ether);
        testFlashLoanLogic.initialize(address(dai), 80 ether, 100 ether, 20, 10);
        testFlashLoanLogic.executeFlashLoan(address(dai), 60 ether, someRandomUser, address(mockReceiverContract));
    }

    function test_ExecuteFlashLoan() public {
        TestFlashLoanLogic testFlashLoanLogic = new TestFlashLoanLogic();
        dai.mint(address(testFlashLoanLogic), 10 ether);
        testFlashLoanLogic.initialize(address(dai), 40 ether, 100 ether, 20, 10);
        testFlashLoanLogic.executeFlashLoan(address(dai), 10 ether, someRandomUser, address(mockReceiverContract));
        assertEq(40 ether + 10 ether * 10 / 10000, testFlashLoanLogic.getTokenReserve(address(dai)));
    }

    function test_FlashLoanProfit() public {
        TestFlashLoanLogic testFlashLoanLogic = new TestFlashLoanLogic();
        dai.mint(address(testFlashLoanLogic), 10 ether);
        testFlashLoanLogic.initialize(address(dai), 40 ether, 100 ether, 20, 10);
        testFlashLoanLogic.executeFlashLoan(address(dai), 10 ether, someRandomUser, address(mockReceiverContract));
        console2.log(testFlashLoanLogic.getTokenReserve(address(dai)));
        assertEq(10 ether, dai.balanceOf(someRandomUser));
    }
}