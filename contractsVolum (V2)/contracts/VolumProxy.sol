// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Upgrade.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract VolumProxy is ERC1967Upgrade, ERC1967Proxy, Ownable {
    address public pendingImplementation;

    event NewImplementationProposed(address indexed newImplementation);
    event ImplementationUpgraded(address indexed newImplementation);

    constructor(address _logic, address _admin, bytes memory _data)
        ERC1967Proxy(_logic, _data)
        Ownable(_admin)
    {
    }

    function proposeNewImplementation(address newImplementation) public onlyOwner {
        require(newImplementation != address(0), "New implementation cannot be the zero address");
        pendingImplementation = newImplementation;
        emit NewImplementationProposed(newImplementation);
    }

    function approveNewImplementation() public onlyOwner {
        require(pendingImplementation != address(0), "No new implementation proposed");
        _upgradeTo(pendingImplementation);
        emit ImplementationUpgraded(pendingImplementation);
        pendingImplementation = address(0);
    }

    function getImplementation() public view returns (address) {
        return _getImplementation();
    }

    receive() external payable {
        // Handle incoming ether transactions
    }
}
