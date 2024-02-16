// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test, console2} from "forge-std/Test.sol";
import "./mocks/TestPerpetualFuturesLogic.sol";

contract PerpetualFuturesLogicTest is Test {
    TestPerpetualFuturesLogic testPerpetualFuturesLogic;
    
    function setUp() public {
        testPerpetualFuturesLogic = new TestPerpetualFuturesLogic();
    }

    function testIncreasePosition() public {

    }

    function testDecreasePosition() public {

    }

    function testLiquidatePosition() public {

    }
}