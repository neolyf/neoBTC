// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./neoBTC.sol";

contract wneoBTC is ERC20 {
    neoBTC public immutable underlying;

    constructor(address _neoBTC) ERC20("Wrapped neoBTC", "wneoBTC") {
        underlying = neoBTC(_neoBTC);
    }

    function wrap(uint256 amount) external {
        // User must have enough neoBTC "rebasing balance"
        require(underlying.balanceOf(msg.sender) >= amount, "Insufficient neoBTC balance");

        // Calculate shares to mint (non-rebasing)
        uint256 shares = (amount * 1e18) / underlying.index();
        _mint(msg.sender, shares);
    }

    function unwrap(uint256 shares) external {
        // Burn wrapper shares
        _burn(msg.sender, shares);
        // Value is still stored in underlying neoBTC; redemption handled off-chain
        // Optionally emit event to help frontend/off-chain logic
        emit Unwrapped(msg.sender, shares);
    }

    function balanceOfUnderlying(address user) external view returns (uint256) {
        return (balanceOf(user) * underlying.index()) / 1e18;
    }

    event Unwrapped(address indexed user, uint256 shares);
}
