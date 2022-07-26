// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';

//We enter the token name and abbreviation to meet the ERC20 requirements.
//Then we will have created a supply from the token with mint. 
//This supply will then remain constant as we do not create an extra accessible supply.
//For the lowest amount to be 0.01, I set the decimal as 2 in the function at the bottom. 

contract GreenToken is ERC20 {
    constructor() ERC20("GreenToken", "GTO") {
        _mint(msg.sender, 1000000 * 10**decimals());
    }
    function decimals() public view virtual override returns (uint8) {
        return 2;
    }
}