// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.4.0
pragma solidity ^0.8.27;

import {BitMaps} from "@openzeppelin/contracts/utils/structs/BitMaps.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {
    MerkleProof
} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {IMintable} from "../interfaces/IMintable.sol";

/// @title AkemonaMerkleDistributor
/// @author [Akemona](https://akemona.com)
/// @notice A contract that allows a user to claim a token against a Merkle tree root.
contract AkemonaMerkleDistributor is Pausable, AccessControl {
    using BitMaps for BitMaps.BitMap;

    /// @notice Pauser role.
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    /// @notice The Merkle root for the distribution.
    bytes32 public immutable MERKLE_ROOT;

    /// @notice The security/perk token contract for the tokens to be claimed.
    IMintable public immutable TOKEN;

    /// @notice This is the total amount of tokens that have been claimed so far.
    uint256 public totalClaimed;

    /// @notice The maximum number of tokens that may be claimed using the MerkleDistributor.
    uint256 public immutable MAXIMUM_TOTAL_CLAIMABLE;

    /// @notice This is a packed array of booleans for tracking completion of claims.
    BitMaps.BitMap internal claimedBitMap;

    /// @notice Event that is emitted whenever a call to claim succeeds.
    /// @param index The index of the claim.
    /// @param account The address that will receive the new tokens.
    /// @param amount The quantity of tokens, in raw decimals, that will be created.
    event Claimed(uint256 index, address indexed account, uint256 amount);

    /// @notice Error thrown when the claim has already been claimed.
    error AkemonaMerkleDistributor__AlreadyClaimed();

    /// @notice Error for when the claim has an invalid proof.
    error AkemonaMerkleDistributor__InvalidProof();

    /// @notice Error for when the total claimed exceeds the maximum claimable amount.
    error AkemonaMerkleDistributor__ClaimAmountExceedsMaximum();

    /// @notice Error for when the sweep has already been done.
    error AkemonaMerkleDistributor__SweepAlreadyDone();

    constructor(
        address _defaultAdmin,
        address _pauser,
        uint256 _maximumTotalClaimable,
        IMintable _token,
        bytes32 _merkleRoot
    ) {
        TOKEN = _token;
        MERKLE_ROOT = _merkleRoot;
        MAXIMUM_TOTAL_CLAIMABLE = _maximumTotalClaimable;

        _grantRole(DEFAULT_ADMIN_ROLE, _defaultAdmin);
        _grantRole(PAUSER_ROLE, _pauser);
    }

    /// @notice Pauses the claim.
    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    /// @notice Resume the contract/claim.
    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    /// @notice Returns true if the index has been claimed.
    /// @param _index The index of the claim.
    /// @return Whether a claim has been claimed.
    function isClaimed(uint256 _index) public view returns (bool) {
        return claimedBitMap.get(_index);
    }

    /// @notice Claims the tokens for a caller, given the index, amount, and merkle proof.
    /// @param _index The index of the claim.
    /// @param _amount The quantity of tokens, in raw decimals, that will be created.
    /// @param _merkleProof The Merkle proof for the claim.
    function claim(
        uint256 _index,
        uint256 _amount,
        bytes32[] calldata _merkleProof
    ) external {
        _claim(_index, msg.sender, _amount, _merkleProof);
    }

    /// @notice Allows the admin to sweep unclaimed tokens to a given address.
    /// @param _unclaimedReceiver The address that will receive the unclaimed tokens.
    function sweepUnclaimed(
        address _unclaimedReceiver
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _revertIfAlreadySwept();
        TOKEN.mint(_unclaimedReceiver, MAXIMUM_TOTAL_CLAIMABLE - totalClaimed);
        totalClaimed = MAXIMUM_TOTAL_CLAIMABLE;
    }

    /// @notice Claims the tokens for a given index, account, amount, and merkle proof.
    /// @param _index The index of the claim.
    /// @param _claimant The address that will receive the new tokens.
    /// @param _amount The quantity of tokens, in raw decimals, that will be created.
    /// @param _merkleProof The Merkle proof for the claim.
    /// @dev Internal method for claiming tokens, called by 'claim'.
    function _claim(
        uint256 _index,
        address _claimant,
        uint256 _amount,
        bytes32[] calldata _merkleProof
    ) internal {
        _revertIfClaimAmountExceedsMaximum(_amount);
        _revertIfAlreadyClaimed(_index);

        // Verify the merkle proof.
        bytes32 node = keccak256(
            bytes.concat(keccak256(abi.encode(_index, _claimant, _amount)))
        );
        if (!MerkleProof.verifyCalldata(_merkleProof, MERKLE_ROOT, node)) {
            revert AkemonaMerkleDistributor__InvalidProof();
        }

        // Bump the total amount claimed, mark it claimed, mint the token, and emit Claimed event.
        totalClaimed += _amount;
        _setClaimed(_index);
        TOKEN.mint(_claimant, _amount);
        emit Claimed(_index, _claimant, _amount);
    }

    /// @notice marks the given index as claimed.
    /// @param _index The index of the claim.
    function _setClaimed(uint256 _index) private {
        claimedBitMap.set(_index);
    }

    /// @notice Reverts if the claim amount exceeds the maximum.
    /// @param _amount The quantity of tokens, in raw decimals, that will be created.
    function _revertIfClaimAmountExceedsMaximum(uint256 _amount) internal view {
        if (_amount + totalClaimed > MAXIMUM_TOTAL_CLAIMABLE) {
            revert AkemonaMerkleDistributor__ClaimAmountExceedsMaximum();
        }
    }

    /// @notice Reverts if already claimed.
    /// @param _index The index of the claim.
    function _revertIfAlreadyClaimed(uint256 _index) internal view {
        if (isClaimed(_index)) {
            revert AkemonaMerkleDistributor__AlreadyClaimed();
        }
    }

    /// @notice Reverts if the sweep has already been done.
    function _revertIfAlreadySwept() internal view {
        if (totalClaimed >= MAXIMUM_TOTAL_CLAIMABLE) {
            revert AkemonaMerkleDistributor__SweepAlreadyDone();
        }
    }
}
