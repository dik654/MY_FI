// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Script, console2} from "forge-std/Script.sol";
import "../src/PriceFeed.sol";

// forge script script/PriceFeed.s.sol:PriceFeedScript --rpc-url http://localhost:8545 --broadcast --account testAccount --sender 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266

contract PriceFeedScript is Script {
    uint256 privateKey;
    address admin;

    function setUp() public {
        privateKey = vm.envUint("PRIVATE_KEY");
        admin = vm.addr(privateKey);
    }

    function run() public {
        vm.startBroadcast();
        PriceFeed priceFeed = new PriceFeed();
        console2.log("PRICE_FEED: ", address(priceFeed));
        vm.stopBroadcast();
    }
}