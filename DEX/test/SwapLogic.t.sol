// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test, console2} from "forge-std/Test.sol";
import "./mocks/TestSwapLogic.sol";

contract SwapLogicTest is Test {
    TestSwapLogic testSwapLogic;

    function setUp() public {
        testSwapLogic = new TestSwapLogic();
    }

    function testSwap() public {

    }
}