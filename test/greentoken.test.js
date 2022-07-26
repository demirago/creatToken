const GreenToken = artifacts.require('GreenToken');
const GreenTokenSale = artifacts.require('GreenTokenSale');

contract('GreenToken', () => {
    const initAmount = BigInt(1000000 * 10**18);
    it('The contract was initialized with the appropriate values', () => {
        GreenToken.deployed().then((GTO) => {
            GreenTokenSale.deployed().then((GTOS) => {
                GTO.transfer(GTOS.address, initAmount)
            });
        })
    });
});