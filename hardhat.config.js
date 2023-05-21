require("@nomicfoundation/hardhat-foundry");
require("@nomiclabs/hardhat-ethers");
require('dotenv').config();
/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.18",
  networks: {
    hardhat: {
      forking: {
        url: process.env.OPTIMISM_RPC
      }
    },
    fork: {
      url: process.env.OPTIMISM_RPC
    }
  }
};
