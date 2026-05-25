// frontend/src/app/layout.tsx
import type { Metadata } from 'next'
import { Inter } from 'next/font/google'
import './globals.css'
import { NavBar } from '@/components/NavBar'

const inter = Inter({
  subsets: ['latin'],
  variable: '--font-inter',
})

export const metadata: Metadata = {
  title: 'Julian — AI Behavioral Interview Coach',
  description: 'Practice behavioral interview questions with AI-powered feedback. 100 curated questions, daily challenges, and real-time coaching.',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en" className={`${inter.variable} dark`}>
      <body className="bg-slate-950 text-white antialiased font-sans">
        <NavBarWrapper />
        <div className="min-h-screen">{children}</div>
      </body>
    </html>
  )
}

function NavBarWrapper() {
  // NavBar is a client component — it self-hides on landing page via useUser
  return <NavBar />
}
