// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test, console2} from "forge-std/Test.sol";
import "./mocks/TestPerpetualFuturesLogic.sol";
import "./mocks/MockToken.sol";
import "../src/libraries/types/DataTypes.sol";

// forge test --match-path test/PerpetualFuturesLogic.t.sol --match-contract PerpetualFuturesLogic -vv

contract PerpetualFuturesLogicTest is Test {
    MockToken dai;
    TestPerpetualFuturesLogic testPerpetualFuturesLogic;
    address ownerUser = vm.addr(2);
    address toUser = vm.addr(3);
    
    function setUp() public {
        dai = new MockToken("DAI", "DAI");
    }

    function test_IncreasePosition() public {
        DataTypes.PositionAdjustmentParams memory params = DataTypes.PositionAdjustmentParams({
            account: ownerUser,
            token: address(dai),
            collateralDelta: 10 ether,
            sizeDelta: 20 ether,
            isLong: true,
            receiver: toUser
        });
        vm.startPrank(ownerUser);
        testPerpetualFuturesLogic = new TestPerpetualFuturesLogic();
        testPerpetualFuturesLogic.initialize(address(dai), 10 ether);
        dai.mint(ownerUser, 100 ether);
        dai.mint(address(testPerpetualFuturesLogic), 100 ether);
        dai.approve(address(testPerpetualFuturesLogic), 10 ether);
        testPerpetualFuturesLogic.increasePosition(params);
        vm.stopPrank();
    }

    function test_DecreasePosition() public {
        DataTypes.PositionAdjustmentParams memory params1 = DataTypes.PositionAdjustmentParams({
            account: ownerUser,
            token: address(dai),
            collateralDelta: 10 ether,
            sizeDelta: 20 ether,
            isLong: true,
            receiver: address(0)
        });
        DataTypes.PositionAdjustmentParams memory params2 = DataTypes.PositionAdjustmentParams({
            account: ownerUser,
            token: address(dai),
            collateralDelta: 9 ether,
            sizeDelta: 20 ether,
            isLong: true,
            receiver: toUser
        });
        vm.startPrank(ownerUser);
        testPerpetualFuturesLogic = new TestPerpetualFuturesLogic();
        testPerpetualFuturesLogic.initialize(address(dai), 10 ether);
        dai.mint(ownerUser, 100 ether);
        dai.mint(address(testPerpetualFuturesLogic), 100 ether);
        dai.approve(address(testPerpetualFuturesLogic), 10 ether);
        testPerpetualFuturesLogic.increasePosition(params1);
        testPerpetualFuturesLogic.decreasePosition(params2);
        vm.stopPrank();
    }
}