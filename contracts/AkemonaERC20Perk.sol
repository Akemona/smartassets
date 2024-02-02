// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract AkemonaERC20Perk is
    ERC20,
    ERC20Burnable,
    ERC20Pausable,
    AccessControl
{
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    // max supply
    uint256 private _maxSupply;

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 maxSupply_
    ) ERC20(name_, symbol_) {
        _maxSupply = maxSupply_;
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    // Distributes tokens to multiple wallet addresses at once - admin only
    function distributeTokens(
        address[] calldata toAddresses,
        uint256[] calldata amounts
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(ERC20.totalSupply() <= _maxSupply, "Not enough supply");
        require(amounts.length == toAddresses.length, "Data length mismatch");

        uint256 totalAmount = 0;

        for (uint256 i = 0; i < toAddresses.length; i++) {
            totalAmount += amounts[i];
        }
        require(
            ERC20.totalSupply() + totalAmount <= _maxSupply,
            "Not enough supply"
        );

        for (uint256 i = 0; i < toAddresses.length; i++) {
            _mint(toAddresses[i], amounts[i]);
        }
    }

    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        require(ERC20.totalSupply() + amount <= _maxSupply, "Out of stock");
        require(amount != 0, "Amount is zero");
        _mint(to, amount);
    }

    function maxSupply() public view returns (uint256) {
        return _maxSupply;
    }

    // The following functions are overrides required by Solidity.

    function _update(
        address from,
        address to,
        uint256 value
    ) internal override(ERC20, ERC20Pausable) {
        super._update(from, to, value);
    }
}
