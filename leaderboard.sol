// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Leaderboard {
    address public owner;
    uint256 public entryFee = 1 * 10**6; // 1 TRX in SUN (Tron's smallest unit)

    struct Score {
        address player;
        uint256 score;
        uint256 timestamp;
    }

    Score[] public scores;
    mapping(address => bool) public hasPlayed;

    event ScoreSubmitted(address indexed player, uint256 score, uint256 timestamp);
    event PaymentReceived(address indexed player, uint256 amount);

    constructor() {
        owner = msg.sender;
    }

    // Pay 1 TRX to play
    function payToPlay() external payable {
        require(msg.value >= entryFee, "Must send at least 1 TRX");
        require(!hasPlayed[msg.sender], "Already played this round");
        hasPlayed[msg.sender] = true;
        emit PaymentReceived(msg.sender, msg.value);
    }

    // Submit score after playing
    function submitScore(uint256 _score) external {
        require(hasPlayed[msg.sender], "Must pay to play first");
        scores.push(Score(msg.sender, _score, block.timestamp));
        emit ScoreSubmitted(msg.sender, _score, block.timestamp);
    }

    // Get top scores (e.g., top 5)
    function getTopScores(uint256 limit) external view returns (Score[] memory) {
        uint256 count = scores.length < limit ? scores.length : limit;
        Score[] memory topScores = new Score[](count);

        // Simple bubble sort (for small datasets)
        Score[] memory tempScores = scores;
        for (uint256 i = 0; i < tempScores.length; i++) {
            for (uint256 j = i + 1; j < tempScores.length; j++) {
                if (tempScores[j].score > tempScores[i].score) {
                    Score memory temp = tempScores[i];
                    tempScores[i] = tempScores[j];
                    tempScores[j] = temp;
                }
            }
        }

        for (uint256 i = 0; i < count; i++) {
            topScores[i] = tempScores[i];
        }
        return topScores;
    }

    // Withdraw funds (owner only)
    function withdraw() external {
        require(msg.sender == owner, "Only owner can withdraw");
        payable(owner).transfer(address(this).balance);
    }
}
