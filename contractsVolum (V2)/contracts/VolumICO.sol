// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./VolumToken.sol";

contract VolumICO is ReentrancyGuard, Ownable {
    IERC20 public volumToken;
    uint256 public constant ICO_ALLOCATION = 300_000_000 * (10 ** 18);
    uint256 public constant ICO_PRICE = 1 ether; // Initial ICO price, adjustable
    uint256 public tokensSold;
    uint256 public icoEndTime;
    uint256 public burnRateOnBuy = 1; // Example burn rate of 1%, adjustable

    event TokensPurchased(address indexed purchaser, uint256 amount);

    constructor(address _volumTokenAddress, uint256 _icoDuration) Ownable(msg.sender) {
        require(_volumTokenAddress != address(0), "VolumToken address cannot be zero");
        volumToken = IERC20(_volumTokenAddress);
        icoEndTime = block.timestamp + _icoDuration;
    }

    function buyTokens() external payable nonReentrant {
        require(block.timestamp < icoEndTime, "ICO has ended");
        require(msg.value > 0, "Amount to purchase must be greater than 0");

        uint256 amountToPurchase = msg.value / ICO_PRICE;
        require(amountToPurchase > 0, "Amount to purchase must be greater than 0");
        require(tokensSold + amountToPurchase <= ICO_ALLOCATION, "ICO allocation exceeded");

        uint256 burnAmount = (amountToPurchase * burnRateOnBuy) / 100;
        require(burnAmount <= volumToken.balanceOf(address(this)), "Insufficient token balance in ICO contract");

        tokensSold += amountToPurchase;

        // Mint and transfer bonus tokens to the buyer
        VolumToken(address(volumToken)).mint(msg.sender, burnAmount);

        emit TokensPurchased(msg.sender, amountToPurchase);
    }

    function withdrawFunds() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function endIco() external onlyOwner {
        require(block.timestamp < icoEndTime, "ICO has already ended");
        icoEndTime = block.timestamp; // End the ICO immediately
    }
}
