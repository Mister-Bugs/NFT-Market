// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract BBB is ERC20 {
    constructor() ERC20("BBBToken", "BBB") {
        //印发一亿枚代币
        _mint(msg.sender, 1 * 10 ** 8 * 10 ** 18);
    }
}
