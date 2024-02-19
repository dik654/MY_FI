// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Script, console2} from "forge-std/Script.sol";
import "../src/CPMM.sol";
import "../src/Router.sol";

// forge script script/ControlAmm.s.sol:ControlAmmScript --rpc-url http://localhost:8545 --broadcast --account testAccount --sender 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266

contract ControlAmmScript is Script {
    uint256 privateKey;
    address admin;
    address dai;
    address wbtc;
    address weth;
    address daiWeth;
    address wethWbtc;

    function setUp() public {
        privateKey = vm.envUint("PRIVATE_KEY");
        admin = vm.addr(privateKey);
        dai = vm.envAddress("DAI");
        wbtc = vm.envAddress("WBTC");
        weth = vm.envAddress("WETH");
        daiWeth = vm.envAddress("DAI_WETH");
        wethWbtc = vm.envAddress("WETH_WBTC");
    }

    function run() public {
        vm.startBroadcast();
        Router router = new Router(vm.envAddress("FACTORY"));
        console2.log("DAI balance: ", ERC20(dai).balanceOf(admin));
        console2.log("WETH balance: ", ERC20(weth).balanceOf(admin));
        console2.log("WBTC balance: ", ERC20(wbtc).balanceOf(admin));
        
        CPMM daiWethPair = CPMM(daiWeth);
        console2.log("Before daiWethPair: ", daiWethPair.totalSupply());
        
        uint256 approveAmount;
        approveAmount = 20 ether;
        if (daiWethPair.totalSupply() != 0) {
            (address token0, address token1, uint256 optimal0, uint256 optimal1) = router.getQuote(20 ether, 20 ether, weth, dai);
            approveAmount = (optimal0 > optimal1) ? optimal1 : optimal0;
            console2.log(token0, optimal0, token1, optimal1);
        }
        ERC20(dai).approve(address(router), approveAmount);
        ERC20(weth).approve(address(router), approveAmount);
        router.addLiquidity(dai, weth, approveAmount, approveAmount, approveAmount * 95/100, approveAmount * 95/100, admin, block.timestamp + 10 hours);
        console2.log("After daiWethPair: ", daiWethPair.totalSupply());
        
        CPMM wethWbtcPair = CPMM(wethWbtc);
        console2.log("Before wethWbtcPair: ", wethWbtcPair.totalSupply());
        
        approveAmount = 100 ether;
        if (wethWbtcPair.totalSupply() != 0) {
            (address token0, address token1, uint256 optimal0, uint256 optimal1) = router.getQuote(100 ether, 100 ether, weth, wbtc);
            approveAmount = (optimal0 > optimal1) ? optimal1 : optimal0;
            console2.log(token0, optimal0, token1, optimal1);
        }
        ERC20(weth).approve(address(router), approveAmount);
        ERC20(wbtc).approve(address(router), approveAmount);
        router.addLiquidity(weth, wbtc, approveAmount, approveAmount, approveAmount * 95/100, approveAmount * 95/100, admin, block.timestamp + 1 hours);
        console2.log("After wethWbtcPair: ", wethWbtcPair.totalSupply());
        vm.stopBroadcast();
    }
}