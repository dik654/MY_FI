// SPDX-License-Identifier: GLP v3.0
pragma solidity ^0.8.19;

interface IAddressResolver {
    function factory() external view returns (address);
    function admin() external view returns (address);
    function setAdmin(address _admin) external;
    function setFactory(address _factory) external;
}