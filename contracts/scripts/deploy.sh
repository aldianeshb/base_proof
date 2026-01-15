#!/bin/bash

# BaseProof Contract Deployment Script
# Usage: ./scripts/deploy.sh [sepolia|mainnet]

set -e

NETWORK=${1:-sepolia}

if [ "$NETWORK" != "sepolia" ] && [ "$NETWORK" != "mainnet" ]; then
    echo "❌ Error: Network must be 'sepolia' or 'mainnet'"
    exit 1
fi

echo "🚀 Deploying BaseProof contracts to Base $NETWORK"
echo ""

# Check if .env exists
if [ ! -f .env ]; then
    echo "❌ Error: .env file not found"
    echo "📝 Please copy .env.example to .env and fill in your values"
    exit 1
fi

# Load environment variables
source .env

# Check required variables
if [ -z "$PRIVATE_KEY" ]; then
    echo "❌ Error: PRIVATE_KEY not set in .env"
    exit 1
fi

if [ -z "$BASESCAN_API_KEY" ]; then
    echo "⚠️  Warning: BASESCAN_API_KEY not set. Contracts will not be verified."
    VERIFY_FLAG=""
else
    VERIFY_FLAG="--verify"
fi

# Set RPC URL based on network
if [ "$NETWORK" == "sepolia" ]; then
    RPC_URL="base_sepolia"
    CHAIN_ID=84532
    EXPLORER_URL="https://sepolia.basescan.org"
else
    RPC_URL="base_mainnet"
    CHAIN_ID=8453
    EXPLORER_URL="https://basescan.org"
fi

echo "📋 Configuration:"
echo "   Network: $NETWORK"
echo "   Chain ID: $CHAIN_ID"
echo "   RPC URL: $RPC_URL"
echo ""

# Export network for script
export NETWORK=$NETWORK

# Deploy contracts
echo "📦 Deploying contracts..."
forge script script/Deploy.s.sol:DeployScript \
    --rpc-url $RPC_URL \
    --broadcast \
    $VERIFY_FLAG \
    -vvv

echo ""
echo "✅ Deployment complete!"
echo ""
echo "📝 Next steps:"
echo "   1. Save the contract addresses from the output above"
echo "   2. Update backend/.env with PROOF_REGISTRY_ADDRESS"
echo "   3. Update frontend/.env.local with NEXT_PUBLIC_PROOF_REGISTRY_ADDRESS"
echo "   4. Update Vercel environment variables"
echo ""
echo "🔗 Explorer: $EXPLORER_URL"

