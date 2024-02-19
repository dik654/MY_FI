// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import "../src/Vault.sol";
import "../src/AddressResolver.sol";

// forge script script/DeployDex.s.sol:DeployDexScript --rpc-url http://localhost:8545 --broadcast --account testAccount --sender 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266

contract DeployDexScript is Script {
    address priceFeed;
    address factory;
    address weth;
    address dai;

    function setUp() public {
        priceFeed = vm.envAddress("PRICE_FEED");
        factory = vm.envAddress("FACTORY");
        weth = vm.envAddress("WETH");
        dai = vm.envAddress("DAI");
    }

    function run() public {
        vm.startBroadcast();
        AddressResolver addressResolver = new AddressResolver();
        addressResolver.setFactory(address(factory));
        Vault vault = new Vault(priceFeed, address(addressResolver), address(weth), address(dai));
        console.log("VAULT: ", address(vault));
        vm.stopBroadcast();
    }
}
