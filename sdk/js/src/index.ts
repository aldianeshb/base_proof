import { createPublicClient, http, parseAbi, type Address, type Hash } from 'viem';
import { base, baseSepolia } from 'viem/chains';

export interface Proof {
  id: string;
  proofType: string;
  subject: Address;
  metadataHash: Hash;
  timestamp: bigint;
  issuer: Address;
  revoked: boolean;
}

export interface BaseProofConfig {
  proofRegistryAddress: Address;
  rpcUrl?: string;
  chainId?: 8453 | 84532;
}

const PROOF_REGISTRY_ABI = parseAbi([
  'function getProofs(address subject) external view returns (uint256[])',
  'function getProof(uint256 proofId) external view returns ((bytes32,address,bytes32,uint256,address,bool))',
  'function hasProof(address subject, bytes32 proofType) external view returns (bool)',
  'function getProofsByType(address subject, bytes32 proofType) external view returns (uint256[])',
  'function getProofTypeHolders(bytes32 proofType) external view returns (address[])',
  'function totalProofs() external view returns (uint256)'
]);

/**
 * BaseProof SDK Client
 * 
 * @example
 * ```ts
 * import { BaseProof } from '@baseproof/sdk';
 * 
 * const client = new BaseProof({
 *   proofRegistryAddress: '0x...',
 *   chainId: 84532 // Base Sepolia
 * });
 * 
 * const hasProof = await client.hasProof(address, 'BASE_CONTRACT_DEPLOYER');
 * ```
 */
export class BaseProof {
  private client: ReturnType<typeof createPublicClient>;
  private proofRegistryAddress: Address;

  constructor(config: BaseProofConfig) {
    const chain = config.chainId === 8453 ? base : baseSepolia;
    
    this.proofRegistryAddress = config.proofRegistryAddress;
    
    this.client = createPublicClient({
      chain,
      transport: http(config.rpcUrl || chain.rpcUrls.default.http[0])
    });
  }

  /**
   * Check if an address has a specific proof type
   * 
   * @param address Subject address
   * @param proofType Proof type (e.g., 'BASE_CONTRACT_DEPLOYER')
   * @returns True if address has a valid (non-revoked) proof
   */
  async hasProof(address: Address, proofType: string): Promise<boolean> {
    const proofTypeHash = this.hashProofType(proofType);
    
    const result = await this.client.readContract({
      address: this.proofRegistryAddress,
      abi: PROOF_REGISTRY_ABI,
      functionName: 'hasProof',
      args: [address, proofTypeHash]
    });
    
    return result as boolean;
  }

  /**
   * Get all proofs for an address
   * 
   * @param address Subject address
   * @returns Array of Proof objects
   */
  async getProofs(address: Address): Promise<Proof[]> {
    const proofIds = await this.client.readContract({
      address: this.proofRegistryAddress,
      abi: PROOF_REGISTRY_ABI,
      functionName: 'getProofs',
      args: [address]
    });

    const proofs = await Promise.all(
      (proofIds as bigint[]).map(async (id) => {
        const proof = await this.client.readContract({
          address: this.proofRegistryAddress,
          abi: PROOF_REGISTRY_ABI,
          functionName: 'getProof',
          args: [id]
        });

        return {
          id: id.toString(),
          proofType: this.unhashProofType(proof[0] as Hash),
          subject: proof[1] as Address,
          metadataHash: proof[2] as Hash,
          timestamp: proof[3] as bigint,
          issuer: proof[4] as Address,
          revoked: proof[5] as boolean
        };
      })
    );

    return proofs.filter(p => !p.revoked);
  }

  /**
   * Get proofs of a specific type for an address
   * 
   * @param address Subject address
   * @param proofType Proof type
   * @returns Array of proof IDs
   */
  async getProofsByType(address: Address, proofType: string): Promise<string[]> {
    const proofTypeHash = this.hashProofType(proofType);
    
    const proofIds = await this.client.readContract({
      address: this.proofRegistryAddress,
      abi: PROOF_REGISTRY_ABI,
      functionName: 'getProofsByType',
      args: [address, proofTypeHash]
    });

    return (proofIds as bigint[]).map(id => id.toString());
  }

  /**
   * Get all holders of a specific proof type
   * 
   * @param proofType Proof type
   * @returns Array of addresses that hold this proof type
   */
  async getProofTypeHolders(proofType: string): Promise<Address[]> {
    const proofTypeHash = this.hashProofType(proofType);
    
    const holders = await this.client.readContract({
      address: this.proofRegistryAddress,
      abi: PROOF_REGISTRY_ABI,
      functionName: 'getProofTypeHolders',
      args: [proofTypeHash]
    });

    return holders as Address[];
  }

  /**
   * Get total number of proofs issued
   * 
   * @returns Total proof count
   */
  async getTotalProofs(): Promise<bigint> {
    const total = await this.client.readContract({
      address: this.proofRegistryAddress,
      abi: PROOF_REGISTRY_ABI,
      functionName: 'totalProofs'
    });

    return total as bigint;
  }

  /**
   * Hash a proof type string to bytes32
   */
  private hashProofType(proofType: string): Hash {
    // In production, use keccak256
    // For now, simple hash
    const encoder = new TextEncoder();
    const data = encoder.encode(proofType);
    // This is a simplified version - in production use proper keccak256
    return `0x${Buffer.from(data).toString('hex').padStart(64, '0')}` as Hash;
  }

  /**
   * Unhash a proof type (simplified - in production would need reverse lookup)
   */
  private unhashProofType(hash: Hash): string {
    // In production, maintain a mapping or use events
    return hash; // Simplified
  }
}

// Export convenience function
export function createBaseProof(config: BaseProofConfig): BaseProof {
  return new BaseProof(config);
}

