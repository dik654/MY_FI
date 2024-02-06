// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test, console2} from "forge-std/Test.sol";
import "./mocks/TestPriceFeedLogic.sol";
import "../src/AddressResolver.sol";
import "./mocks/PriceFeed.sol";
import "./mocks/Factory.sol";
import "./mocks/utils/ERC20.sol";
import "./mocks/Router.sol";

contract MockToken is ERC20 {
    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) {}

    function mint(address _account, uint256 _value) public {
        _mint(_account, _value);
    }
}

contract PriceFeedLogicTest is Test {
    address someRandomUser = vm.addr(2);
    Factory factory;
    PriceFeed priceFeed;
    MockToken weth;
    MockToken dai;
    MockToken wbtc;
    AddressResolver addressResolver;
    address daiWethPair;
    address wethWbtcPair;
    Router router;

    function setUp() public {
        vm.startPrank(someRandomUser);
        factory = new Factory();
        router = new Router(address(factory));
        addressResolver = new AddressResolver();
        addressResolver.setFactory(address(factory));
        dai = new MockToken("DAI", "DAI");
        wbtc = new MockToken("WBTC", "WBTC");
        weth = new MockToken("WETH", "WETH");
        dai.mint(someRandomUser, 1000000 ether);
        wbtc.mint(someRandomUser, 1000000 ether);
        weth.mint(someRandomUser, 1000000 ether);
        priceFeed = new PriceFeed();
        priceFeed.setAssetPrice(address(wbtc), 428040777214);
        priceFeed.setAssetPrice(address(weth), 22902663427);

        daiWethPair = factory.createPair(address(dai), address(weth));
        wethWbtcPair = factory.createPair(address(wbtc), address(weth));

        uint256 approveAmount;
        approveAmount = 20 ether;
        for (uint256 i = 0; i < 1; i++) {
            if (CPMM(daiWethPair).totalSupply() != 0) {
                (,, uint256 optimal0, uint256 optimal1) = router.getQuote(20 ether, 40 ether, address(weth), address(dai));
                approveAmount = (optimal0 > optimal1) ? optimal1 : optimal0;
            }
            dai.approve(address(router), approveAmount);
            weth.approve(address(router), approveAmount);
            router.addLiquidity(address(dai), address(weth), approveAmount, approveAmount, approveAmount * 95/100, approveAmount * 95/100, someRandomUser, block.timestamp + 1 hours);
            
            approveAmount = 100 ether;
            if (CPMM(wethWbtcPair).totalSupply() != 0) {
                (,, uint256 optimal0, uint256 optimal1) = router.getQuote(100 ether, 100 ether, address(weth), address(wbtc));
                approveAmount = (optimal0 > optimal1) ? optimal1 : optimal0;
            }
            ERC20(weth).approve(address(router), approveAmount);
            ERC20(wbtc).approve(address(router), approveAmount);
            router.addLiquidity(address(weth), address(wbtc), approveAmount, approveAmount, approveAmount * 95/100, approveAmount * 95/100, someRandomUser, block.timestamp + 1 hours);
            (uint112 _reserve0, uint112 _reserve1,) = CPMM(wethWbtcPair).getReserves();
            address[] memory path = new address[](2);
            path[0] = address(wbtc);
            path[1] = address(weth);
            wbtc.approve(address(router), 100 ether);
            console2.log(router.getAmountOut(10 ether, _reserve0, _reserve1));
            router.swapExactTokensForTokens(100 ether, router.getAmountOut(10 ether, _reserve0, _reserve1) * 95/100, path, someRandomUser, block.timestamp + 1 hours);
            console2.log(_reserve0, " ", _reserve1);
        }
        vm.stopPrank();
    }

    function testGetPrimaryPrice() public {
        setUp();
        TestPriceFeedLogic testPriceFeed = new TestPriceFeedLogic();
        testPriceFeed.initialize(address(priceFeed), address(addressResolver), address(weth), address(dai));
        console2.log(testPriceFeed.getEthPrice());
        console2.log(testPriceFeed.getPrimaryPrice(address(wbtc)));
    }

}