// SPDX-License-Identifier: MIT


/*
     88     888       888  .d88888b.   .d88888b.  8888888888
 .d88888b.  888   o   888 d88P" "Y88b d88P" "Y88b 888       
d88P 88"88b 888  d8b  888 888     888 888     888 888       
Y88b.88     888 d888b 888 888     888 888     888 8888888   
 "Y88888b.  888d88888b888 888     888 888     888 888       
     88"88b 88888P Y88888 888     888 888     888 888       
Y88b 88.88P 8888P   Y8888 Y88b. .d88P Y88b. .d88P 888       
 "Y88888P"  888P     Y888  "Y88888P"   "Y88888P"  888       
     88                                                          
*/


pragma solidity 0.8.20;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract WOOF is ERC20, ERC20Burnable, Ownable {

  mapping(address => bool) controllers;

constructor(address initialOwner) ERC20("WOOF", "WOOF") Ownable(initialOwner) { }

  function mint(address to, uint256 amount) external {
    require(controllers[msg.sender], "Only controllers can mint");
    _mint(to, amount);
  }

  function burnFrom(address account, uint256 amount) public override {
      if (controllers[msg.sender]) {
          _burn(account, amount);
      }
      else {
          super.burnFrom(account, amount);
      }
  }

  function addController(address controller) external onlyOwner {
    controllers[controller] = true;
  }
