// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract WavePortal {
    uint256 totalWaves;
    uint256 private seed;
    bool winsPrize;

    event NewWave(address indexed from, uint256 timestamp, string message, bool winsPrize);

    struct Wave {
        address waver;
        string message;
        uint256 timestamp;
        bool isWinner;
    }

    //Array of our waves
    Wave[] waves;
    //Mapping address of wallet to time to prevent spamming
    mapping(address => uint256) public lastWavedAt;

    constructor() payable {
        console.log("We have been constructed!");
        //Initial seed (for randomness)
        seed = (block.timestamp + block.difficulty) % 100;
    }

    function wave(string memory _message) public {
        //Preventing spamming (15 minute cooldown), require last waved to be > 15 mins
        require(
            lastWavedAt[msg.sender] + 15 minutes < block.timestamp,
            "Wait 15m"
        );

        //Update timestamp
        lastWavedAt[msg.sender] = block.timestamp;

        totalWaves += 1;
        console.log("%s has waved!", msg.sender);


        seed = (block.difficulty + block.timestamp + seed) % 100;

        //The user wins the prize money
        if (seed <= 50) {
            winsPrize = true;
            waves.push(Wave(msg.sender, _message, block.timestamp, true));

            console.log("%s won!", msg.sender);

            uint256 prizeAmount = 0.0001 ether;
            require(
                prizeAmount <= address(this).balance,
                "Trying to withdraw more money than they contract has."
            );
            (bool success, ) = (msg.sender).call{value: prizeAmount}("");
            require(success, "Failed to withdraw money from contract.");
        }
        //User does not win the prize money 
        else {
            winsPrize = false;
            waves.push(Wave(msg.sender, _message, block.timestamp, false));
        }

        emit NewWave(msg.sender, block.timestamp, _message, winsPrize);
    }

    function getAllWaves() public view returns (Wave[] memory) {
        return waves;
    }

    function getTotalWaves() public view returns (uint256) {
        return totalWaves;
    }
}