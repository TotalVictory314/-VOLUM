// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IVolumToken {
    function burn(uint256 amount) external;
}

contract VolumBurnReservoir {
    IVolumToken public volumToken;
    uint256 public constant BURN_RATE = 10; // 10% of the transaction

    // The address of the VolumToken contract
    constructor(address _volumTokenAddress) {
        require(_volumTokenAddress != address(0), "VolumToken address cannot be zero");
        volumToken = IVolumToken(_volumTokenAddress);
    }

    // Burns tokens on buy transactions
    function burnOnBuy(uint256 transactionAmount) external {
        uint256 burnAmount = (transactionAmount * BURN_RATE) / 100;
        volumToken.burn(burnAmount);
    }

    // Burns tokens on sell transactions
    function burnOnSell(uint256 transactionAmount) external {
        uint256 burnAmount = (transactionAmount * BURN_RATE) / 100;
        volumToken.burn(burnAmount);
    }
}
