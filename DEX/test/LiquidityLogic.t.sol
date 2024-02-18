// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test, console2} from "forge-std/Test.sol";
import "./mocks/TestLiquidityLogic.sol";
import "./mocks/MockToken.sol";

// forge test --match-path test/LiquidityLogic.t.sol --match-contract LiquidityLogic -vv

contract LiquidityLogicTest is Test {
    address someRandomUser = vm.addr(2);
    MockToken dai;
    MockToken depositDai;

    function setUp() public {
        vm.startPrank(someRandomUser);
        dai = new MockToken("DAI", "DAI");
        depositDai = new MockToken("dDAI", "dDAI");
        dai.mint(someRandomUser, 1000 ether);
        vm.stopPrank();
    }

    function test_AddLiquidity() public {
        setUp();
        vm.startPrank(someRandomUser);
        TestLiquidityLogic testLiquidityLogic = new TestLiquidityLogic();
        testLiquidityLogic.initialize(1000000 ether, 100);
        testLiquidityLogic.mappingDepositToken(address(dai), address(depositDai));

        dai.approve(address(testLiquidityLogic), 1000 ether);
        assertEq(1000 ether - 1000 ether * 100/10000, testLiquidityLogic.addLiquidity(address(dai), 1000 ether, someRandomUser));
        vm.stopPrank();
    }

    function test_RemoveLiquidity() public {
        setUp();
        vm.startPrank(someRandomUser);
        TestLiquidityLogic testLiquidityLogic = new TestLiquidityLogic();
        testLiquidityLogic.initialize(1000000 ether, 100);
        testLiquidityLogic.mappingDepositToken(address(dai), address(depositDai));

        dai.approve(address(testLiquidityLogic), 1000 ether);
        testLiquidityLogic.addLiquidity(address(dai), 1000 ether, someRandomUser);
        testLiquidityLogic.removeLiquidity(address(dai), 10 ether, someRandomUser);
        assertEq(10 ether - 10 ether * 100/10000, dai.balanceOf(someRandomUser));
        vm.stopPrank();
    }

}