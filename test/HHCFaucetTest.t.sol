// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import {HaHaCoin} from "../src/HaHaCoin.sol";
import {HHCFaucet} from "../src/HHCFaucet.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract HHCFaucetTest is Test {
    HaHaCoin public hhc;
    HHCFaucet public faucet;
    address owner = vm.addr(1);
    address user = vm.addr(2);
    uint256 public dripInterval = 20 seconds;
    uint256 public dripLimit = 100;

    function setUp() public {
        hhc = new HaHaCoin(owner);
        faucet = new HHCFaucet(address(hhc), dripInterval, dripLimit, owner);
        vm.deal(owner, 1_000 ether);
        vm.deal(user, 1_000 ether);

        vm.startPrank(owner);
        hhc.mint(1_000 ether);
        hhc.approve(address(faucet), 1_000 ether); // to allow contract faucet takes hhc from msgSender's
        vm.stopPrank();
    }

    function testDrip() public {
        uint256 targetDripAmount = 100;
        uint256 targetDepositAmount = 1_000 ether;

        vm.prank(owner);
        faucet.deposit(targetDepositAmount);

        vm.warp(block.timestamp + dripInterval);

        vm.prank(user);
        faucet.drip(targetDripAmount);

        assertEq(100, hhc.balanceOf(user));
    }

    function testDeposit() public {
        uint256 targetAmount = 1_000 ether;
        vm.startPrank(owner);
        faucet.deposit(targetAmount);
        vm.stopPrank();
        assertEq(targetAmount, hhc.balanceOf(address(faucet)));
    }

    function testSuccessSetDripInterval() public {
        uint256 newDripInterval = 50 seconds;
        vm.startPrank(owner);
        faucet.setDripInterval(newDripInterval);
        vm.stopPrank();
        assertEq(50, faucet.getDripInterval());
    }

    function testFailSetDripInterval() public {
        uint256 newDripInterval = 5 seconds;
        vm.startPrank(user);
        vm.expectRevert(Ownable.OwnableUnauthorizedAccount.selector, address(user));
        faucet.setDripInterval(newDripInterval);
        vm.stopPrank();
    }

    function testSuccessSetDripLimit() public {
        uint256 newDripLimit = 150;
        vm.startPrank(owner);
        faucet.setDripLimit(newDripLimit);
        vm.stopPrank();
        assertEq(150, faucet.getDripLimit());
    }

    function testFailSetDripLimit() public {
        uint256 newDripLimit = 150;
        vm.startPrank(user);
        vm.expectRevert(Ownable.OwnableUnauthorizedAccount.selector, address(user));
        faucet.setDripLimit(newDripLimit);
        vm.stopPrank();
    }

    function testSetTokenAddress() public {
        address newAddress = vm.addr(3);
        vm.prank(owner);
        faucet.setTokenAddress(newAddress);
        assertEq(newAddress, faucet.tokenAddress());
    }
}
