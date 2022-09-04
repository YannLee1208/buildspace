require('@nomiclabs/hardhat-waffle');
require("dotenv").config({ path: ".env" });

module.exports = {
  solidity: '0.8.1',
  networks: {
    rinkeby: {
      chainId: 4, 
      url: process.env.QUICKNODE_API_KEY_URL,
      accounts: [process.env.RINKEBY_PRIVATE_KEY],
    },
  },
};