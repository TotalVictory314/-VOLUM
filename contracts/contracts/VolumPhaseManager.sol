// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VolumPhaseManager {
    enum Phase { Buy, Sell }
    Phase public currentPhase;
    uint256 public lastPhaseShiftTimestamp;
    uint256 public constant PHASE_DURATION = 1 days;

    event PhaseShifted(Phase newPhase);

    constructor() {
        currentPhase = Phase.Buy; // Start with the Buy phase
        lastPhaseShiftTimestamp = block.timestamp;
    }

    function getCurrentPhase() public view returns (Phase) {
        if (block.timestamp >= lastPhaseShiftTimestamp + PHASE_DURATION) {
            return (currentPhase == Phase.Buy) ? Phase.Sell : Phase.Buy;
        }
        return currentPhase;
    }

    function shiftPhase() external {
        require(block.timestamp >= lastPhaseShiftTimestamp + PHASE_DURATION, "Cannot shift phase yet");
        currentPhase = (currentPhase == Phase.Buy) ? Phase.Sell : Phase.Buy;
        lastPhaseShiftTimestamp = block.timestamp;
        emit PhaseShifted(currentPhase);
    }

    // Additional functions to integrate with the VolumToken contract for applying phase-based incentives
    // would be added here, depending on the specific mechanisms of the VolumToken contract.
}

