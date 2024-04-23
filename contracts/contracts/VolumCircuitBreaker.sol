// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract VolumCircuitBreaker is Pausable, Ownable {
    event CircuitBreakerPaused(address account);

    constructor(address initialOwner) Ownable(initialOwner) {}

    function pauseContract() external onlyOwner {
        _pause();
        emit CircuitBreakerPaused(msg.sender);
    }

    function resumeContract() external onlyOwner {
        _unpause();
    }
}

