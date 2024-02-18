// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test, console2} from "forge-std/Test.sol";
import "./mocks/TestSwapLogic.sol";
import "./mocks/MockToken.sol";

contract SwapLogicTest is Test {
    address ownerUser = vm.addr(2);
    address toUser = vm.addr(3);
    TestSwapLogic testSwapLogic;
    MockToken weth;
    MockToken wbtc;

    function setUp() public {
        testSwapLogic = new TestSwapLogic();
        wbtc = new MockToken("WBTC", "WBTC");
        weth = new MockToken("WETH", "WETH");
        weth.mint(ownerUser, 1000000 ether);
        wbtc.mint(address(testSwapLogic), 1000000 ether);
    }

    function testFail_ExceedCRR() public {
        vm.startPrank(ownerUser);
        testSwapLogic.initialize(address(wbtc), 100 ether, 100 ether, 20, 10);
        weth.approve(address(testSwapLogic), 70 ether);
        testSwapLogic.swap(address(weth), address(wbtc), 80 ether, toUser);
        assertEq((70 ether - 70 ether * 0.001) * 10 ether / 30 ether, wbtc.balanceOf(address(toUser)));
        vm.stopPrank();
    }
    
    function test_Swap() public {
        vm.startPrank(ownerUser);
        testSwapLogic.initialize(address(wbtc), 100 ether, 100 ether, 20, 10);
        weth.approve(address(testSwapLogic), 70 ether);
        testSwapLogic.swap(address(weth), address(wbtc), 70 ether, toUser);
        assertEq((70 ether - 70 ether * 0.001) * 10 ether / 30 ether, wbtc.balanceOf(address(toUser)));
        vm.stopPrank();
    }
}