// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

/**
 * @dev Standard Contract Errors
 * Custom error interface.
 */
interface IAkemonaContractErrors {
    /**
     * @dev Indicates invalid/zero address.
     * @param walletAddress address.
     */
    error AkemonaInvalidAddress(address walletAddress);

    /**
     * @dev Input exceeds maximum allowed length in array input.
     * @param passedLength unit.
     * @param maxAllowedElements unit.
     */
    error AkemonaInputExceedsMax(uint passedLength, uint maxAllowedElements);

    /**
     * @dev Address is not verified yet.
     * @param walletAddress address.
     */
    error AkemonaAddressNotVerified(address walletAddress);

    /**
     * @dev Not enough allowance.
     * @param minExpected expected allowance.
     * @param received received allowance.
     */
    error AkemonaNotEnoughAllowance(uint256 minExpected, uint256 received);

    /**
     * @dev Not enough allowance.
     * @param minExpected expected allowance.
     * @param received received allowance.
     */
    error AkemonaNotEnoughBalance(uint256 minExpected, uint256 received);

    /**
     * @dev Token transfer failed.
     * @param toAddress address
     * @param amountToSend amount.
     */
    error AkemonaTransferFailed(address toAddress, uint256 amountToSend);

    /**
     * @dev Address is not whitelisted.
     * @param walletAddress address.
     */
    error AkemonaAddressNotWhitelisted(address walletAddress);

    /**
     * @dev Invalid/zero amount.
     * @param amount  amount
     */
    error AkemonaInvalidAmount(uint256 amount);

    /**
     * @dev Wallet verification expired.
     * @param walletAddress wallet address
     * @param timeDifference time difference
     */
    error AkemonaVerificationExpired(
        address walletAddress,
        uint256 timeDifference
    );

    /**
     * @dev redeem not supported if payment wallet is zero address
     */
    error AkemonaRedeemNotSupported();
}
