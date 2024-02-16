// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../interfaces/IDERC20.sol";
import "./ERC20.sol";

contract DERC20 is ERC20, IDERC20 {
    constructor(
        string memory _name,
        string memory _symbol
    ) ERC20(_name, _symbol) {}

    function mint(
        address _to,
        uint256 _amount
    ) external override {
        _mint(_to, _amount);
    }

    function burn(
        address _from,
        uint256 _amount
    ) external override {
        _burn(_from, _amount);
    }
}