# Create contract

## env

```shell
npm init -y
npm install --save-dev hardhat@2.9.9 # yarn add -D hardhat@2.9.9

npx hardhat 
# Create a basic sample project. choose yes to install the following dependencies
# npm install --save-dev @nomiclabs/hardhat-waffle ethereum-waffle chai @nomiclabs/hardhat-ethers ethers

npx hardhat compile
npx hardhat test
```



## Write your first smart contract in Solidity

contract file

```solidity
// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract WavePortal {
    constructor() {
        console.log("Yo yo, I am a contract and I am smart");
    }
}
```

Deploy file `run.js`

==what's hre?==

​	**Hardhat is the HRE.** Every time you run a terminal command that starts with `npx hardhat` you are getting this `hre` object built on the fly using the `hardhat.config.js` specified in your code! This means you will **never** have to actually do some sort of import into your files like: `const hre = require("hardhat")`

```js
const main = async () => {
  const waveContractFactory = await hre.ethers.getContractFactory("WavePortal");
  const waveContract = await waveContractFactory.deploy();
  await waveContract.deployed();
  console.log("Contract deployed to:", waveContract.address);
};

const runMain = async () => {
  try {
    await main();
    process.exit(0); // exit Node process without error
  } catch (error) {
    console.log(error);
    process.exit(1); // exit Node process while indicating 'Uncaught Fatal Exception' error
  }
  // Read more about Node exit ('process.exit(num)') status codes here: https://stackoverflow.com/a/47163396/7974948
};

runMain();
```

==note==

* ==Hardhat will create a local Ethereum network for us, but just for this contract. Then, after the script completes it'll destroy that local network.==

* Our `constructor` runs when we actually deploy(`contract.deployed()`).

Finally:

​	`yarn hardhat run scripts/run.js`



## **Store 👋 data on our smart contract**

contract

```solidity
// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract WavePortal {
    uint256 totalWaves;

    constructor() {
        console.log("Yo yo, I am a contract and I am smart");
    }

    function wave() public{
        totalWaves += 1;
        console.log("%s has waved", msg.sender);
    }

    function getWaves() public view returns (uint256){
        console.log("We have waved %d times", totalWaves);
        return totalWaves;
    }
}
```

==what's msg.sender?==

​	`msg.sender`. This is the wallet address of the person who called the function. It's like built-in authentication. We know exactly who called the function because in order to even call a smart contract function, you need to be connected with a valid wallet!

`run.js`

