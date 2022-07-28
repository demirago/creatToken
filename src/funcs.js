import Web3 from 'web3'
import GreenToken from '../build/contracts/GreenToken.json';
import GreenTokenSale from '../build/contracts/GreenTokenSale.json';
const contract = require('@truffle/contract');

export const load = async() => {
    await loadWeb3();
    const account = await loadAccount();
    const { contractGTO, contractGTOS } = await loadContracts();
    const { ethFunds, transactionCount, tokensSold, ethPriceN, transactions } = await loadVariables(contractGTOS);
    const bal = await contractGTO.balanceOf(account);
    const myGTO = bal / 10**2;
    return { account, contractGTOS, contractGTO, ethFunds, transactionCount, tokensSold, ethPriceN, transactions, myGTO };
};


const loadVariables = async (contractGTOS) => {
    const admin = "0x0A203D5bFf9c3f9AdAFaFF4fAeAb6c7512Ed40E9";
    const ethFunds = await window.web3.eth.getBalance(admin);

    const tCount = await contractGTOS.transactionCount();
    const transactionCount = tCount.toNumber();

    const tSold = await contractGTOS.tokensSold();
    const tokensSold = window.web3.utils.fromWei(tSold, 'ether');

    const ethPrice = await contractGTOS.getETHPrice();
    const ethPriceN = ethPrice.toNumber();

    // Make this strange for loop to get the last 10 transactions.
    const transactions = [];
    var j = 0;
    for (var i = transactionCount - 1; i >= 0 && j < 10; i--) {
        const t = await contractGTOS.transaction(i);
        j++;
        transactions.push(t);
    }

    return { ethFunds, transactionCount, tokensSold, ethPriceN, transactions };
};

const loadContracts = async () => {
    const GTOContract = contract(GreenToken);
    GTOContract.setProvider(window.web3.currentProvider);
    const GTOSContract = contract(GreenTokenSale);
    GTOSContract.setProvider(window.web3.currentProvider);

    const contractGTO = await GTOContract.deployed();
    const contractGTOS = await GTOSContract.deployed();

    return { contractGTO, contractGTOS };
};

const loadAccount = async () => {
    const account = window.web3.eth.getCoinbase();
    return account;
};

const loadWeb3 = async() => {
    if (window.ethereum) {
        window.web3 = new Web3(ethereum);
        try {
            // Request account access if needed
            await ethereum.enable();
            // Acccounts now exposed
            web3.eth.sendTransaction({/* ... */});
        } catch (error) {
            // User denied account access...
        }
    }
    // Legacy dapp browsers...
    else if (window.web3) {
        window.web3 = new Web3(web3.currentProvider);
        // Acccounts always exposed
        web3.eth.sendTransaction({/* ... */});
    }
    // Non-dapp browsers...
    else {
        console.log('Non-Ethereum browser detected. You should consider trying MetaMask!');
    }
};
