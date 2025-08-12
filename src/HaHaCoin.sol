// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract HaHaCoin is ERC20, Ownable {
    event Mint(uint256 indexed amount);
    event Burn(uint256 indexed amount);

    string _name = "HaHaCoin";
    string _symbol = "HHC";

    constructor(address initialOwner) ERC20(_name, _symbol) Ownable(initialOwner) {}

    function mint(uint256 _amount) public onlyOwner {
        _mint(owner(), _amount);
        emit Mint(_amount);
    }

    function burn(uint256 _amount) public onlyOwner {
        _burn(owner(), _amount);
        emit Burn(_amount);
    }
}
