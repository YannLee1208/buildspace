// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract WavePortal {
    uint256 totalWaves;
    uint256 private seed;

    event NewWave(address indexed from, uint256 timestamp, string message);

    constructor() payable {
        console.log("Yo yo, I am a contract and I am smart");

        seed = (block.difficulty + block.timestamp) % 100;
    }

    struct Wave{
        address waver;
        string message;
        uint256 timestamp;
    }

    Wave[] waves;

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


        totalWaves += 1;
        console.log("%s has waved message %s", msg.sender, _message);

        // store the data
        waves.push( Wave( msg.sender, _message, block.timestamp ));

        /*
         * Generate a new seed for the next user that sends a wave
         */
        seed = (block.difficulty + block.timestamp + seed) % 100;

        console.log("Random # generated: %d", seed);

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

        // uint256 prizeAmount = 0.00001 ether;
        // require(
        //     prizeAmount < address(this).balance,
        //     "Try to withdraw more money than the contract has."
        // );

        // (bool success, ) = (msg.sender).call{ value : prizeAmount}("");
        // require(success,
        //     "fail to withdraw"
        // );
    }

    function getAllWaves() public view returns (Wave[] memory){
        return waves;
    }

    function getTotalWaves() public view returns (uint256){
        console.log("We have waved %d times", totalWaves);
        return totalWaves;
    }


}