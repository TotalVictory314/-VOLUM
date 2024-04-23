// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IVolumToken {
    function burn(uint256 amount) external;
}

contract VolumOwnerBurnWallet {
    IVolumToken public volumToken;
    address private _owner;
    uint256 private _burnWalletBalance;

    event TokensBurned(uint256 amount);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {
        require(msg.sender == _owner, "Caller is not the owner");
        _;
    }

    constructor(address tokenAddress, uint256 initialBalance) {
        require(tokenAddress != address(0), "VolumToken address cannot be the zero address");
        volumToken = IVolumToken(tokenAddress);
        _owner = msg.sender;
        _burnWalletBalance = initialBalance;
    }

    function burnTokens(uint256 amount) external onlyOwner {
        require(amount <= _burnWalletBalance, "Insufficient balance in burn wallet");
        volumToken.burn(amount);
        _burnWalletBalance -= amount;
        emit TokensBurned(amount);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New owner cannot be the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function burnWalletBalance() public view returns (uint256) {
        return _burnWalletBalance;
    }

    function owner() public view returns (address) {
        return _owner;
    }
    function burnTokensDuringBuyPhase(uint256 amount) external onlyOwner {
        require(amount <= _burnWalletBalance, "Insufficient balance in burn wallet");

        _burnWalletBalance -= amount;
        volumToken.burn(amount);
        emit TokensBurned(amount);
    }

    function burnTokensDuringSellPhase(uint256 amount) external onlyOwner {
        require(amount <= _burnWalletBalance, "Insufficient balance in burn wallet");

        _burnWalletBalance -= amount;
        volumToken.burn(amount);
        emit TokensBurned(amount);
    }
}
