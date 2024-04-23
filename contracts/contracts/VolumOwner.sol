// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IVolumToken {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function burn(uint256 amount) external;
}

contract VolumOwner {
    IVolumToken public volumToken;
    address public owner;
    uint256 public ownerAllocation;
    uint256 public ownerBurnWalletBalance;

    // Event to emit when tokens are burned
    event TokensBurned(uint256 amount);

    // Modifier to restrict functions to only the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    constructor(address _volumTokenAddress, uint256 _ownerAllocation, uint256 _ownerBurnWallet) {
        require(_volumTokenAddress != address(0), "VolumToken address cannot be zero");
        volumToken = IVolumToken(_volumTokenAddress);
        owner = msg.sender;
        ownerAllocation = _ownerAllocation;
        ownerBurnWalletBalance = _ownerBurnWallet;
    }

    // Function for the owner to sell tokens with a 1:1 burn mechanism
    function sellOwnerTokens(uint256 amount) external onlyOwner {
        require(amount <= ownerAllocation, "Amount exceeds owner allocation");
        require(amount <= ownerBurnWalletBalance, "Burn amount exceeds owner burn wallet balance");
        
        // Burn tokens from the owner's burn wallet
        volumToken.burn(amount);
        // Update the owner's allocation and burn wallet balance
        ownerAllocation -= amount;
        ownerBurnWalletBalance -= amount;
        // Transfer the remaining tokens to the market or a specified recipient
        volumToken.transfer(owner, amount);
    }

    // Function to update the owner
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "New owner cannot be the zero address");
        owner = newOwner;
    }

    // Function to burn tokens during the buy phase
    function burnTokensDuringBuyPhase(uint256 amount) external onlyOwner {
        require(amount <= ownerBurnWalletBalance, "Insufficient balance in burn wallet");
        ownerBurnWalletBalance -= amount;
        volumToken.burn(amount);
        emit TokensBurned(amount);
    }

    // Function to burn tokens during the sell phase
    function burnTokensDuringSellPhase(uint256 amount) external onlyOwner {
        require(amount <= ownerBurnWalletBalance, "Insufficient balance in burn wallet");
        ownerBurnWalletBalance -= amount;
        volumToken.burn(amount);
        emit TokensBurned(amount);
    }
}
