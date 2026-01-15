# BaseProof - Integration Guide

This guide explains how to integrate BaseProof into your dApp or service.

## Overview

BaseProof provides verifiable on-chain proofs of meaningful actions on Base. You can use these proofs for:

- **Allowlists:** Grant access based on proof ownership
- **Grants:** Verify eligibility for funding programs
- **Hackathons:** Verify participation and contributions
- **Reputation Systems:** Build on top of BaseProof attestations
- **Governance:** Weight votes based on proof types

## Integration Methods

### 1. JavaScript SDK (Recommended)

Install the SDK:

```bash
npm install @baseproof/sdk
```

Use in your code:

```typescript
import { BaseProof } from '@baseproof/sdk';

const client = new BaseProof({
  proofRegistryAddress: '0x...', // Deployed ProofRegistry address
  chainId: 84532, // Base Sepolia (8453 for mainnet)
  rpcUrl: 'https://sepolia.base.org' // Optional
});

// Check if address has a proof
const hasProof = await client.hasProof(
  '0x1234...',
  'BASE_CONTRACT_DEPLOYER'
);

// Get all proofs for an address
const proofs = await client.getProofs('0x1234...');

// Get holders of a proof type
const holders = await client.getProofTypeHolders('BASE_CONTRACT_DEPLOYER');
```

### 2. REST API

BaseProof provides a REST API for querying proofs:

```bash
# Get proofs for an address
curl https://api.baseproof.org/address/0x1234.../proofs

# Get holders of a proof type
curl https://api.baseproof.org/proof/BASE_CONTRACT_DEPLOYER/holders

# Verify a proof
curl -X POST https://api.baseproof.org/verify \
  -H "Content-Type: application/json" \
  -d '{"address": "0x1234...", "proofType": "BASE_CONTRACT_DEPLOYER"}'

# Get statistics
curl https://api.baseproof.org/stats
```

### 3. Direct Smart Contract Integration

You can interact directly with the ProofRegistry contract:

```solidity
import "@baseproof/contracts/interfaces/IProofRegistry.sol";

contract MyContract {
    IProofRegistry public proofRegistry;
    
    constructor(address _proofRegistry) {
        proofRegistry = IProofRegistry(_proofRegistry);
    }
    
    function checkProof(address user) external view returns (bool) {
        bytes32 proofType = keccak256("BASE_CONTRACT_DEPLOYER");
        return proofRegistry.hasProof(user, proofType);
    }
}
```

## Use Cases

### Allowlist Example

```typescript
async function checkAllowlist(address: string): Promise<boolean> {
  const client = new BaseProof({
    proofRegistryAddress: PROOF_REGISTRY_ADDRESS,
    chainId: 8453
  });
  
  // User must have deployed a contract OR be an early user
  const hasDeployer = await client.hasProof(address, 'BASE_CONTRACT_DEPLOYER');
  const isEarlyUser = await client.hasProof(address, 'EARLY_BASE_USER');
  
  return hasDeployer || isEarlyUser;
}
```

### Grant Eligibility

```typescript
async function checkGrantEligibility(address: string): Promise<boolean> {
  const client = new BaseProof({
    proofRegistryAddress: PROOF_REGISTRY_ADDRESS,
    chainId: 8453
  });
  
  const proofs = await client.getProofs(address);
  
  // Must have at least 2 different proof types
  const uniqueTypes = new Set(proofs.map(p => p.proofType));
  return uniqueTypes.size >= 2;
}
```

### Reputation Score

```typescript
async function calculateReputation(address: string): Promise<number> {
  const client = new BaseProof({
    proofRegistryAddress: PROOF_REGISTRY_ADDRESS,
    chainId: 8453
  });
  
  const proofs = await client.getProofs(address);
  
  // Weight different proof types
  const weights: Record<string, number> = {
    'BASE_CONTRACT_DEPLOYER': 10,
    'GOVERNANCE_PARTICIPANT': 5,
    'OPEN_SOURCE_CONTRIBUTOR': 8,
    'EARLY_BASE_USER': 3,
    'BASE_TESTNET_USER': 1
  };
  
  let score = 0;
  for (const proof of proofs) {
    score += weights[proof.proofType] || 0;
  }
  
  return score;
}
```

## Best Practices

1. **Cache Results:** Proof data doesn't change frequently, so cache API responses
2. **Handle Errors:** Network issues can occur, implement retry logic
3. **Verify On-chain:** For critical checks, verify directly on-chain rather than trusting API
4. **Check Revocation:** Always verify proofs haven't been revoked
5. **Use TypeScript:** The SDK provides full TypeScript support

## Support

- **Documentation:** https://docs.baseproof.org
- **GitHub:** https://github.com/aldianeshb/baseproof
- **Discord:** [Join our Discord]

---

**Last Updated:** 2025-01-27

