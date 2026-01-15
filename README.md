# BaseProof

[![Built for Base](https://img.shields.io/badge/Built%20for-Base-0052FF?style=flat-square)](https://base.org)
[![Deployed on Base](https://img.shields.io/badge/Deployed%20on-Base-0052FF?style=flat-square)](https://basescan.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)](https://opensource.org/licenses/MIT)

**On-chain proof-of-contribution & verifiable activity attestations for Base**

BaseProof lets builders, users, and protocols generate **verifiable on-chain proofs** of meaningful actions on Base (building, deploying, contributing, testing, governance), without NFTs, without tokens — just clean attestations.

## 🎯 What is BaseProof?

BaseProof provides **portable reputation primitives** for the Base ecosystem. Think:

- ✅ "This address deployed 3 contracts on Base"
- ✅ "This wallet voted in governance"
- ✅ "This account tested contracts on Base Sepolia"
- ✅ "This user contributed PRs to Base repos"

**No speculation. No tokens. Just facts.**

## ✨ Features

- **On-chain Proofs:** All proofs stored on Base blockchain
- **Verifiable:** Anyone can verify proofs on-chain
- **No NFTs/Tokens:** Clean attestations without speculation
- **Open Source:** Fully open and forkable
- **SDK & API:** Easy integration for dApps
- **Multiple Proof Types:** Contract deployer, governance participant, contributor, and more

## 🏗️ Architecture

```
Action happens → proof generated → attestation stored → reusable everywhere
```

### Project Structure

```
baseproof/
├── contracts/          # Smart contracts (ProofRegistry, ProofVerifier)
├── indexer/            # Blockchain event indexer
├── backend/            # REST API
├── frontend/           # Explorer UI (Next.js)
├── sdk/                # JavaScript SDK
├── proofs/             # Proof type definitions
└── docs/               # Documentation
```

## 🚀 Quick Start

### Prerequisites

- **Node.js** ≥18.x
- **Foundry** (for smart contracts)
- **Git**

### Installation

```bash
# Clone repository
git clone https://github.com/aldianeshb/baseproof.git
cd baseproof

# Install all dependencies
npm run install:all
```

### Development

#### Smart Contracts

```bash
cd contracts

# Install OpenZeppelin
forge install OpenZeppelin/openzeppelin-contracts --no-commit

# Build
forge build

# Run tests
forge test
```

#### Backend API

```bash
cd backend

# Copy environment file
cp .env.example .env
# Edit .env with your values

# Start development server
npm run dev
# API runs on http://localhost:3001
```

#### Frontend

```bash
cd frontend

# Copy environment file
cp .env.example .env.local
# Edit .env.local with your values

# Start development server
npm run dev
# Frontend runs on http://localhost:3000
```

## 📋 Proof Types

BaseProof supports multiple proof types:

- **BASE_CONTRACT_DEPLOYER** - Deployed contracts on Base mainnet
- **BASE_TESTNET_USER** - Interacted with Base Sepolia
- **GOVERNANCE_PARTICIPANT** - Participated in Base governance
- **OPEN_SOURCE_CONTRIBUTOR** - Contributed to Base ecosystem repos
- **EARLY_BASE_USER** - Early adopter of Base

See [docs/proofs.md](./docs/proofs.md) for detailed information.

## 🔌 Integration

### Using the SDK

```typescript
import { BaseProof } from '@baseproof/sdk';

const client = new BaseProof({
  proofRegistryAddress: '0x...',
  chainId: 84532 // Base Sepolia (8453 for mainnet)
});

// Check if address has a proof
const hasProof = await client.hasProof(
  '0x1234...',
  'BASE_CONTRACT_DEPLOYER'
);

// Get all proofs for an address
const proofs = await client.getProofs('0x1234...');
```

### Using the API

```bash
# Get proofs for an address
GET /address/:addr/proofs

# Get holders of a proof type
GET /proof/:type/holders

# Verify a proof
POST /verify
{
  "address": "0x...",
  "proofType": "BASE_CONTRACT_DEPLOYER"
}

# Get statistics
GET /stats
```

See [docs/integrations.md](./docs/integrations.md) for more examples.

## 📖 Documentation

- [Proof Types](./docs/proofs.md) - Detailed proof type documentation
- [Integration Guide](./docs/integrations.md) - How to integrate BaseProof
- [API Reference](./docs/api.md) - REST API documentation (coming soon)

## 🛠️ Tech Stack

- **Smart Contracts:** Solidity 0.8.20, Foundry
- **Frontend:** Next.js 14, React, Wagmi, RainbowKit, Tailwind CSS
- **Backend:** Node.js, Express, TypeScript
- **Indexer:** TypeScript, Viem
- **SDK:** TypeScript, Viem

## 🌐 Network Information

### Base Mainnet
- **Chain ID:** 8453
- **RPC URL:** https://mainnet.base.org
- **Explorer:** https://basescan.org

### Base Sepolia (Testnet)
- **Chain ID:** 84532
- **RPC URL:** https://sepolia.base.org
- **Explorer:** https://sepolia.basescan.org

## 📦 Deployment

### Smart Contracts

```bash
cd contracts

# Deploy to Base Sepolia
forge script script/Deploy.s.sol:DeployScript \
  --rpc-url base_sepolia \
  --broadcast \
  --verify

# Deploy to Base Mainnet
forge script script/Deploy.s.sol:DeployScript \
  --rpc-url base_mainnet \
  --broadcast \
  --verify
```

### Frontend

Deploy to Vercel, Netlify, or your preferred hosting:

```bash
cd frontend
npm run build
```

## 🧪 Testing

```bash
# Test contracts
cd contracts
forge test

# Test backend
cd backend
npm test

# Test frontend
cd frontend
npm test
```

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](./LICENSE) file for details.

## 🗺️ Roadmap

### Phase 1: MVP ✅
- [x] ProofRegistry contract
- [x] 3 proof types
- [x] Base Sepolia indexer
- [x] Simple explorer UI
- [x] API + SDK
- [x] Documentation

### Phase 2: Mainnet Release
- [ ] Deploy to Base Mainnet
- [ ] Full indexer implementation
- [ ] Additional proof types
- [ ] Enhanced UI/UX
- [ ] Analytics dashboard

### Phase 3: Ecosystem Expansion
- [ ] More proof types
- [ ] Integration examples
- [ ] Community feedback
- [ ] Partnerships with Base projects

## 🙏 Acknowledgments

- Built for [Base](https://base.org) ecosystem
- Inspired by the need for portable reputation primitives
- Thanks to the Base community for feedback and support

## 📞 Contact & Links

- **GitHub:** https://github.com/aldianeshb/baseproof
- **Documentation:** https://docs.baseproof.org (coming soon)
- **Twitter:** [@BaseProof](https://twitter.com/baseproof) (coming soon)

---

**Built with ❤️ for Base**

*BaseProof - Verifiable on-chain proofs of meaningful actions on Base*

