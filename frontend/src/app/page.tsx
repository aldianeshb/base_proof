'use client'

import { ConnectButton } from '@rainbow-me/rainbowkit'
import { useAccount } from 'wagmi'
import { useState, useEffect } from 'react'
import Link from 'next/link'

interface Proof {
  id: string
  proofType: string
  subject: string
  metadataHash: string
  timestamp: string
  issuer: string
  revoked: boolean
}

export default function Home() {
  const { address, isConnected } = useAccount()
  const [proofs, setProofs] = useState<Proof[]>([])
  const [loading, setLoading] = useState(false)
  const [stats, setStats] = useState<any>(null)

  const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001'

  useEffect(() => {
    fetchStats()
  }, [])

  useEffect(() => {
    if (address) {
      fetchProofs(address)
    }
  }, [address])

  const fetchStats = async () => {
    try {
      const res = await fetch(`${apiUrl}/stats`)
      const data = await res.json()
      setStats(data)
    } catch (error) {
      console.error('Error fetching stats:', error)
    }
  }

  const fetchProofs = async (addr: string) => {
    setLoading(true)
    try {
      const res = await fetch(`${apiUrl}/address/${addr}/proofs`)
      const data = await res.json()
      setProofs(data.proofs || [])
    } catch (error) {
      console.error('Error fetching proofs:', error)
    } finally {
      setLoading(false)
    }
  }

  return (
    <main className="min-h-screen bg-gradient-to-b from-white to-gray-50">
      <div className="container mx-auto px-4 py-8">
        {/* Header */}
        <header className="flex justify-between items-center mb-12">
          <div>
            <h1 className="text-4xl font-bold text-gray-900 mb-2">
              BaseProof
            </h1>
            <p className="text-gray-600">
              On-chain proof-of-contribution & verifiable activity attestations for Base
            </p>
          </div>
          <ConnectButton />
        </header>

        {/* Stats */}
        {stats && (
          <div className="bg-white rounded-lg shadow-md p-6 mb-8">
            <h2 className="text-2xl font-semibold mb-4">Statistics</h2>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              <div>
                <p className="text-sm text-gray-600">Total Proofs</p>
                <p className="text-3xl font-bold text-base-blue">{stats.totalProofs || 0}</p>
              </div>
              <div>
                <p className="text-sm text-gray-600">Network</p>
                <p className="text-xl font-semibold">{stats.network || 'Base Sepolia'}</p>
              </div>
              <div>
                <p className="text-sm text-gray-600">Contract</p>
                <p className="text-sm font-mono text-gray-800 truncate">
                  {stats.contractAddress || 'Not deployed'}
                </p>
              </div>
            </div>
          </div>
        )}

        {/* Main Content */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Address Explorer */}
          <div className="lg:col-span-2 bg-white rounded-lg shadow-md p-6">
            <h2 className="text-2xl font-semibold mb-4">Your Proofs</h2>
            
            {!isConnected ? (
              <div className="text-center py-12">
                <p className="text-gray-600 mb-4">Connect your wallet to view your proofs</p>
              </div>
            ) : loading ? (
              <div className="text-center py-12">
                <p className="text-gray-600">Loading proofs...</p>
              </div>
            ) : proofs.length === 0 ? (
              <div className="text-center py-12">
                <p className="text-gray-600">No proofs found for this address</p>
              </div>
            ) : (
              <div className="space-y-4">
                {proofs.map((proof) => (
                  <div key={proof.id} className="border border-gray-200 rounded-lg p-4">
                    <div className="flex justify-between items-start">
                      <div>
                        <p className="font-semibold text-lg">{proof.proofType}</p>
                        <p className="text-sm text-gray-600 mt-1">
                          Issued: {new Date(parseInt(proof.timestamp) * 1000).toLocaleDateString()}
                        </p>
                      </div>
                      <span className="px-3 py-1 bg-green-100 text-green-800 rounded-full text-sm">
                        Verified
                      </span>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>

          {/* Sidebar */}
          <div className="space-y-6">
            {/* Proof Types */}
            <div className="bg-white rounded-lg shadow-md p-6">
              <h3 className="text-xl font-semibold mb-4">Proof Types</h3>
              <ul className="space-y-2">
                <li>
                  <Link href="/proofs/BASE_CONTRACT_DEPLOYER" className="text-base-blue hover:underline">
                    Contract Deployer
                  </Link>
                </li>
                <li>
                  <Link href="/proofs/BASE_TESTNET_USER" className="text-base-blue hover:underline">
                    Testnet User
                  </Link>
                </li>
                <li>
                  <Link href="/proofs/GOVERNANCE_PARTICIPANT" className="text-base-blue hover:underline">
                    Governance Participant
                  </Link>
                </li>
                <li>
                  <Link href="/proofs/OPEN_SOURCE_CONTRIBUTOR" className="text-base-blue hover:underline">
                    Open Source Contributor
                  </Link>
                </li>
                <li>
                  <Link href="/proofs/EARLY_BASE_USER" className="text-base-blue hover:underline">
                    Early Base User
                  </Link>
                </li>
              </ul>
            </div>

            {/* Links */}
            <div className="bg-white rounded-lg shadow-md p-6">
              <h3 className="text-xl font-semibold mb-4">Resources</h3>
              <ul className="space-y-2">
                <li>
                  <Link href="/docs" className="text-base-blue hover:underline">
                    Documentation
                  </Link>
                </li>
                <li>
                  <Link href="/integrations" className="text-base-blue hover:underline">
                    Integrations
                  </Link>
                </li>
              </ul>
            </div>
          </div>
        </div>
      </div>
    </main>
  )
}

