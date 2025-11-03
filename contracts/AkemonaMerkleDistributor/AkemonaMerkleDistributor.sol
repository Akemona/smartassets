// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.4.0
pragma solidity ^0.8.27;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";

contract AkemonaMerkleDistributor is Pausable, AccessControl {
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    /// @dev The merkle root which will be used to verify claims
    // bytes32 public override merkleRoot;

    /// @dev This is a packed array of booleans.
    mapping(uint256 => uint256) private claimedBitMap;

    constructor(address defaultAdmin, address pauser) {
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
    // function isClaimed(uint256 index) public view override returns (bool) {
    //     uint256 claimedWordIndex = index / 256;
    //     uint256 claimedBitIndex = index % 256;
    //     uint256 claimedWord = claimedBitMap[claimedWordIndex];
    //     uint256 mask = (1 << claimedBitIndex);
    //     return claimedWord & mask == mask;
    // }
}
