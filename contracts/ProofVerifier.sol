// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./ProofRegistry.sol";

/**
 * @title ProofVerifier
 * @notice Utility contract for verifying proofs with additional validation logic
 * @dev Can be extended with custom verification rules
 */
contract ProofVerifier {
    ProofRegistry public immutable proofRegistry;
    
    constructor(address _proofRegistry) {
        require(_proofRegistry != address(0), "ProofVerifier: invalid registry");
        proofRegistry = ProofRegistry(_proofRegistry);
    }
    
    /**
     * @notice Verify that a subject has a specific proof type
     * @param subject Address to verify
     * @param proofType Type of proof to verify
     * @return isValid True if subject has valid (non-revoked) proof
     * @return proofId The first valid proof ID found (0 if none)
     */
    function verifyProof(
        address subject,
        bytes32 proofType
    ) external view returns (bool isValid, uint256 proofId) {
        uint256[] memory proofIds = proofRegistry.getProofsByType(subject, proofType);
        
        for (uint256 i = 0; i < proofIds.length; i++) {
            ProofRegistry.Proof memory proof = proofRegistry.getProof(proofIds[i]);
            if (!proof.revoked) {
                return (true, proofIds[i]);
            }
        }
        
        return (false, 0);
    }
    
    /**
     * @notice Verify multiple proof types for a subject
     * @param subject Address to verify
     * @param proofTypes Array of proof types to verify
     * @return results Array of verification results (true/false for each type)
     */
    function verifyMultipleProofs(
        address subject,
        bytes32[] calldata proofTypes
    ) external view returns (bool[] memory results) {
        results = new bool[](proofTypes.length);
        
        for (uint256 i = 0; i < proofTypes.length; i++) {
            (bool isValid,) = this.verifyProof(subject, proofTypes[i]);
            results[i] = isValid;
        }
        
        return results;
    }
    
    /**
     * @notice Get count of valid proofs for a subject
     * @param subject Address to query
     * @return count Number of non-revoked proofs
     */
    function getValidProofCount(address subject) external view returns (uint256 count) {
        uint256[] memory proofIds = proofRegistry.getProofs(subject);
        
        for (uint256 i = 0; i < proofIds.length; i++) {
            ProofRegistry.Proof memory proof = proofRegistry.getProof(proofIds[i]);
            if (!proof.revoked) {
                count++;
            }
        }
        
        return count;
    }
}

