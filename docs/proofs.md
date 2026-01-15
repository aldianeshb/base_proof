# BaseProof - Proof Types

This document describes all available proof types in BaseProof.

## Overview

BaseProof issues verifiable on-chain attestations for meaningful actions on Base. Each proof type represents a specific achievement or contribution.

## Proof Types

### BASE_CONTRACT_DEPLOYER

**Description:** Proves that an address has deployed at least one smart contract on Base mainnet.

**Verification Method:** Indexer monitors Base mainnet for CREATE opcode events.

**Source of Truth:** Base mainnet blockchain

**Metadata Fields:**
- `contract_address`: Address of the deployed contract
- `deployment_tx_hash`: Transaction hash of the deployment
- `deployment_timestamp`: Unix timestamp of deployment
- `contract_bytecode_hash`: Hash of the contract bytecode

**Example:**
```json
{
  "contract_address": "0x1234...",
  "deployment_tx_hash": "0xabcd...",
  "deployment_timestamp": 1704067200,
  "contract_bytecode_hash": "0xef01..."
}
```

---

### BASE_TESTNET_USER

**Description:** Proves that an address has interacted with Base Sepolia testnet.

**Verification Method:** Indexer monitors Base Sepolia for transactions.

**Source of Truth:** Base Sepolia testnet blockchain

**Metadata Fields:**
- `first_tx_hash`: First transaction hash
- `first_tx_timestamp`: Timestamp of first transaction
- `total_transactions`: Total number of transactions

---

### GOVERNANCE_PARTICIPANT

**Description:** Proves that an address has participated in Base governance votes.

**Verification Method:** Indexer monitors Base governance contracts.

**Source of Truth:** Base governance contracts

**Metadata Fields:**
- `proposal_id`: Governance proposal ID
- `vote_tx_hash`: Transaction hash of the vote
- `vote_timestamp`: Timestamp of the vote
- `vote_choice`: Vote choice (for/against/abstain)

---

### OPEN_SOURCE_CONTRIBUTOR

**Description:** Proves that an address is associated with merged PRs to Base ecosystem repositories.

**Verification Method:** GitHub API integration

**Source of Truth:** GitHub API (Base repositories)

**Metadata Fields:**
- `github_username`: GitHub username
- `pr_url`: URL of the merged PR
- `pr_merged_at`: Timestamp when PR was merged
- `repository_name`: Name of the repository

---

### EARLY_BASE_USER

**Description:** Proves that an address was active on Base during early days (before a certain date).

**Verification Method:** Indexer checks first transaction timestamp

**Source of Truth:** Base mainnet blockchain

**Metadata Fields:**
- `first_tx_hash`: First transaction hash on Base
- `first_tx_timestamp`: Timestamp of first transaction
- `milestone_date`: Cutoff date for "early" status

---

## How Proofs Work

1. **Action Occurs:** User performs an action (deploys contract, votes, etc.)
2. **Indexer Detects:** BaseProof indexer detects the action
3. **Proof Generated:** Indexer generates proof with metadata
4. **On-chain Attestation:** Proof is issued on-chain via ProofRegistry
5. **Verifiable:** Anyone can verify the proof on-chain

## Proof Lifecycle

- **Issued:** Proof is created and stored on-chain
- **Active:** Proof is valid and can be verified
- **Revoked:** Proof issuer or owner can revoke a proof (e.g., if found to be fraudulent)

## Integration

To check if an address has a proof:

```typescript
import { BaseProof } from '@baseproof/sdk';

const client = new BaseProof({
  proofRegistryAddress: '0x...',
  chainId: 84532
});

const hasProof = await client.hasProof(address, 'BASE_CONTRACT_DEPLOYER');
```

## Adding New Proof Types

New proof types can be added by:

1. Adding definition to `proofs/definitions.yaml`
2. Implementing verification logic in indexer
3. Updating this documentation

---

**Last Updated:** 2025-01-27

