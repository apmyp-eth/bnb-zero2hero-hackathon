require("@nomicfoundation/hardhat-toolbox");
require("@nomiclabs/hardhat-etherscan");
require("dotenv").config();
require("solidity-coverage");
require("hardhat-gas-reporter");
require("./tasks");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.17",
  networks: {
    /* README: https://hardhat.org/hardhat-network/docs/metamask-issue */
    hardhat: {
      chainId: 1337
    },
    bnbt: {
      //url: `https://rpc.ankr.com/bsc_testnet_chapel`,
      url: 'https://data-seed-prebsc-1-s1.binance.org:8545',
      accounts: [process.env.PRIVATE_KEY]
    }
  },
  etherscan: {
    apiKey: `${process.env.BSCSCAN_API_KEY}`
  },
  gasReporter: {
    enabled: (process.env.REPORT_GAS) ? true : false,
  }
};
