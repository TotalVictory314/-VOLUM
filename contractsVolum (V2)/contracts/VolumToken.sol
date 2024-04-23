// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract VolumToken is ERC20, Ownable {
    uint256 public constant INITIAL_SUPPLY = 1_000_000_000 * (10 ** 18); // Assuming 18 decimal places
    uint256 public constant BURN_RESERVOIR_ALLOCATION = 200_000_000 * (10 ** 18);
    uint256 public constant OWNER_ALLOCATION = 100_000_000 * (10 ** 18);
    uint256 public constant ICO_ALLOCATION = 300_000_000 * (10 ** 18);
    uint256 public constant MINT_CAP = 100_000_000 * (10 ** 18);
    uint256 public constant MINT_RATE = 10; // 10% of the burn amount

    uint256 public burnReservoirBalance;
    uint256 public mintedSupply;
    uint256 public burnRateOnBuy = 10; // 10% of the transaction
    uint256 public burnRateOnSell = 10; // 10% of the transaction

    event BonusTokensTransferred(address indexed recipient, uint256 amount);

    constructor() ERC20("VolumToken", "VOLUM") Ownable(msg.sender) {
        _mint(msg.sender, INITIAL_SUPPLY);
        burnReservoirBalance = BURN_RESERVOIR_ALLOCATION;
        mintedSupply = 0;
    }

    function mint(address account, uint256 amount) external {
        _mint(account, amount);
    }

    function burn(uint256 amount) internal {
        require(amount <= burnReservoirBalance, "Insufficient burn reservoir balance");
        burnReservoirBalance -= amount;
        _burn(address(this), amount);
    }

    function mintAndTransferBonusTokensBuy(address recipient, uint256 burnAmount) internal {
        uint256 bonusAmount = (burnAmount * MINT_RATE) / 100;
        require(mintedSupply + bonusAmount <= MINT_CAP, "Mint cap exceeded");
        mintedSupply += bonusAmount;
        _mint(recipient, bonusAmount);
        emit BonusTokensTransferred(recipient, bonusAmount);
    }

    function mintAndTransferBonusTokensSell(address, uint256 burnAmount) internal {
        uint256 bonusAmount = (burnAmount * MINT_RATE) / 100;
        require(mintedSupply + bonusAmount <= MINT_CAP, "Mint cap exceeded");
        mintedSupply += bonusAmount;
        _mint(owner(), bonusAmount); // Mint bonus tokens to contract owner
        emit BonusTokensTransferred(owner(), bonusAmount);
    }


    function buyTokens(uint256 amount) public payable {
        require(amount > 0, "Amount must be greater than 0");
        uint256 burnAmount = (msg.value * burnRateOnBuy) / 100;
        require(burnAmount <= burnReservoirBalance, "Insufficient burn reservoir balance");

        // Mint and transfer bonus tokens to the buyer
        mintAndTransferBonusTokensBuy(msg.sender, burnAmount);

        // Burn tokens from the burn reservoir
        burn(burnAmount);

        // Transfer tokens to the buyer
        _mint(msg.sender, amount);
    }

    function sellTokens(uint256 amount) public {
        require(amount > 0, "Amount must be greater than 0");
        uint256 burnAmount = (amount * burnRateOnSell) / 100;
        require(burnAmount <= burnReservoirBalance, "Insufficient burn reservoir balance");

        // Mint and transfer bonus tokens for sellers
        mintAndTransferBonusTokensSell(msg.sender, burnAmount);

        // Burn tokens from the seller's balance
        _burn(msg.sender, burnAmount);

        // Transfer tokens to the burn reservoir (optional if burning from seller's balance is sufficient)
        // burn(burnAmount);
    }

    // Getter function for the mint rate
    function getMintRate() public pure returns (uint256) {
        return MINT_RATE;
    }
}
