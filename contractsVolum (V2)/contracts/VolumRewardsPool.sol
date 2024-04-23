// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract VolumRewardsPool is Ownable {
    IERC20 public volumToken;
    uint256 public rewardsPoolBalance;

    event RewardPaid(address indexed user, uint256 rewardAmount);

    constructor(address _volumTokenAddress, address initialOwner) Ownable(initialOwner) {
        require(_volumTokenAddress != address(0), "VolumToken address cannot be zero");
        volumToken = IERC20(_volumTokenAddress);
    }

    function depositRewards(uint256 amount) external onlyOwner {
        require(volumToken.transferFrom(msg.sender, address(this), amount), "Transfer failed");
        rewardsPoolBalance += amount;
    }

    function distributeReward(address user, uint256 amount) external onlyOwner {
        require(amount <= rewardsPoolBalance, "Insufficient rewards pool balance");
        require(volumToken.transfer(user, amount), "Reward transfer failed");
        rewardsPoolBalance -= amount;
        emit RewardPaid(user, amount);
    }

    // Additional logic to automate reward distribution during the sell phase
    // could be added here, depending on the specific mechanisms of the VolumToken contract.
}
