// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract VolumToken is ERC20 {
    uint256 public constant INITIAL_SUPPLY = 1_000_000_000 * (10 ** 18); // Assuming 18 decimal places
    uint256 public constant BURN_RESERVOIR_ALLOCATION = 200_000_000 * (10 ** 18);
    uint256 public constant OWNER_ALLOCATION = 100_000_000 * (10 ** 18);
    uint256 public constant ICO_ALLOCATION = 300_000_000 * (10 ** 18);
    uint256 public constant MINT_CAP = 100_000_000 * (10 ** 18);

    uint256 public burnReservoirBalance;
    uint256 public mintedSupply;
    uint256 public burnRateOnBuy = 10; // 10% of the transaction
    uint256 public burnRateOnSell = 10; // 10% of the transaction
    uint256 public mintRate = 1; // 10% of the burn rate

    constructor() ERC20("VolumToken", "VOLUM") {
        _mint(msg.sender, INITIAL_SUPPLY);
        burnReservoirBalance = BURN_RESERVOIR_ALLOCATION;
        mintedSupply = 0;
    }


    function burn(uint256 amount) internal {
        require(amount <= burnReservoirBalance, "Insufficient burn reservoir balance");
        burnReservoirBalance -= amount;
        _burn(address(this), amount);
    }

    function mintBonusTokens(uint256 amount) internal {
        uint256 bonusAmount = (amount * mintRate) / 100;
        require(mintedSupply + bonusAmount <= MINT_CAP, "Mint cap exceeded");
        mintedSupply += bonusAmount;
        _mint(msg.sender, bonusAmount);
    }

function buyTokens(uint256 amount) public payable {
        require(amount > 0, "Amount must be greater than 0");
        uint256 burnAmount = (msg.value * burnRateOnBuy) / 100;
        require(burnAmount <= burnReservoirBalance, "Insufficient burn reservoir balance");
        uint256 bonusAmount = (burnAmount * mintRate) / 100;
        require(mintedSupply + bonusAmount <= MINT_CAP, "Mint cap exceeded");

        _burn(address(this), burnAmount);
        burnReservoirBalance -= burnAmount;
        mintedSupply += bonusAmount;
        _mint(msg.sender, amount + bonusAmount);
    }

    function sellTokens(uint256 amount) public {
        require(amount > 0, "Amount must be greater than 0");
        uint256 burnAmount = (amount * burnRateOnSell) / 100;
        require(burnAmount <= burnReservoirBalance, "Insufficient burn reservoir balance");

        _burn(msg.sender, burnAmount);
        burnReservoirBalance -= burnAmount;
    }
}
