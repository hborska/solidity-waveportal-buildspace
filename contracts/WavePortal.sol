// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract WavePortal {
    uint256 totalWaves;
    uint256 private seed;
    bool winsPrize;

    event NewWave(address indexed from, uint256 timestamp, string message, bool isWinner);

    struct Wave {
        address waver;
        string message;
        uint256 timestamp;
        bool isWinner;
    }

    Wave[] waves;

    constructor() payable {
        console.log("We have been constructed!");
        
        //Initial seed (for randomness)
        seed = (block.timestamp + block.difficulty) % 100;
    }

    //Generating random # based on the block difficulty and timestamp 
    //NOT a good way to generate randomness since hackers could reverse engineer! 
    //Seed makes it harder but still possible to hack, but this is fine for our tiny app
    function wave(string memory _message) public {
        totalWaves += 1;
        console.log("%s has waved!", msg.sender);

        //New seed # for next user that waves
        seed = (block.difficulty + block.timestamp + seed) % 100;
        
        console.log("Random # generated: %d", seed);

        //50/50 chance the user wins the prize
        if (seed <= 50) {
            console.log("%s won!", msg.sender);
            winsPrize = true;
            waves.push(Wave(msg.sender, _message, block.timestamp, true));

            //Sending the prize ether
            uint256 prizeAmount = 0.0001 ether;
            require(
                prizeAmount <= address(this).balance,
                "Trying to withdraw more money than the contract has."
            );
            (bool success, ) = (msg.sender).call{value: prizeAmount}("");
            require(success, "Failed to withdraw money from contract.");
        } else {
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