```js
const main = async () => {
  const [owner, randomPerson] = await hre.ethers.getSigners();
  const waveContractFactory = await hre.ethers.getContractFactory("WavePortal");
  const waveContract = await waveContractFactory.deploy();
  await waveContract.deployed();

  console.log("Contract deployed to:", waveContract.address);
  console.log("Contract deployed by:", owner.address);

  let waveCount;
  waveCount = await waveContract.getTotalWaves();

  let waveTxn = await waveContract.wave();
  await waveTxn.wait();

  waveCount = await waveContract.getTotalWaves();
    
  waveTxn = await waveContract.connect(randomPerson).wave();
  await waveTxn.wait();

  waveCount = await waveContract.getTotalWaves();
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



==what's owner?==

​	In order to deploy something to the blockchain, we need to have a wallet address! Hardhat does this for us magically in the **background**, but here I grabbed the wallet address of contract owner and I also grabbed a random wallet address and called it `randomPerson`. This will make more sense in a moment.

==What's final output?==

Actually, `randomPerson` calls the same contract as the `owner` (not a new one), so the result is `2`



## D**eploy locally so we can start building the website**

==how does the run.js work before?==

1. Creating a new local Ethereum network.
2. Deploying your contract.
3. Then, when the script ends Hardhat will automatically **destroy** that local network.

==how to create a alive local network==

`yarn hardhat node`



==run2.js==

```js
const main = async () => {
    const [deployer] = await hre.ethers.getSigners();
    const accountBalance = await deployer.getBalance();
  
    console.log("Deploying contracts with account: ", deployer.address);
    console.log("Account balance: ", accountBalance.toString());
  
    const waveContractFactory = await hre.ethers.getContractFactory("WavePortal");
    const waveContract = await waveContractFactory.deploy();
    await waveContract.deployed();
  
    console.log("WavePortal address: ", waveContract.address);
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

==run==

`yarn hardhat run scripts/run2.js --network localhost`





# Connect to a wallet

## Replit（WebApp）

We'll be using [Replit](https://replit.com/~?utm_source=buildspace.so&utm_medium=buildspace_project)! It is a browser-based IDE that lets us easily build web apps and deploy them all from the browser.

**Just go [here](https://replit.com/@adilanchian/waveportal-starter-project?v=1?utm_source=buildspace.so&utm_medium=buildspace_project), and near the right you'll see the "Fork" button.**



## Real testnet （chain）

Now we're going to be doing the real deal, deploying to the actual blockchain.

Go ahead and make an account with **QuickNode** [here](https://www.quicknode.com/?utm_source=buildspace&utm_campaign=generic&utm_content=sign-up&utm_medium=buildspace).

* QuickNode essentially helps us broadcast our contract creation transaction so that it can be picked up by miners as quickly as possible

==QuickNode==

create an endpoint -> ethereum -> Rinkeby -> get HTTP Provider

==Rinkeby==

load `https://faucets.chain.link/rinkeby` to fetch 0.1 Rinkeby Eth



## deploy

1. use `dotenv` to set up configurations.

install : `yarn add dotenv `

`.env` file 

```shell
STAGING_QUICKNODE_KEY=REPLACE_WITH_ACTUAL_QUICKNODE_URL
PROD_QUICKNODE_KEY=BLAHBLAH
PRIVATE_KEY=BLAHBLAH
```

2. change `hardhat.config.js`

```js
require("@nomiclabs/hardhat-waffle");
// Import and configure dotenv
require("dotenv").config();

module.exports = {
  solidity: "0.8.0",
  networks: {
    rinkeby: {
      // This value will be replaced on runtime
      url: process.env.STAGING_QUICKNODE_KEY,
      accounts: [process.env.PRIVATE_KEY],
    },
    mainnet: {
      chainId: 1,
      url: process.env.PROD_QUICKNODE_KEY,
      accounts: [process.env.PRIVATE_KEY],
    },
  },
};
```

3. deploy

`yarn hardhat run scripts/run-local.js --network rinkeby`







## **Connect our wallet to our web app**

==window.ethereum==

If we're logged in to Metamask, it will automatically inject a special object named `ethereum` into our window.

```tsx
import React, { useEffect, useState } from "react";
import "./App.css";

const App = () => {
  const [currentAccount, setCurrentAccount] = useState("");

  const checkIfWalletIsConnected = async () => {
    try {
      const { ethereum } = window;

	  // check if there is window.ethereum
      if (!ethereum) {
        console.log("Make sure you have metamask!");
        return;
      } else {
        console.log("We have the ethereum object", ethereum);
      }

	  // connect to metamask
      const accounts = await ethereum.request({ method: "eth_accounts" });

      if (accounts.length !== 0) {
        const account = accounts[0];
        console.log("Found an authorized account:", account);
        setCurrentAccount(account);
      } else {
        console.log("No authorized account found")
      }
    } catch (error) {
      console.log(error);
    }
  }

  /**
  * Implement your connectWallet method here
  */
  const connectWallet = async () => {
    try {
      const { ethereum } = window;

      if (!ethereum) {
        alert("Get MetaMask!");
        return;
      }

      // connect to metamask
      const accounts = await ethereum.request({ method: "eth_requestAccounts" });

      console.log("Connected", accounts[0]);
      setCurrentAccount(accounts[0]);
    } catch (error) {
      console.log(error)
    }
  }

  useEffect(() => {
    checkIfWalletIsConnected();
  }, [])

  return (
    <div className="mainContainer">
      <div className="dataContainer">
        <div className="header">
        👋 Hey there!
        </div>

        <div className="bio">
          I am farza and I worked on self-driving cars so that's pretty cool right? Connect your Ethereum wallet and wave at me!
        </div>

        <button className="waveButton" onClick={null}>
          Wave at Me
        </button>

        {/*
        * If there is no currentAccount render this button
        */}
        {!currentAccount && (
          <button className="waveButton" onClick={connectWallet}>
            Connect Wallet
          </button>
        )}
      </div>
    </div>
  );
}

export default App
```

==connect==

`const accounts = await ethereum.request({ method: "eth_requestAccounts" });`



## Call the deployed smart contract from our web app



```jsx
import React, { useEffect, useState } from "react";
import "./App.css";
import {ethers} from "ethers";
import abi from "../utils/WavePortal.json";

const App = () => {
  const [currentAccount, setCurrentAccount] = useState("");

  const contractAddress = "0x56a3C32a5B872Adb7b6284238608a0927eEC3CA0";
  const contractABI = abi.abi;
  
  const checkIfWalletIsConnected = async () => {
    try {
      const { ethereum } = window;

      if (!ethereum) {
        console.log("Make sure you have metamask!");
        return;
      } else {
        console.log("We have the ethereum object", ethereum);
      }

      const accounts = await ethereum.request({ method: "eth_accounts" });

      if (accounts.length !== 0) {
        const account = accounts[0];
        console.log("Found an authorized account:", account);
        setCurrentAccount(account);
      } else {
        console.log("No authorized account found")
      }
    } catch (error) {
      console.log(error);
    }
  }

  /**
  * Implement your connectWallet method here
  */
  const connectWallet = async () => {
    try {
      const { ethereum } = window;

      if (!ethereum) {
        alert("Get MetaMask!");
        return;
      }

      const accounts = await ethereum.request({ method: "eth_requestAccounts" });

      console.log("Connected", accounts[0]);
      setCurrentAccount(accounts[0]);
    } catch (error) {
      console.log(error)
    }
  }


  const wave = async() => {
    try{
      const {ethereum} = window;

      if (ethereum){
        const provider = new ethers.providers.Web3Provider(window.ethereum)
        const signer = provider.getSigner()
        const wavePortalContract = new ethers.Contract(contractAddress, contractABI, signer);
        // await wavePortalContract.wave();
        let count = await wavePortalContract.getTotalWaves();
        console.log("Retrieved total wave count...", count.toNumber());
      } 
      else
      {
        console.log("Ethereum object doesn't exist!");
      }
    }
    catch (error)
    {
      console.log(error);
    }
  }

  const disconnect = async () => {
    console.log("DisConnect");
    setCurrentAccount("");
  }
  

  useEffect(() => {
    checkIfWalletIsConnected();
  }, [])

  return (
    <div className="mainContainer">
      <div className="dataContainer">
        <div className="header">
        👋 Hey there!
        </div>

        <div className="bio">
          I am farza and I worked on self-driving cars so that's pretty cool right? Connect your Ethereum wallet and wave at me!
        </div>

        <button className="waveButton" onClick={wave}>
          Wave at Me
        </button>

        {/*
        * If there is no currentAccount render this button
        */}
        {!currentAccount && (
          <button className="waveButton" onClick={connectWallet}>
            Connect Wallet
          </button>
        )}

        {currentAccount && (
          <button className="waveButton" onClick={disconnect}>
            Disconnect
          </button>
        )
          
        }
      </div>
    </div>
  );
}

export default App
```

==Connect Contract==

```jsx
const provider = new ethers.providers.Web3Provider(window.ethereum)
const signer = provider.getSigner()
const wavePortalContract = new ethers.Contract(contractAddress, contractABI, signer);
// await wavePortalContract.wave();
let count = await wavePortalContract.getTotalWaves();
console.log("Retrieved total wave count...", count.toNumber());
```

==what's contractABI and contractAddress?==

* `contractAddress` : in session `deploy` we get the address of the contract in Rinkeby network
* `contractABI` : after compilation of the contract , we get the `artifacts/contracts/contract.json` which contains the abi

==if we use wavePortalContract.wave()==

it need to change the parameters of the contract , so it takes the gas fee. Metamask will ask the approval.



# ****INTERACT WITH CONTRACT****

==What to do==

1. Let users submit a message along with their wave.
2.  Have that data saved somehow on the blockchain.
3. Show that data on our site so anyone can come to see all the people who have waved at us and their messages.



## using arrays of structs

```solidity
// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract WavePortal {
    uint256 totalWaves;

    /*
     * A little magic, Google what events are in Solidity!
     */
    event NewWave(address indexed from, uint256 timestamp, string message);

    /*
     * I created a struct here named Wave.
     * A struct is basically a custom datatype where we can customize what we want to hold inside it.
     */
    struct Wave {
        address waver; // The address of the user who waved.
        string message; // The message the user sent.
        uint256 timestamp; // The timestamp when the user waved.
    }

    /*
     * I declare a variable waves that lets me store an array of structs.
     * This is what lets me hold all the waves anyone ever sends to me!
     */
    Wave[] waves;

    constructor() {
        console.log("I AM SMART CONTRACT. POG.");
    }

    /*
     * You'll notice I changed the wave function a little here as well and
     * now it requires a string called _message. This is the message our user
     * sends us from the frontend!
     */
    function wave(string memory _message) public {
        totalWaves += 1;
        console.log("%s waved w/ message %s", msg.sender, _message);

        /*
         * This is where I actually store the wave data in the array.
         */
        waves.push(Wave(msg.sender, _message, block.timestamp));

        /*
         * I added some fanciness here, Google it and try to figure out what it is!
         * Let me know what you learn in #general-chill-chat
         */
        emit NewWave(msg.sender, block.timestamp, _message);
    }

    /*
     * I added a function getAllWaves which will return the struct array, waves, to us.
     * This will make it easy to retrieve the waves from our website!
     */
    function getAllWaves() public view returns (Wave[] memory) {
        return waves;
    }

    function getTotalWaves() public view returns (uint256) {
        // Optional: Add this line if you want to see the contract print the value!
        // We'll also print it over in run.js as well.
        console.log("We have %d total waves!", totalWaves);
        return totalWaves;
    }
}
```

==whats memory?==

* Much like RAM, **Memory** in Solidity is a temporary place to store data whereas **Storage** holds data between function calls.

*  The Solidity Smart Contract can use any amount of memory during the execution but **once the execution stops, the Memory is completely wiped off for the next execution**. Whereas Storage on the other hand is **persistent**, each execution of the Smart contract has access to the data previously stored on the storage area.
* The Gas consumption of Memory is not very significant as compared to the gas consumption of Storage. Therefore, it is always better to use Memory for intermediate calculations and store the final result in Storage.

1. **State variables** and **Local Variables of structs, array** are always stored in storage by default.
2. Function arguments are in memory.
3. Whenever a new instance of an array is created using the keyword ‘memory’, a new copy of that variable is created. Changing the array value of the new instance does not affect the original array.

==What's NewWave==

Used to listen.

==What's indexed==

Used to filter the event (only parameter with indexed can be used to filter). An event has atmost 3 indexed parameters.



## update js

`run-part3.js`

```js
const main = async () => {
  const waveContractFactory = await hre.ethers.getContractFactory("WavePortal");
  const waveContract = await waveContractFactory.deploy();
  await waveContract.deployed();
  console.log("Contract addy:", waveContract.address);

  let waveCount;
  waveCount = await waveContract.getTotalWaves();
  console.log(waveCount.toNumber());

  /**
   * Let's send a few waves!
   */
  let waveTxn = await waveContract.wave("A message!");
  await waveTxn.wait(); // Wait for the transaction to be mined

  const [_, randomPerson] = await hre.ethers.getSigners();
  waveTxn = await waveContract.connect(randomPerson).wave("Another message!");
  await waveTxn.wait(); // Wait for the transaction to be mined

  let allWaves = await waveContract.getAllWaves();
  console.log(allWaves);
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



## Redeploy

So, now that we've updated our contract we need to do a few things:

1. We need to deploy it again.

2. We need to update the contract address on our frontend.

3. We need to update the abi file on our frontend. 





## **Fund contract, set a prize, and send users Ethereum**

`contract.sol`

```solidity
    function wave(string memory _message) public{
        totalWaves += 1;
        console.log("%s has waved message %s", msg.sender, _message);

        // store the data
        waves.push( Wave( msg.sender, _message, block.timestamp ));
        
        emit NewWave(msg.sender, block.timestamp, _message);

        uint256 prizeAmount = 0.00001 ether;
        require(
            prizeAmount < address(this).balance,
            "Try to withdraw more money than the contract has."
        );

        (bool success, ) = (msg.sender).call{ value : prizeAmount}("");
        require(success,
            "fail to withdraw"
        );
    }
```

`run-withdraw.js`

```js
const main = async () => {
    const WaveContractFactory = await hre.ethers.getContractFactory("WavePortal")
    const waveContract = await WaveContractFactory.depoly({
        value : hre.ethers.utils.parseEther("0.1")
    })

    await waveContract.depolyed()
    console.log("Contract addy:", waveContract.address);

    /*
     * Get Contract balance
     */
    let contractBalance = await hre.ethers.provider.getBalance(
      waveContract.address
    );
    console.log(
      "Contract balance:",
      hre.ethers.utils.formatEther(contractBalance)
    );


    /*
    * Send Wave
    */
    let waveTxn = await waveContract.wave("A message!");
    await waveTxn.wait();

     /*
    * Get Contract balance to see what happened!
    */
    contractBalance = await hre.ethers.provider.getBalance(waveContract.address);
    console.log(
        "Contract balance:",
        hre.ethers.utils.formatEther(contractBalance)
    );

    let allWaves = await waveContract.getAllWaves();
    console.log(allWaves);
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



==Error:== non-payable constructor cannot override value

What this is saying is, our contract isn't allowed to pay people right now! This is quick fix, we need to add the keyword `payable` to our constructor in `WavePortal.sol`. Check it out:

```solidity
constructor() payable {
  console.log("We have been constructed!");
}
```



==Fund the Contract==

```js
const waveContract = await waveContractFactory.deploy({
    value: hre.ethers.utils.parseEther("0.001"),
});
```

Here the account who deploy this contract need to fund 0.001 eth. So make sure your account has that money





# **POLISH UI AND DEPLOY**

## **Randomly pick a winner **

On the blockchain, there is **nearly no source of randomness**. Everything the contract sees, the public sees. Because of that, someone could game the system by just looking at the smart contract, seeing what #s it relies on for randomness, and then the person could give it the exact numbers they need to win.

```solidity
contract WavePortal {
    uint256 totalWaves;
    // define the seed
    uint256 private seed; 

    event NewWave(address indexed from, uint256 timestamp, string message);

    constructor() payable {
        console.log("Yo yo, I am a contract and I am smart");
        seed = (block.difficulty + block.timestamp) % 100;
    }
    
        function wave(string memory _message) public{
        totalWaves += 1;
        console.log("%s has waved message %s", msg.sender, _message);

        // store the data
        waves.push( Wave( msg.sender, _message, block.timestamp ));

        /*
         * Generate a new seed for the next user that sends a wave
         */
        seed = (block.difficulty + block.timestamp + seed) % 100;

        console.log("Random # generated: %d", seed);

		// only winer gets the prize.
        if (seed < 50) {
            console.log("%s won!", msg.sender);

            /*
             * The same code we had before to send the prize.
             */
            uint256 prizeAmount = 0.0001 ether;
            require(
                prizeAmount <= address(this).balance,
                "Trying to withdraw more money than the contract has."
            );
            (bool success, ) = (msg.sender).call{value: prizeAmount}("");
            require(success, "Failed to withdraw money from contract.");
        }

        emit NewWave(msg.sender, block.timestamp, _message);
    }
```



## Cooldowns to prevent spammers

it might be useful to add a cooldown function to your site so people can't just spam wave at you. Why? Well, maybe you just don't want them to keep on trying to win the prize over and over by waving at you. Or, maybe you don't want *just* *their* messages filling up your wall of messages.



```solidity
mapping(address => uint256) public lastWaveAt;

function wave(string memory _message) public{
/*
* We need to make sure the current timestamp is at least 15-minutes bigger than the last timestamp we stored
*/
    require(
        lastWaveAt[msg.sender] + 15 minutes < block.timestamp,
        "Wait 15m"
    );

    /*
    * Update the current timestamp we have for the user
    */
    lastWaveAt[msg.sender] = block.timestamp;
```



# Bugs

* `const waveContract = await WaveContractFactory.depoly()` await is necessary

* In Replit, to see the results of console, you need to open in another tab.

  