// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract HHCFaucet is Ownable {
    using SafeERC20 for IERC20;

    IERC20 public token; // declare IERC20 interface
    address public tokenAddress;
    uint256 public dripInterval;
    uint256 public dripLimit;
    mapping(address => uint256) dripTime;

    event HHCFaucet_Drip(address to, uint256 amount);
    event HHCFaucet_Deposit(uint256 amount);

    error HHCFaucet_BalanceNotEnough();
    error HHCFaucet_IntervalHasNotPassed();
    error HHCFaucet_ExceedLimit();
    error HHCFaucet_InsufficientBalance();

    constructor(address _tokenAddress, uint256 _dripInterval, uint256 _dripLimit, address _owner) Ownable(_owner) {
        token = IERC20(_tokenAddress);
        tokenAddress = _tokenAddress;
        dripInterval = _dripInterval;
        dripLimit = _dripLimit;
    }

    function drip(uint256 _amount) external {
        uint256 targetAmount = _amount;
        if (token.balanceOf(address(this)) < targetAmount) {
            revert HHCFaucet_BalanceNotEnough();
        }
        if (block.timestamp < dripTime[_msgSender()] + dripInterval) {
            revert HHCFaucet_IntervalHasNotPassed();
        }
        if (targetAmount > dripLimit) {
            revert HHCFaucet_ExceedLimit();
        }

        dripTime[_msgSender()] = block.timestamp;
        token.safeTransfer(_msgSender(), targetAmount);

        emit HHCFaucet_Drip(_msgSender(), targetAmount);
    }

    function deposit(uint256 _amount) external onlyOwner {
        uint256 targetAmount = _amount;
        if (targetAmount > token.balanceOf(_msgSender())) {
            revert HHCFaucet_InsufficientBalance();
        }

        token.safeTransferFrom(_msgSender(), address(this), targetAmount);

        emit HHCFaucet_Deposit(targetAmount);
    }

    function setDripInterval(uint256 _newDripInterval) external onlyOwner {
        dripInterval = _newDripInterval;
    }

    function setDripLimit(uint256 _newDripLimit) external onlyOwner {
        dripLimit = _newDripLimit;
    }

    function setTokenAddress(address _newTokenAddress) external onlyOwner {
        tokenAddress = _newTokenAddress;
    }

    function getDripTime(address _user) external view returns (uint256) {
        return dripTime[_user];
    }

    function getDripInterval() external view returns (uint256) {
        return dripInterval;
    }

    function getDripLimit() external view returns (uint256) {
        return dripLimit;
    }
}
