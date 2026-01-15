// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title ProofRegistry
 * @notice On-chain registry for verifiable proof-of-contribution attestations on Base
 * @dev Stores proofs of meaningful actions without NFTs or tokens - just clean attestations
 */
contract ProofRegistry {
    /// @notice Proof structure
    struct Proof {
        bytes32 proofType;      // e.g., keccak256("BASE_CONTRACT_DEPLOYER")
        address subject;        // Address that the proof is about
        bytes32 metadataHash;   // Hash of proof metadata (IPFS, JSON, etc.)
        uint256 timestamp;      // Block timestamp when proof was issued
        address issuer;         // Address that issued the proof
        bool revoked;           // Whether the proof has been revoked
    }

    /// @notice Mapping from proof ID to Proof struct
    mapping(uint256 => Proof) public proofs;
    
    /// @notice Mapping from subject address to array of proof IDs
    mapping(address => uint256[]) public proofsBySubject;
    
    /// @notice Mapping from proof type to array of proof IDs
    mapping(bytes32 => uint256[]) public proofsByType;
    
    /// @notice Mapping from subject + proofType to proof ID (for quick lookup)
    mapping(address => mapping(bytes32 => uint256[])) public proofsBySubjectAndType;
    
    /// @notice Total number of proofs issued
    uint256 public totalProofs;
    
    /// @notice Authorized issuers (indexers, protocols, DAOs, operators)
    mapping(address => bool) public authorizedIssuers;
    
    /// @notice Owner of the contract (can add/remove issuers)
    address public owner;
    
    /// @notice Events
    event ProofIssued(
        uint256 indexed proofId,
        bytes32 indexed proofType,
        address indexed subject,
        bytes32 metadataHash,
        address issuer,
        uint256 timestamp
    );
    
    event ProofRevoked(
        uint256 indexed proofId,
        address indexed issuer,
        uint256 timestamp
    );
    
    event IssuerAuthorized(address indexed issuer, address indexed authorizedBy);
    event IssuerRevoked(address indexed issuer, address indexed revokedBy);
    
    /// @notice Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "ProofRegistry: not owner");
        _;
    }
    
    modifier onlyAuthorizedIssuer() {
        require(authorizedIssuers[msg.sender], "ProofRegistry: not authorized issuer");
        _;
    }
    
    /// @notice Constructor
    constructor() {
        owner = msg.sender;
        authorizedIssuers[msg.sender] = true;
        emit IssuerAuthorized(msg.sender, msg.sender);
    }
    
    /**
     * @notice Issue a new proof
     * @param subject Address that the proof is about
     * @param proofType Type of proof (e.g., keccak256("BASE_CONTRACT_DEPLOYER"))
     * @param metadataHash Hash of proof metadata
     * @return proofId The ID of the newly issued proof
     */
    function issueProof(
        address subject,
        bytes32 proofType,
        bytes32 metadataHash
    ) external onlyAuthorizedIssuer returns (uint256 proofId) {
        require(subject != address(0), "ProofRegistry: invalid subject");
        require(proofType != bytes32(0), "ProofRegistry: invalid proof type");
        
        proofId = totalProofs;
        totalProofs++;
        
        Proof storage proof = proofs[proofId];
        proof.proofType = proofType;
        proof.subject = subject;
        proof.metadataHash = metadataHash;
        proof.timestamp = block.timestamp;
        proof.issuer = msg.sender;
        proof.revoked = false;
        
        proofsBySubject[subject].push(proofId);
        proofsByType[proofType].push(proofId);
        proofsBySubjectAndType[subject][proofType].push(proofId);
        
        emit ProofIssued(
            proofId,
            proofType,
            subject,
            metadataHash,
            msg.sender,
            block.timestamp
        );
        
        return proofId;
    }
    
    /**
     * @notice Revoke a proof
     * @param proofId ID of the proof to revoke
     */
    function revokeProof(uint256 proofId) external {
        Proof storage proof = proofs[proofId];
        require(proof.issuer != address(0), "ProofRegistry: proof does not exist");
        require(
            msg.sender == proof.issuer || msg.sender == owner,
            "ProofRegistry: not authorized to revoke"
        );
        require(!proof.revoked, "ProofRegistry: proof already revoked");
        
        proof.revoked = true;
        
        emit ProofRevoked(proofId, msg.sender, block.timestamp);
    }
    
    /**
     * @notice Get all proofs for a subject address
     * @param subject Address to query
     * @return proofIds Array of proof IDs
     */
    function getProofs(address subject) external view returns (uint256[] memory) {
        return proofsBySubject[subject];
    }
    
    /**
     * @notice Get all proofs of a specific type for a subject
     * @param subject Address to query
     * @param proofType Type of proof to filter by
     * @return proofIds Array of proof IDs
     */
    function getProofsByType(
        address subject,
        bytes32 proofType
    ) external view returns (uint256[] memory) {
        return proofsBySubjectAndType[subject][proofType];
    }
    
    /**
     * @notice Check if a subject has a specific proof type (non-revoked)
     * @param subject Address to check
     * @param proofType Type of proof to check
     * @return hasProof True if subject has at least one non-revoked proof of this type
     */
    function hasProof(address subject, bytes32 proofType) external view returns (bool) {
        uint256[] memory proofIds = proofsBySubjectAndType[subject][proofType];
        for (uint256 i = 0; i < proofIds.length; i++) {
            if (!proofs[proofIds[i]].revoked) {
                return true;
            }
        }
        return false;
    }
    
    /**
     * @notice Get proof details by ID
     * @param proofId ID of the proof
     * @return proof The Proof struct
     */
    function getProof(uint256 proofId) external view returns (Proof memory) {
        require(proofs[proofId].issuer != address(0), "ProofRegistry: proof does not exist");
        return proofs[proofId];
    }
    
    /**
     * @notice Get all holders of a specific proof type
     * @param proofType Type of proof to query
     * @return holders Array of unique subject addresses
     */
    function getProofTypeHolders(bytes32 proofType) external view returns (address[] memory) {
        uint256[] memory proofIds = proofsByType[proofType];
        
        // Use a temporary mapping to track unique addresses
        mapping(address => bool) storage seen;
        address[] memory uniqueHolders = new address[](proofIds.length);
        uint256 uniqueCount = 0;
        
        for (uint256 i = 0; i < proofIds.length; i++) {
            Proof memory proof = proofs[proofIds[i]];
            if (!proof.revoked && !seen[proof.subject]) {
                seen[proof.subject] = true;
                uniqueHolders[uniqueCount] = proof.subject;
                uniqueCount++;
            }
        }
        
        // Resize array to actual unique count
        address[] memory result = new address[](uniqueCount);
        for (uint256 i = 0; i < uniqueCount; i++) {
            result[i] = uniqueHolders[i];
        }
        
        return result;
    }
    
    /**
     * @notice Authorize a new issuer
     * @param issuer Address to authorize
     */
    function authorizeIssuer(address issuer) external onlyOwner {
        require(issuer != address(0), "ProofRegistry: invalid issuer");
        authorizedIssuers[issuer] = true;
        emit IssuerAuthorized(issuer, msg.sender);
    }
    
    /**
     * @notice Revoke issuer authorization
     * @param issuer Address to revoke
     */
    function revokeIssuer(address issuer) external onlyOwner {
        require(authorizedIssuers[issuer], "ProofRegistry: issuer not authorized");
        authorizedIssuers[issuer] = false;
        emit IssuerRevoked(issuer, msg.sender);
    }
    
    /**
     * @notice Transfer ownership
     * @param newOwner New owner address
     */
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "ProofRegistry: invalid new owner");
        owner = newOwner;
    }
}

