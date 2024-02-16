// SPDX-License-Identifier: GLP v3.0
pragma solidity ^0.8.19;

import "./utils/ERC20.sol";

contract MockToken is ERC20 {
    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) {}

    function mint(address _account, uint256 _value) public {
        _mint(_account, _value);
    }

    function burn(address _account, uint256 _value) public {
        _burn(_account, _value);
    }
}
