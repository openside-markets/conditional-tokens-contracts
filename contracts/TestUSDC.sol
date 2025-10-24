// SPDX-License-Identifier: MIT
pragma solidity ^0.5.10;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20Mintable.sol";

contract TestUSDC is ERC20Mintable {
    string public name = "Test USDC";
    string public symbol = "USDC";
    uint8 public decimals = 6;
    
    constructor() public ERC20Mintable() {
        _mint(msg.sender, 1000000000000000000);
    }
}
