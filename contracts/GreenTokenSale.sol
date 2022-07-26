// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import './GreenToken.sol';
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.8/Denominations.sol";

//I created the GreenTokenSale file where we will determine the token sale-sales and 
//token price. 
contract GreenTokenSale {
    GreenToken public token; //Define token
    address payable public admin; //Define msg.sender
    address payable private ethFunds = payable(0x0A203D5bFf9c3f9AdAFaFF4fAeAb6c7512Ed40E9); // Another account
    uint256 public tokensSold; 
    int public tokenPriceEUR; //Define token price
    uint256 public transactionCount; //Define counts of transaction
    AggregatorV3Interface internal priceFeed1; //ETH/USD
    AggregatorV3Interface internal priceFeed2; //EUR/USD
    
    

    //The command to sell the amount to the buyer is entered in the last line.
    event Sell(address _buyer, uint256 _amount);
    //Objects named buyer and amount are defined.
    struct Transaction {
        address buyer;
        uint256 amount;
    }

    //Unsigned integers in the contract map to transections.
    mapping(uint256 => Transaction) public transaction;
 
    //I started making the constructor part of our token.
    //The price was defined in this section because when we redistributed the contract 
    //we were told that the price would be volatile.
    //This is why the address that distributes the contract is entered here. 
    
    //When the constructor contract is first distributed, the parameters are written and
    // these entered values cannot be changed.
    constructor(GreenToken _token) {
        priceFeed1 = AggregatorV3Interface(0x9326BFA02ADD2366b30bacB125260Af641031331);
        priceFeed2 = AggregatorV3Interface(0x0c15Ab9A0DB086e062194c273CC79f41597Bbf13);
        tokenPriceEUR = 1;
        token = _token;
        admin = payable(msg.sender);                
    }
   
    //Take ETH/USD parity
    function getETHPrice() public view returns(int) {
        (, int price1, , , ) = priceFeed1.latestRoundData();
        return (price1 / 10**8);
    }

    //Take EUR/USD parity
    function getEURPrice() public view returns(int) {
        (, int price2, , , ) = priceFeed2.latestRoundData();
        return (price2 / 10**8);
    }
    
    //The price of the token is determined in ethereum terms. => [(EUR/USD)/(ETH/USD)]
    function greenTokenPriceInETH() public view returns(int) {
        int ethPrice = getETHPrice() / getEURPrice();
        return tokenPriceEUR / ethPrice;
    }

    //In thıs part the token selling function is written.
    function buyToken(uint256 _amount) public payable {
        int greenTokenPriceETH = greenTokenPriceInETH();
        // Check that the buyer sends the enough ETH
        require(int(msg.value) >= greenTokenPriceETH * int(_amount));
        // Check that the sale contract provides the enough ETH to make this transaction.
        require(token.balanceOf(address(this)) >= _amount);
        // Make the transaction inside of the require
        // transfer returns a boolean value.
        require(token.transfer(msg.sender, _amount));
        // Transfer the ETH of the buyer to us
        ethFunds.transfer(msg.value);
        // Increase the amount of tokens sold
        tokensSold += _amount;
        // Increase the amount of transactions
        transaction[transactionCount] = Transaction(msg.sender, _amount);
        transactionCount++;
        // Emit the Sell event
        emit Sell(msg.sender, _amount);
    }

    //**The reason why we write the buyToken function first and write the token sending 
    // function separately below is to prevent the reentrancy attack. 
    //In this line tokens were also transmitted to the buyer. 
    function endSale() public {
        require(msg.sender == admin);
        // Return the tokens that were left inside of the sale contract
        uint256 amount = token.balanceOf(address(this));
        require(token.transfer(admin, amount));
        selfdestruct(payable(admin));
    }

}

//GreenToken Etherscan:https://kovan.etherscan.io/address/0xd2e94d2042c5180dc2cf2851ec54cc35565164f9
//TokenAddress:0xd2E94D2042c5180dc2Cf2851ec54CC35565164F9
