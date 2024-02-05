// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Script, console2} from "forge-std/Script.sol";
import "../src/CPMM.sol";

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
        console2.log("DAI balance: ", ERC20(dai).balanceOf(admin));
        console2.log("WETH balance: ", ERC20(weth).balanceOf(admin));
        console2.log("WBTC balance: ", ERC20(wbtc).balanceOf(admin));
        CPMM daiWethPair = CPMM(daiWeth);
        console2.log("Before daiWethPair: ", daiWethPair.totalSupply());
        ERC20(dai).approve(address(daiWethPair), 20 ether);
        ERC20(weth).approve(address(daiWethPair), 20 ether);
        daiWethPair.mint(admin, 10 ether, 20 ether);
        console2.log("After daiWethPair: ", daiWethPair.totalSupply());
        CPMM wethWbtcPair = CPMM(wethWbtc);
        console2.log("Before wethWbtcPair: ", wethWbtcPair.totalSupply());
        ERC20(weth).approve(address(wethWbtcPair), 200 ether);
        ERC20(wbtc).approve(address(wethWbtcPair), 200 ether);
        wethWbtcPair.mint(admin, 100 ether, 200 ether);
        console2.log("After wethWbtcPair: ", wethWbtcPair.totalSupply());
        vm.stopBroadcast();
    }
}