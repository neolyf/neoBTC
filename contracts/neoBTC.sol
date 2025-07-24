// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract neoBTC is ERC20, Ownable {
    uint256 public index = 1e18; // starts at 1.0
    uint256 public totalShares;

    mapping(address => uint256) private _shares;

    event Minted(address indexed user, uint256 btcAmount, uint256 sharesMinted, string btcWallet, string custodian);
    event Burned(address indexed user, uint256 sharesBurned);
    event Rebased(uint256 reward, uint256 newIndex);

    constructor() ERC20("neoBTC", "neoBTC") Ownable(msg.sender) {}

    modifier onlyAdmin() {
        require(owner() == msg.sender, "Not admin");
        _;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return (_shares[account] * index) / 1e18;
    }

    function mint(address recipient, uint256 btcAmount, string calldata btcWallet, string calldata custodian) external onlyAdmin {
        require(btcAmount > 0, "Invalid amount");

        uint256 shares = (btcAmount * 1e18) / index;
        _shares[recipient] += shares;
        totalShares += shares;

        emit Minted(recipient, btcAmount, shares, btcWallet, custodian);
    }

    function burn(address user, uint256 btcAmount) external onlyAdmin {
        uint256 shares = (btcAmount * 1e18) / index;
        require(_shares[user] >= shares, "Insufficient balance");

        _shares[user] -= shares;
        totalShares -= shares;

        emit Burned(user, shares);
    }

    function rebase(uint256 reward) external onlyAdmin {
        require(totalShares > 0, "No supply");

        uint256 deltaIndex = (reward * 1e18) / totalShares;
        index += deltaIndex;

        emit Rebased(reward, index);
    }

    function transfer(address, uint256) public pure override returns (bool) {
        revert("Transfers disabled, use wrapper");
    }

    function transferFrom(address, address, uint256) public pure override returns (bool) {
        revert("Transfers disabled, use wrapper");
    }
}
