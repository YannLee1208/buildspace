[Mint your own NFT collection and ship a Web3 app to show them off](https://buildspace.so/p/mint-nft-collection)

NFT example:

1. The buyer can prove that the NFT collection was originally signed and created by Picasso himself because the **NFT would show that it came from a smart contract signed by Picasso**. Remember, **Picasso signed the collection with his public address**! Usually, artists publicly announce their wallet address so no one can pretend to be them!
2. The buyer can prove that the NFT itself is a **unique** Picasso sketch from the collection because **each NFT from the collection has a unique identifier** (ex. Sketch #1, Sketch #2, Sketch #3, etc) that comes from the person who originally created the collection.



# **🦊 MINT YOUR FIRST NFT**

## 🤖 Get your local environment up and running

```shell
yarn init
yarn add hardhat
yarn hardhat
yarn add @nomiclabs/hardhat-waffle ethereum-waffle chai @nomiclabs/hardhat-ethers ethers -D
yarn add @openzeppelin/contracts

```

## **💎 Create a contract that mints NFTs**

```solidity
// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.1;

// We first import some OpenZeppelin Contracts.
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

// We inherit the contract we imported. This means we'll have access
// to the inherited contract's methods.
contract MyEpicNFT is ERC721URIStorage {
  // Magic given to us by OpenZeppelin to help us keep track of tokenIds.
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  // We need to pass the name of our NFTs token and its symbol.
  constructor() ERC721 ("SquareNFT", "SQUARE") {
    console.log("This is my NFT contract. Woah!");
  }

  // A function our user will hit to get their NFT.
  function makeAnEpicNFT() public {
     // Get the current tokenId, this starts at 0.
    uint256 newItemId = _tokenIds.current();

     // Actually mint the NFT to the sender using msg.sender.
    _safeMint(msg.sender, newItemId);

    // Set the NFTs data.
    _setTokenURI(newItemId, "blah");

    // Increment the counter for when the next NFT is minted.
    _tokenIds.increment();
  }
}
```

**add tokenURI**

> The `tokenURI` is where the actual NFT data lives. And it usually **links** to a JSON file called the `metadata` that looks something like this:
>
> ```bash
> {
>     "name": "Spongebob Cowboy Pants",
>     "description": "A silent hero. A watchful protector.",
>     "image": "https://i.imgur.com/v7U019j.png"
> }
> ```
>
> We can copy the `Spongebob Cowboy Pants` JSON metadata above and paste it into [this](https://jsonkeeper.com/?utm_source=buildspace.so&utm_medium=buildspace_project) website. This website is just an easy place for people to host JSON data
>
> For me, I push tokenURI json file in GitHub https://github.com/YannLee1208/buildspace/blob/master/resources/1.json

`_setTokenURI(newItemId, "https://github.com/YannLee1208/buildspace/blob/master/resources/1.json");`



**deploy**

```js
const main = async () => {
  const nftContractFactory = await hre.ethers.getContractFactory('MyEpicNFT');
  const nftContract = await nftContractFactory.deploy();
  await nftContract.deployed();
  console.log("Contract deployed to:", nftContract.address);

  // Call the function.
  let txn = await nftContract.makeAnEpicNFT()
  // Wait for it to be mined.
  await txn.wait()

  // Mint another NFT for fun.
  txn = await nftContract.makeAnEpicNFT()
  // Wait for it to be mined.
  await txn.wait()

};

const runMain = async () => {
  try {
    await main();
    process.exit(0);
  } catch (error) {
    console.log(error);
    process.exit(1);
  }
};

runMain();
```

==every time someone mints an NFT with this function, it's always the same NFT==



##  Deploy to Rinkeby and see on OpenSea

==what's transaction==

When we want to perform an action that changes the blockchain we call it a *transaction*

* sending someone ETH 
* updates a variable in our contract
* Minting an NFT is a transaction because we're saving data on the contract.

==deploy to rinkeby==

> use QuickNode  + Rinkeby

set `hardhat.config.js`

```js
require('@nomiclabs/hardhat-waffle');
require("dotenv").config({ path: ".env" });

module.exports = {
  solidity: '0.8.1',
  networks: {
    rinkeby: {
      url: process.env.QUICKNODE_API_KEY_URL,
      accounts: [process.env.RINKEBY_PRIVATE_KEY],
    },
  },
};
```

