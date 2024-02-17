// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

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
}
