// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Script, console2} from "forge-std/Script.sol";
import "../src/utils/ERC20.sol";

// cast wallet import --interactive testAccount
// forge script script/Tokens.s.sol:TokensScript --rpc-url http://localhost:8545 --broadcast --account testAccount --sender 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266

contract MockToken is ERC20 {
    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) {}

    function mint(address _account, uint256 _value) public {
        _mint(_account, _value);
    }
}

contract TokensScript is Script {
    uint256 privateKey;
    address admin;

    function setUp() public {
        privateKey = vm.envUint("PRIVATE_KEY");
        admin = vm.addr(privateKey);
    }

    function run() public {
        vm.startBroadcast();
        MockToken dai = new MockToken("DAI", "DAI");
        console2.log("DAI: ", address(dai));
        MockToken wbtc = new MockToken("WBTC", "WBTC");
        console2.log("WBTC: ", address(wbtc));
        MockToken weth = new MockToken("WETH", "WETH");
        console2.log("WETH: ", address(weth));
        dai.mint(admin, 1000000 ether);
        wbtc.mint(admin, 1000000 ether);
        weth.mint(admin, 1000000 ether);
        vm.stopBroadcast();
    }
}