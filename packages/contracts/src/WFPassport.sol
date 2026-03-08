// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title WFPassport
 * @notice Soulbound Token (SBT) representing W&F Network citizenship.
 *         Non-transferable. One per address. Minted on manifesto signing.
 *
 * Based on ERC-5192 (Minimal Soulbound NFTs).
 */
contract WFPassport is ERC721, Ownable {
    uint256 private _tokenIdCounter;

    // Manifesto signature hash per token
    mapping(uint256 => bytes32) public manifestoHash;

    // One passport per address
    mapping(address => bool) public hasPassport;

    // ERC-5192: Locked event
    event Locked(uint256 tokenId);

    constructor(address initialOwner)
        ERC721("Wind & Flow Passport", "WFPASS")
        Ownable(initialOwner)
    {}

    /**
     * @notice Mint a Passport SBT.
     * @param to The recipient (NIM's wallet address)
     * @param _manifestoHash Hash of the signed manifesto (EIP-712)
     */
    function mint(address to, bytes32 _manifestoHash) external onlyOwner returns (uint256) {
        require(!hasPassport[to], "Already has passport");

        _tokenIdCounter++;
        uint256 tokenId = _tokenIdCounter;

        _safeMint(to, tokenId);
        manifestoHash[tokenId] = _manifestoHash;
        hasPassport[to] = true;

        emit Locked(tokenId);

        return tokenId;
    }

    /**
     * @notice Soulbound: transfers are disabled.
     */
    function _update(address to, uint256 tokenId, address auth)
        internal
        override
        returns (address)
    {
        address from = _ownerOf(tokenId);
        // Allow minting (from == address(0)) and burning (to == address(0))
        // Block transfers between non-zero addresses
        require(from == address(0) || to == address(0), "Soulbound: non-transferable");
        return super._update(to, tokenId, auth);
    }

    /**
     * @notice ERC-5192: All tokens are locked (soulbound).
     */
    function locked(uint256 tokenId) external view returns (bool) {
        _requireOwned(tokenId);
        return true;
    }

    /**
     * @notice Total passports issued.
     */
    function totalPassports() external view returns (uint256) {
        return _tokenIdCounter;
    }

    /**
     * @notice Get token ID for an address. Returns 0 if no passport.
     */
    function passportOf(address holder) external view returns (uint256) {
        if (!hasPassport[holder]) return 0;
        // Linear scan (acceptable for expected scale)
        for (uint256 i = 1; i <= _tokenIdCounter; i++) {
            if (_ownerOf(i) == holder) return i;
        }
        return 0;
    }
}
