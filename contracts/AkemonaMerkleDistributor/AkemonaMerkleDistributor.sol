// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.4.0
pragma solidity ^0.8.27;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {IAkemonaMerkleDistributor} from "./IAkemonaMerkleDistributor.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IAkemonaContractErrors} from "../interfaces/IAkemonaContractErrors.sol";

contract AkemonaMerkleDistributor is
    Pausable,
    AccessControl,
    IAkemonaMerkleDistributor
{
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    /// @dev The merkle root which will be used to verify claims
    bytes32 public override merkleRoot;

    /// @dev wallet with tokens to claim
    address public paymentWallet;

    /// @dev Perk/Security Token contract
    address public override token;

    /// @dev This is a packed array of booleans.
    mapping(uint256 => uint256) private claimedBitMap;

    constructor(
        address defaultAdmin,
        address pauser,
        address _token,
        address _paymentWallet,
        bytes32 _merkleRoot
    ) {
        merkleRoot = _merkleRoot;
        token = _token;
        paymentWallet = _paymentWallet;

        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        _grantRole(PAUSER_ROLE, pauser);
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    /**
     * @dev Check if the user of the merkle index has claimed drops already.
     * @param index - The merkle index
     * @return true if it's claimed, otherwise false
     */
    function isClaimed(uint256 index) public view override returns (bool) {
        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        uint256 claimedWord = claimedBitMap[claimedWordIndex];
        uint256 mask = (1 << claimedBitIndex);
        return claimedWord & mask == mask;
    }

    /**
     * @dev Marks that the user of the merkle index has claimed drops.
     * @param index - The merkle index
     */
    function _setClaimed(uint256 index) private {
        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        claimedBitMap[claimedWordIndex] =
            claimedBitMap[claimedWordIndex] |
            (1 << claimedBitIndex);
    }

    /**
     * @notice updates the payment wallet.
     * @param _newWallet - Address that holds Ondo to transfer to the user
     */
    function updatePaymentWallet(
        address _newWallet
    ) external onlyRole(DEFAULT_ADMIN_ROLE) whenNotPaused {
        paymentWallet = _newWallet;
        emit PaymentWalletUpdated(_newWallet);
    }

    /**
     * @dev Allows users to claim tokens.
     * It reverts when the user has already claimed or after terminated.
     * index, account, amount, merkleProof - all these data has been used
     * to contribute merkle tree, hence users must keep it securely and provide correct data
     * or it will fail to claim.
     *
     * @param index       - The merkle index
     * @param account     - The address of the user
     * @param amount      - The amount to be distributed to the user
     * @param merkleProof - The merkle proof
     */
    function claim(
        uint256 index,
        address account,
        uint256 amount,
        bytes32[] calldata merkleProof
    ) external override whenNotPaused {
        require(msg.sender == account, "Can't claim another user's tokens");
        require(!isClaimed(index), "Error: Drop already claimed.");

        // Verify the merkle proof.
        bytes32 leaf = keccak256(
            bytes.concat(keccak256(abi.encode(index, account, amount)))
        );

        require(
            MerkleProof.verify(merkleProof, merkleRoot, leaf),
            "Error: Invalid proof."
        );
        /*  
         - removed to reduce gas cost, transfer will fail automatically if allowance is not enough
        uint256 currentAllowance = IERC20(token).allowance(
                paymentWallet,
                address(this)
            );
            if (currentAllowance < amount) {
                revert IAkemonaContractErrors.AkemonaNotEnoughAllowance(
                    amount,
                    currentAllowance
                );
            } 
        */

        // Mark address as claimed
        _setClaimed(index);

        IERC20(token).transferFrom(paymentWallet, account, amount);

        emit Claimed(index, account, amount);
    }
}
