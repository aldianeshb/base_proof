// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {ProofRegistry} from "../ProofRegistry.sol";
import {ProofVerifier} from "../ProofVerifier.sol";

contract ProofRegistryTest is Test {
    ProofRegistry public registry;
    ProofVerifier public verifier;
    
    address public owner;
    address public issuer;
    address public subject;
    
    bytes32 public constant PROOF_TYPE = keccak256("BASE_CONTRACT_DEPLOYER");
    
    function setUp() public {
        owner = address(this);
        issuer = address(0x1);
        subject = address(0x2);
        
        registry = new ProofRegistry();
        verifier = new ProofVerifier(address(registry));
        
        // Authorize issuer
        registry.authorizeIssuer(issuer);
    }
    
    function test_IssueProof() public {
        bytes32 metadataHash = keccak256("test-metadata");
        
        vm.prank(issuer);
        uint256 proofId = registry.issueProof(subject, PROOF_TYPE, metadataHash);
        
        assertEq(proofId, 0);
        assertEq(registry.totalProofs(), 1);
        
        ProofRegistry.Proof memory proof = registry.getProof(proofId);
        assertEq(proof.subject, subject);
        assertEq(proof.proofType, PROOF_TYPE);
        assertEq(proof.metadataHash, metadataHash);
        assertEq(proof.issuer, issuer);
        assertFalse(proof.revoked);
    }
    
    function test_GetProofs() public {
        bytes32 metadataHash = keccak256("test-metadata");
        
        vm.prank(issuer);
        registry.issueProof(subject, PROOF_TYPE, metadataHash);
        
        uint256[] memory proofIds = registry.getProofs(subject);
        assertEq(proofIds.length, 1);
        assertEq(proofIds[0], 0);
    }
    
    function test_HasProof() public {
        bytes32 metadataHash = keccak256("test-metadata");
        
        assertFalse(registry.hasProof(subject, PROOF_TYPE));
        
        vm.prank(issuer);
        registry.issueProof(subject, PROOF_TYPE, metadataHash);
        
        assertTrue(registry.hasProof(subject, PROOF_TYPE));
    }
    
    function test_RevokeProof() public {
        bytes32 metadataHash = keccak256("test-metadata");
        
        vm.prank(issuer);
        uint256 proofId = registry.issueProof(subject, PROOF_TYPE, metadataHash);
        
        assertTrue(registry.hasProof(subject, PROOF_TYPE));
        
        vm.prank(issuer);
        registry.revokeProof(proofId);
        
        assertFalse(registry.hasProof(subject, PROOF_TYPE));
        
        ProofRegistry.Proof memory proof = registry.getProof(proofId);
        assertTrue(proof.revoked);
    }
    
    function test_OnlyAuthorizedIssuer() public {
        bytes32 metadataHash = keccak256("test-metadata");
        address unauthorized = address(0x999);
        
        vm.prank(unauthorized);
        vm.expectRevert("ProofRegistry: not authorized issuer");
        registry.issueProof(subject, PROOF_TYPE, metadataHash);
    }
    
    function test_VerifyProof() public {
        bytes32 metadataHash = keccak256("test-metadata");
        
        vm.prank(issuer);
        registry.issueProof(subject, PROOF_TYPE, metadataHash);
        
        (bool isValid, uint256 proofId) = verifier.verifyProof(subject, PROOF_TYPE);
        assertTrue(isValid);
        assertEq(proofId, 0);
    }
    
    function test_MultipleProofs() public {
        bytes32 metadataHash1 = keccak256("metadata1");
        bytes32 metadataHash2 = keccak256("metadata2");
        bytes32 proofType2 = keccak256("BASE_TESTNET_USER");
        
        vm.startPrank(issuer);
        registry.issueProof(subject, PROOF_TYPE, metadataHash1);
        registry.issueProof(subject, proofType2, metadataHash2);
        vm.stopPrank();
        
        uint256[] memory allProofs = registry.getProofs(subject);
        assertEq(allProofs.length, 2);
        
        assertTrue(registry.hasProof(subject, PROOF_TYPE));
        assertTrue(registry.hasProof(subject, proofType2));
    }
}

