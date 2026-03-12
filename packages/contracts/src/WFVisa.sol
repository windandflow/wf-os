// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title WFVisa
 * @notice Non-transferable NFT representing membership in a W&F State (Sodo).
 *         Metadata includes level (0-4) and cooperative status.
 *         Supports ERC-4906 for metadata update notifications.
 *
 * Level 0: Observer    - Invited, browsing
 * Level 1: Participant - 3+ visits
 * Level 2: Contributor - Sustained contribution, voting rights
 * Level 3: Steward     - Cooperative member (off-chain verification required)
 * Level 4: Elder       - Long-term dedication, mediation authority
 */
contract WFVisa is ERC721, Ownable {
    uint256 private _tokenIdCounter;

    struct VisaData {
        bytes32 stateId;       // e.g., keccak256("sinwolri")
        uint8 level;           // 0-4
        bool coopMember;       // off-chain cooperative membership verified
        uint64 issuedAt;
        uint64 levelUpdatedAt;
        address invitedBy;     // wallet of the inviter
    }

    mapping(uint256 => VisaData) public visaData;
    mapping(address => mapping(bytes32 => uint256)) public visaOf; // holder -> stateId -> tokenId

    // ERC-4906: Metadata update event
    event MetadataUpdate(uint256 _tokenId);
    event VisaIssued(uint256 indexed tokenId, address indexed holder, bytes32 indexed stateId, address invitedBy);
    event VisaLevelChanged(uint256 indexed tokenId, uint8 oldLevel, uint8 newLevel, address changedBy);
    event CoopStatusChanged(uint256 indexed tokenId, bool coopMember, address verifiedBy);

    constructor(address initialOwner)
        ERC721("Wind & Flow Visa", "WFVISA")
        Ownable(initialOwner)
    {}

    /**
     * @notice Issue a Visa to a NIM for a specific State.
     */
    function mint(
        address to,
        bytes32 stateId,
        address invitedBy
    ) external onlyOwner returns (uint256) {
        require(visaOf[to][stateId] == 0, "Already has visa for this state");

        _tokenIdCounter++;
        uint256 tokenId = _tokenIdCounter;

        _safeMint(to, tokenId);

        visaData[tokenId] = VisaData({
            stateId: stateId,
            level: 0,
            coopMember: false,
            issuedAt: uint64(block.timestamp),
            levelUpdatedAt: uint64(block.timestamp),
            invitedBy: invitedBy
        });

        visaOf[to][stateId] = tokenId;

        emit VisaIssued(tokenId, to, stateId, invitedBy);

        return tokenId;
    }

    /**
     * @notice Update Visa level. Only owner (multisig).
     *         Level 3 requires coopMember == true (enforced off-chain, recorded here).
     */
    function updateLevel(uint256 tokenId, uint8 newLevel) external onlyOwner {
        require(_ownerOf(tokenId) != address(0), "Visa does not exist");
        require(newLevel <= 4, "Invalid level");

        VisaData storage v = visaData[tokenId];

        // Level 3+ requires cooperative membership
        if (newLevel >= 3) {
            require(v.coopMember, "Cooperative membership required for level 3+");
        }

        uint8 oldLevel = v.level;
        v.level = newLevel;
        v.levelUpdatedAt = uint64(block.timestamp);

        emit VisaLevelChanged(tokenId, oldLevel, newLevel, msg.sender);
        emit MetadataUpdate(tokenId);
    }

    /**
     * @notice Record cooperative membership status (off-chain bridge).
     *         Called by Operator after verifying off-chain cooperative enrollment.
     */
    function updateCoopStatus(uint256 tokenId, bool _coopMember) external onlyOwner {
        require(_ownerOf(tokenId) != address(0), "Visa does not exist");

        visaData[tokenId].coopMember = _coopMember;

        emit CoopStatusChanged(tokenId, _coopMember, msg.sender);
        emit MetadataUpdate(tokenId);
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
        require(from == address(0) || to == address(0), "Soulbound: non-transferable");
        return super._update(to, tokenId, auth);
    }

    /**
     * @notice Token URI. Returns on-chain JSON with level and state info.
     *         In production, this would point to a metadata API.
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        _requireOwned(tokenId);
        // MVP: return placeholder. Real implementation uses metadata API.
        return string(abi.encodePacked(
            "https://windandflow.xyz/api/metadata/visa/",
            _toString(tokenId)
        ));
    }

    function totalVisas() external view returns (uint256) {
        return _tokenIdCounter;
    }

    // Simple uint to string helper
    function _toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) return "0";
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) { digits++; temp /= 10; }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}
