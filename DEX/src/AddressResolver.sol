// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract AddressResolver {
    address public factory;
    address public admin;

    modifier onlyOwner {
        if (msg.sender != admin) {
            revert("AddressResolver: not owner");
        }
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function setAdmin(address _admin) external onlyOwner {
        admin = _admin;
    }

    function setFactory(address _factory) external onlyOwner {
        factory = _factory;
    }
}