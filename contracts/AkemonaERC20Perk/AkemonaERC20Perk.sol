// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts/access/extensions/AccessControlDefaultAdminRules.sol";
import "../interfaces/IAkemonaContractErrors.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract AkemonaERC20Perk is
    ERC20,
    ERC20Pausable,
    AccessControlDefaultAdminRules,
    IAkemonaContractErrors
{
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    uint private constant MAX_BATCH_SIZE = 255;

    // max supply
    uint256 private _maxSupply;
    uint256 private _tokensPerDollar;

    address private _usdc;
    address private _paymentWallet;
    IERC20 private usdcContract;

    // mapping of wallet address to last verified unix timestamp
    mapping(address => uint256) private whitelistedAddresses;

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 maxSupply_,
        uint256 tokensPerDollar_,
        address usdc_,
        address paymentWallet_
    ) ERC20(name_, symbol_) AccessControlDefaultAdminRules(3 days, msg.sender) {
        _maxSupply = maxSupply_;
        _usdc = usdc_;
        _paymentWallet = paymentWallet_;
        _tokensPerDollar = tokensPerDollar_;
        usdcContract = IERC20(_usdc);
        // default roles
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
     * @dev Adds new verified addresses (admin only)
     *
     * Requirements:
     *
     * - `_addresses` cannot have zero address.
     * - maximum of 255 addresses can be passed per call
     */
    function addWhitelistedAddresses(
        address[] calldata _addresses
    ) public onlyRole(DEFAULT_ADMIN_ROLE) returns (bool) {
        if (_addresses.length > MAX_BATCH_SIZE) {
            revert AkemonaInputExceedsMax(_addresses.length, MAX_BATCH_SIZE);
        }
        for (uint8 i = 0; i < _addresses.length; i++) {
            if (_addresses[i] == address(0)) {
                revert AkemonaInvalidAddress(address(0));
            } else if (whitelistedAddresses[_addresses[i]] > 0) {
                // skip if already whitelisted
                continue;
            }
            // set last verified timestamp
            whitelistedAddresses[_addresses[i]] = block.timestamp;
        }
        return true;
    }

    /**
     * @dev Removes specified verified addresses from list (admin only)
     *
     * Requirements:
     *
     * - `_addresses` cannot have zero address.
     * - maximum of 255 addresses can be passed per call
     */
    function removeWhitelistedAddresses(
        address[] calldata _addresses
    ) public onlyRole(DEFAULT_ADMIN_ROLE) returns (bool) {
        if (_addresses.length > MAX_BATCH_SIZE) {
            revert AkemonaInputExceedsMax(_addresses.length, MAX_BATCH_SIZE);
        }
        for (uint8 i = 0; i < _addresses.length; i++) {
            if (_addresses[i] == address(0)) {
                revert AkemonaInvalidAddress(address(0));
            } else if (whitelistedAddresses[_addresses[i]] == 0) {
                // skip if already removed
                continue;
            }
            delete whitelistedAddresses[_addresses[i]]; // sets zero
        }
        return true;
    }

    /**
     * @dev update last verified time for specified verified addresses - admin only
     * @param _addresses wallet addresses
     *
     * Requirements:
     *
     * - `_addresses` cannot have zero address.
     * - maximum of 255 addresses can be passed per call
     */
    function updateVerificationTimeForAddresses(
        address[] calldata _addresses
    ) public onlyRole(DEFAULT_ADMIN_ROLE) returns (bool) {
        for (uint8 i = 0; i < _addresses.length; i++) {
            if (_addresses[i] == address(0)) {
                revert AkemonaInvalidAddress(address(0));
            } else if (whitelistedAddresses[_addresses[i]] == 0) {
                revert AkemonaAddressNotVerified(_addresses[i]);
            }

            // update last verified timestamp
            whitelistedAddresses[_addresses[i]] = block.timestamp;
        }
        return true;
    }

    /**
     * @dev Distributes tokens to investors (admin only)
     * @param toAddresses  wallet addresses
     * @param amounts number of tokens
     * Requirements:
     *
     * - `toAddresses` cannot have zero address.
     * - maximum of 255 addresses can be passed per call
     */
    function distributeTokens(
        address[] calldata toAddresses,
        uint256[] calldata amounts
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(ERC20.totalSupply() <= _maxSupply, "Not enough supply");
        require(amounts.length == toAddresses.length, "Data length mismatch");

        if (toAddresses.length > MAX_BATCH_SIZE) {
            revert AkemonaInputExceedsMax(toAddresses.length, MAX_BATCH_SIZE);
        }

        uint256 totalAmount = 0;

        for (uint8 i = 0; i < toAddresses.length; i++) {
            if (toAddresses[i] == address(0)) {
                revert AkemonaInvalidAddress(address(0));
            }
            totalAmount += amounts[i];
        }
        require(
            ERC20.totalSupply() + totalAmount <= _maxSupply,
            "Not enough supply"
        );

        for (uint8 i = 0; i < toAddresses.length; i++) {
            _mint(toAddresses[i], amounts[i]);
        }
    }

    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        require(ERC20.totalSupply() + amount <= _maxSupply, "Out of stock");
        if (amount == 0) {
            revert AkemonaInvalidAmount(amount);
        } else if (to == address(0)) {
            revert AkemonaInvalidAddress(address(0));
        }
        _mint(to, amount);
    }

    /**
     * @dev Redeem tokens for USDC
     * @param amount number of tokens to redeem
     */
    function redeemInUSDC(uint256 amount) public returns (bool) {
        uint256 currentBalance = ERC20.balanceOf(msg.sender);
        if (currentBalance < amount) {
            revert AkemonaNotEnoughBalance(amount, currentBalance);
        }

        uint256 lastVerifiedAt = whitelistedAddresses[msg.sender];
        uint256 timeDiff = block.timestamp - lastVerifiedAt;

        if (lastVerifiedAt == 0) {
            revert AkemonaAddressNotWhitelisted(msg.sender);
        } else if (timeDiff > 180 days) {
            // check if last verified is not older than 180 days
            revert AkemonaVerificationExpired(msg.sender, timeDiff);
        }

        uint256 amountToSend = amount / _tokensPerDollar;
        uint256 currentAllowance = usdcContract.allowance(
            _paymentWallet,
            address(this)
        );

        if (currentAllowance < amountToSend) {
            revert AkemonaNotEnoughAllowance(amountToSend, currentAllowance);
        }

        uint256 usdcBalance = usdcContract.balanceOf(_paymentWallet);
        if (usdcBalance < amountToSend) {
            revert AkemonaNotEnoughBalance(amountToSend, usdcBalance);
        } else if (
            !usdcContract.transferFrom(_paymentWallet, msg.sender, amountToSend)
        ) {
            revert AkemonaTransferFailed(msg.sender, amountToSend);
        }
        // burn caller's perk tokens after transfer is sucessful
        _burn(msg.sender, amount);
        return true;
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
