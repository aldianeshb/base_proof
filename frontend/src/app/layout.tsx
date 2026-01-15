import type { Metadata } from 'next'
import { Inter } from 'next/font/google'
import './globals.css'
import { Providers } from './providers'

const inter = Inter({ subsets: ['latin'] })

export const metadata: Metadata = {
  title: 'BaseProof - On-chain Proof of Contribution',
  description: 'Verifiable on-chain proofs of meaningful actions on Base',
  // Base verification meta tag
  other: {
    'base:app_id': '69692e49effdef4d6af2c406'
  }
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <head>
        <meta name="base:app_id" content="69692e49effdef4d6af2c406" />
      </head>
      <body className={inter.className}>
        <Providers>{children}</Providers>
      </body>
    </html>
  )
}

