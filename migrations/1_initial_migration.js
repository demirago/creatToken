
//This section is where we distribute the contracts we write. 
//What is written here are deploy functions and they are standard.
//At the same time, there are other folders called migrations.sol in my contract folder.
//It comes by default.

const GreenToken = artifacts.require("./greenTokenICO/GreenToken");
const GreenTokenSale = artifacts.require("./greenTokenICO/GreenTokenSale");

module.exports = function (deployer) {
  deployer.deploy(GreenToken).then(() => {
    deployer.deploy(GreenTokenSale, GreenToken.address);
  });
  // -------If this code doesn't work, to deploy the contract token sale
  // -------we have to copy the contract tokenn address and paste here
  // -------deployer.deploy(GreenTokenSale, "0xB8816EEe0365af32Bb184d81Ae529008F1597ada");
};