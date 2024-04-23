// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Import the VolumToken contract
import "./VolumToken.sol";

contract VolumPhaseManager {
    enum Phase { Buy, Sell }
    Phase public currentPhase;

    // Address of the VolumToken contract
    address public volumTokenAddress;

    constructor(address _volumTokenAddress) {
        require(_volumTokenAddress != address(0), "VolumToken address cannot be zero");
        volumTokenAddress = _volumTokenAddress;
    }

    // Function to set the current phase
    function setCurrentPhase(Phase _phase) external {
        currentPhase = _phase;
    }
    
    // Function to mint and transfer bonus tokens during buy transactions
    function mintAndTransferBonusTokensBuy(address recipient, uint256 amount) external {
        require(volumTokenAddress != address(0), "VolumToken address not set");
        require(currentPhase == Phase.Buy, "Can only mint bonus tokens during Buy phase");

        VolumToken volumToken = VolumToken(volumTokenAddress);
        uint256 bonusAmount = (amount * volumToken.getMintRate()) / 100;
        volumToken.mint(recipient, bonusAmount);
    }

    // Function to mint and transfer bonus tokens during sell transactions
    function mintAndTransferBonusTokensSell(address recipient, uint256 amount) external {
        require(volumTokenAddress != address(0), "VolumToken address not set");
        require(currentPhase == Phase.Sell, "Can only mint bonus tokens during Sell phase");

        VolumToken volumToken = VolumToken(volumTokenAddress);
        uint256 bonusAmount = (amount * volumToken.getMintRate()) / 100;
        volumToken.mint(recipient, bonusAmount);
    }
}
