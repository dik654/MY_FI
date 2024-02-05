// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Script, console2} from "forge-std/Script.sol";
import "../src/Factory.sol";

// forge script script/DeployAmm.s.sol:DeployAmmScript --rpc-url http://localhost:8545 --broadcast --account testAccount --sender 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266

contract DeployAmmScript is Script {
    uint256 privateKey;
    address admin;
    address dai;
    address wbtc;
    address weth;

    function setUp() public {
        privateKey = vm.envUint("PRIVATE_KEY");
        admin = vm.addr(privateKey);
        dai = vm.envAddress("DAI");
        wbtc = vm.envAddress("WBTC");
        weth = vm.envAddress("WETH");
    }

    function run() public {
        vm.startBroadcast();
        Factory factory = new Factory();
        console2.log("FACTORY: ", address(factory));
        address daiWeth = factory.createPair(dai, weth);
        console2.log("DAI_WETH: ", daiWeth);
        address wethWbtc = factory.createPair(weth, wbtc);
        console2.log("WETH_WBTC: ", wethWbtc);
        vm.stopBroadcast();
    }
}