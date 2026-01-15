// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IProofRegistry {
    struct Proof {
        bytes32 proofType;
        address subject;
        bytes32 metadataHash;
        uint256 timestamp;
        address issuer;
        bool revoked;
    }
    
    function issueProof(
        address subject,
        bytes32 proofType,
        bytes32 metadataHash
    ) external returns (uint256 proofId);
    
    function revokeProof(uint256 proofId) external;
    
    function getProofs(address subject) external view returns (uint256[] memory);
    
    function getProofsByType(
        address subject,
        bytes32 proofType
    ) external view returns (uint256[] memory);
    
    function hasProof(address subject, bytes32 proofType) external view returns (bool);
    
    function getProof(uint256 proofId) external view returns (Proof memory);
    
    function getProofTypeHolders(bytes32 proofType) external view returns (address[] memory);
}

