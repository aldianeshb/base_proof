import express from 'express';
import cors from 'cors';
import * as dotenv from 'dotenv';
import { createPublicClient, http, parseAbi } from 'viem';
import { base, baseSepolia } from 'viem/chains';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3001;

app.use(cors());
app.use(express.json());

// Initialize viem client
const chain = (process.env.NETWORK || 'sepolia') === 'mainnet' ? base : baseSepolia;
const rpcUrl = process.env.BASE_MAINNET_RPC || process.env.BASE_SEPOLIA_RPC || 'https://sepolia.base.org';
const proofRegistryAddress = process.env.PROOF_REGISTRY_ADDRESS || '';

const client = createPublicClient({
  chain,
  transport: http(rpcUrl)
});

const PROOF_REGISTRY_ABI = parseAbi([
  'function getProofs(address subject) external view returns (uint256[])',
  'function getProof(uint256 proofId) external view returns ((bytes32,address,bytes32,uint256,address,bool))',
  'function hasProof(address subject, bytes32 proofType) external view returns (bool)',
  'function getProofTypeHolders(bytes32 proofType) external view returns (address[])',
  'function totalProofs() external view returns (uint256)'
]);

/**
 * GET /address/:addr/proofs
 * Get all proofs for an address
 */
app.get('/address/:addr/proofs', async (req, res) => {
  try {
    const { addr } = req.params;
    
    if (!proofRegistryAddress) {
      return res.status(503).json({ error: 'ProofRegistry not configured' });
    }
    
    const proofIds = await client.readContract({
      address: proofRegistryAddress as `0x${string}`,
      abi: PROOF_REGISTRY_ABI,
      functionName: 'getProofs',
      args: [addr as `0x${string}`]
    });
    
    const proofs = await Promise.all(
      (proofIds as bigint[]).map(async (id) => {
        const proof = await client.readContract({
          address: proofRegistryAddress as `0x${string}`,
          abi: PROOF_REGISTRY_ABI,
          functionName: 'getProof',
          args: [id]
        });
        
        return {
          id: id.toString(),
          proofType: proof[0],
          subject: proof[1],
          metadataHash: proof[2],
          timestamp: proof[3].toString(),
          issuer: proof[4],
          revoked: proof[5]
        };
      })
    );
    
    res.json({
      address: addr,
      proofs: proofs.filter(p => !p.revoked),
      total: proofs.length
    });
  } catch (error: any) {
    console.error('Error fetching proofs:', error);
    res.status(500).json({ error: error.message || 'Internal server error' });
  }
});

/**
 * GET /proof/:type/holders
 * Get all holders of a specific proof type
 */
app.get('/proof/:type/holders', async (req, res) => {
  try {
    const { type } = req.params;
    const proofType = type as `0x${string}`;
    
    if (!proofRegistryAddress) {
      return res.status(503).json({ error: 'ProofRegistry not configured' });
    }
    
    const holders = await client.readContract({
      address: proofRegistryAddress as `0x${string}`,
      abi: PROOF_REGISTRY_ABI,
      functionName: 'getProofTypeHolders',
      args: [proofType]
    });
    
    res.json({
      proofType: type,
      holders: (holders as `0x${string}`[]).map(h => h.toLowerCase()),
      count: (holders as `0x${string}`[]).length
    });
  } catch (error: any) {
    console.error('Error fetching holders:', error);
    res.status(500).json({ error: error.message || 'Internal server error' });
  }
});

/**
 * GET /stats
 * Get overall statistics
 */
app.get('/stats', async (req, res) => {
  try {
    if (!proofRegistryAddress) {
      return res.status(503).json({ error: 'ProofRegistry not configured' });
    }
    
    const totalProofs = await client.readContract({
      address: proofRegistryAddress as `0x${string}`,
      abi: PROOF_REGISTRY_ABI,
      functionName: 'totalProofs'
    });
    
    res.json({
      totalProofs: totalProofs.toString(),
      network: chain.name,
      contractAddress: proofRegistryAddress
    });
  } catch (error: any) {
    console.error('Error fetching stats:', error);
    res.status(500).json({ error: error.message || 'Internal server error' });
  }
});

/**
 * POST /verify
 * Verify if an address has a specific proof type
 */
app.post('/verify', async (req, res) => {
  try {
    const { address, proofType } = req.body;
    
    if (!address || !proofType) {
      return res.status(400).json({ error: 'address and proofType are required' });
    }
    
    if (!proofRegistryAddress) {
      return res.status(503).json({ error: 'ProofRegistry not configured' });
    }
    
    const hasProof = await client.readContract({
      address: proofRegistryAddress as `0x${string}`,
      abi: PROOF_REGISTRY_ABI,
      functionName: 'hasProof',
      args: [address as `0x${string}`, proofType as `0x${string}`]
    });
    
    res.json({
      address,
      proofType,
      hasProof: hasProof as boolean,
      verified: hasProof as boolean
    });
  } catch (error: any) {
    console.error('Error verifying proof:', error);
    res.status(500).json({ error: error.message || 'Internal server error' });
  }
});

/**
 * Health check
 */
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

app.listen(PORT, () => {
  console.log(`🚀 BaseProof API running on port ${PORT}`);
  console.log(`📍 Network: ${chain.name}`);
  console.log(`📋 ProofRegistry: ${proofRegistryAddress || 'Not configured'}`);
});

