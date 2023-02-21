// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

/** THIS IS V1 **/

contract RSPier2 is VRFConsumerBase {
    //event RequestFulfilled(bytes32 requestId, uint256 randomness);

    bytes32 internal keyHash;
    uint256 internal fee;

    uint256 public randomResult;
    uint256 public gameId; 
    uint256 public lastGameId;
    address payable public owner;

    enum Choice {
        Empty,
        Rock, 
        Paper, 
        Scissor
    }
    
    Choice public userChoice = Choice.Empty;
    Choice public botChoice = Choice.Empty;

    bool gameEnded = false;

    mapping(address=>uint) public balances;

    function resetAll() public {
        require(gameEnded);
        userChoice = Choice.Empty;
        botChoice = Choice.Empty;
        gameEnded = false;
    }

    constructor()
        VRFConsumerBase(
            0xa555fC018435bef5A13C6c6870a9d4C11DEC329C, // VRF Coordinator
            0x84b9B910527Ad5C03A9Ca831909E21e236EA7b06 // LINK Token
        )
    {
        keyHash = 0xcaf3c3727e033261d383b315559476f48034c13b18f8cafed4d871abe5049186;
        fee = 0.1 * 10 ** 18; // 0.1 LINK (Varies by network)
        owner = payable(msg.sender);
    }


    // check the result
    function getResult() public {
        require(!gameEnded, "can only compute result once");
        require(userChoice != Choice.Empty && botChoice != Choice.Empty, "someone did not reveal their choice");

        bool winner = false;
        
        // draw
        if (userChoice == botChoice) {
            // user : bot
        } else if (userChoice == Choice.Rock) {
            if (botChoice == Choice.Paper) {
                // user: rock, bot: paper, bot win
                winner = false;
            } else {
                // user: rock, bot: scissor, user win
                winner = true;
            }
        } else if (userChoice == Choice.Paper) {
            if (botChoice == Choice.Scissor) {
                // user: paper, bot: scissor, bot win
                winner = false;
            } else {
                // user: paper, bot: rock, user win
                winner = true;
            }
        } else if (userChoice == Choice.Scissor) {
            if (botChoice == Choice.Rock) {
                // user: scissor, bot: rock, bot win
                winner = false;
            } else {
                // user: scissor, bot: paper, user win
                winner = true;
            }
        }

        if (winner) {
            payable(msg.sender).transfer(msg.value*2);
            return true;
        }
        
        return false;
        gameEnded = true;
    }

    //function compareStrings(string memory a, string memory b) public pure returns(bool) {
    //    return(keccak256(abi.encodePacked((a))) == abi.encodePacked((b)));
    //}

    /**
     * Requests randomness
     */
    function getRandomNumber() public returns (bytes32 requestId) {
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");
        return requestRandomness(keyHash, fee);
    }

    /**
     * Callback function used by VRF Coordinator
     */
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        randomResult = (randomness < 0 % 4);
        //emit RequestFulfilled(requestId, randomness);
    }

    function playGame() public returns(uint256) {
        for(uint i=lastGameId; i < gameId; i++) {

            theGame();

            Games[i] = Game(i, Games[i].bet, Games[i].amount, Games[i].player, randomResult);

            emit Result(i, Games[i].bet, winAmount, Games[i].player, randomResult);
        }

        lastGameId = gameId;

        return lastGameId;
    }



    function WithdrawIncome(uint256 amount) public {
        require(address(this).balance >= amount, "Funds not enought");
        owner.transfer(amount);

        emit WithdrawIncome(owner, amount);
    }

    // function withdrawLink() external {} - Implement a withdraw function to avoid locking your LINK in the contract
}