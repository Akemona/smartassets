// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "../interfaces/IAkemonaContractErrors.sol";

contract AkemonaERC20Perk is
    ERC20,
    ERC20Pausable,
    AccessControl,
    IAkemonaContractErrors
{
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    uint public constant MAX_ELEMENTS_IN_BATCH = 255;

    // max supply
    uint256 private _maxSupply;

    // mapping of wallet address to last verified unix timestamp
    mapping(address => uint256) public verifiedAddresses;

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

    function decimals() public view virtual override returns (uint8) {
        return 6;
    }

    /**
     * @dev Adds new verified addresses - admin only
     *
     * Requirements:
     *
     * - `_addresses` cannot have zero address.
     * - maximum of 255 addresses can be passed per call
     */
    function addVerifiedAddresses(
        address[] memory _addresses
    ) public onlyRole(DEFAULT_ADMIN_ROLE) returns (bool) {
        if (_addresses.length > MAX_ELEMENTS_IN_BATCH) {
            revert AkemonaInputExceedsMax(
                _addresses.length,
                MAX_ELEMENTS_IN_BATCH
            );
        }
        for (uint8 i = 0; i < _addresses.length; i++) {
            if (_addresses[i] == address(0)) {
                revert AkemonaInvalidAddress(address(0));
            }
            // set last verified timestamp
            verifiedAddresses[_addresses[i]] = block.timestamp;
        }
        return true;
    }

    /**
     * @dev Removes specified verified addresses from list - admin only
     *
     * Requirements:
     *
     * - `_addresses` cannot have zero address.
     * - maximum of 255 addresses can be passed per call
     */
    function removeVerifiedAddresses(
        address[] memory _addresses
    ) public onlyRole(DEFAULT_ADMIN_ROLE) returns (bool) {
        for (uint8 i = 0; i < _addresses.length; i++) {
            if (_addresses[i] == address(0)) {
                revert AkemonaInvalidAddress(address(0));
            }
            delete verifiedAddresses[_addresses[i]]; // sets zero
        }
        return true;
    }

    /**
     * @dev update last verified time for specified verified addresses - admin only
     *
     * Requirements:
     *
     * - `_addresses` cannot have zero address.
     * - maximum of 255 addresses can be passed per call
     */
    function updateVerificationTimeForAddresses(
        address[] memory _addresses
    ) public onlyRole(DEFAULT_ADMIN_ROLE) returns (bool) {
        for (uint8 i = 0; i < _addresses.length; i++) {
            if (_addresses[i] == address(0)) {
                revert AkemonaInvalidAddress(address(0));
            } else if (verifiedAddresses[_addresses[i]] == 0) {
                revert AkemonaAddressNotVerified(_addresses[i]);
            }

            // update last verified timestamp
            verifiedAddresses[_addresses[i]] = block.timestamp;
        }
        return true;
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

    /**
     * @dev Destroys a `value` amount of tokens from `account` - could be used after redeem
     *
     * See {ERC20-_burn} and {ERC20-allowance}.
     *
     * Requirements:
     *
     * - Only account with admin role can take this action.
     */
    /* function burnFromAdmin(address account, uint256 value) public virtual {
        _burn(account, value);
    } */

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
