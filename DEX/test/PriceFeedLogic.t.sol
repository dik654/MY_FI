// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import "../src/tests/TestPriceFeedLogic.sol";

contract PriceFeedLogicTest is Test {
    TestPriceFeedLogic public testPriceFeed;
    address eth;

    function setUp() public {
        eth = vm.envAddress("ETH_ADDRESS");
    }

    function testGetPrimaryPrice() public {
        testPriceFeed = new TestPriceFeedLogic();
        testPriceFeed.getPrimaryPrice(eth);
    }

}