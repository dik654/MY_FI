// SPDX-License-Identifier: GLP v3.0
pragma solidity ^0.8.19;

import "./utils/DERC20.sol";

contract MockReceiverContract {
    event ExecutedWithFail(address asset, uint256 amount, uint256 premium);
    event ExecutedWithSuccess(address asset, uint256 amount, uint256 premium);

    bool internal _failExecution;
    uint256 internal _amountToApprove;
    bool internal _simulateEOA;

    function setFailExecutionTransfer(bool fail) public {
        _failExecution = fail;
    }

    function setAmountToApprove(uint256 amountToApprove) public {
        _amountToApprove = amountToApprove;
    }

    function setSimulateEOA(bool flag) public {
        _simulateEOA = flag;
    }

    function getAmountToApprove() public view returns (uint256) {
        return _amountToApprove;
    }

    function simulateEOA() public view returns (bool) {
        return _simulateEOA;
    }

    function executeOperation(
        address asset,
        uint256 amount,
        uint256 premium,
        address, // initiator
        bytes memory // params
    ) public returns (bool) {
        if (_failExecution) {
            emit ExecutedWithFail(asset, amount, premium);
            return !_simulateEOA;
        }

        //mint to this contract the specific amount
        DERC20 token = DERC20(asset);

        require(amount <= token.balanceOf(address(this)), 'Invalid balance for the contract');
        uint256 amountToReturn = (_amountToApprove != 0) ? _amountToApprove : amount + premium;
        token.mint(address(this), premium);
        token.approve(address(msg.sender), amountToReturn);

        emit ExecutedWithSuccess(asset, amount, premium);

        return true;
    }
 
}