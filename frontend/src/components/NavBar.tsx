// frontend/src/components/NavBar.tsx
'use client'
import { useState, useEffect } from 'react'
import Link from 'next/link'
import { usePathname } from 'next/navigation'
import { Menu, X, ChevronDown, LogOut, User, BarChart3, Flame, Trophy } from 'lucide-react'
import { useUser } from '@/hooks/useUser'

const NAV_LINKS = [
  { href: '/dashboard', label: 'Home' },
  { href: '/questions', label: 'Questions' },
  { href: '/potd', label: 'Daily Challenge', badge: '⚡' },
  { href: '/leaderboard', label: 'Leaderboard' },
]

export function NavBar() {
  const { user, signOut } = useUser()
  const pathname = usePathname()
  const [mobileOpen, setMobileOpen] = useState(false)
  const [dropdownOpen, setDropdownOpen] = useState(false)

  // Close mobile menu on route change
  useEffect(() => { setMobileOpen(false); setDropdownOpen(false) }, [pathname])

  if (!user) return null

  const displayName = user.user_metadata?.full_name || user.email?.split('@')[0] || 'User'
  const avatarUrl = user.user_metadata?.avatar_url
  const initials = displayName.charAt(0).toUpperCase()
  const currentStreak = user.user_metadata?.current_streak || 0

  return (
    <nav className="sticky top-0 z-50 border-b border-neutral-800 bg-neutral-900/80 backdrop-blur-xl">
      <div className="max-w-7xl mx-auto px-4 sm:px-6">
        <div className="flex items-center justify-between h-14">
          {/* Logo */}
          <Link href="/dashboard" className="flex items-center group">
            <span className="text-white font-semibold">Julian</span>
          </Link>

          {/* Desktop nav links */}
          <div className="hidden md:flex items-center gap-1">
            {NAV_LINKS.map(link => {
              const isActive = pathname === link.href || pathname.startsWith(link.href + '/')
              return (
                <Link
                  key={link.href}
                  href={link.href}
                  className={`px-3 py-1.5 rounded-sm text-sm font-medium transition-all flex items-center gap-1.5 ${
                    isActive
                      ? 'bg-neutral-800 text-white'
                      : 'text-neutral-500 hover:text-white hover:bg-neutral-900/50'
                  }`}
                >
                  {link.label}
                  {link.badge && (
                    <span className="text-xs">{link.badge}</span>
                  )}
                </Link>
              )
            })}
          </div>

          {/* Right side: streak + avatar dropdown */}
          <div className="flex items-center gap-3">
            {/* Streak indicator */}
            <div className="hidden sm:flex items-center gap-1 text-sm">
              <Flame className="w-4 h-4 text-orange-400" />
              <span className="text-neutral-400 font-medium font-mono" id="nav-streak">{currentStreak}</span>
            </div>

            {/* Avatar dropdown */}
            <div className="relative">
              <button
                onClick={() => setDropdownOpen(!dropdownOpen)}
                className="flex items-center gap-2 px-2 py-1 rounded-sm hover:bg-neutral-900/50 transition-colors"
                id="nav-avatar-btn"
              >
                {avatarUrl ? (
                  <img src={avatarUrl} alt="" className="w-7 h-7 rounded-sm border border-neutral-700" />
                ) : (
                  <div className="w-7 h-7 rounded-sm bg-white flex items-center justify-center text-black text-xs font-bold">
                    {initials}
                  </div>
                )}
                <ChevronDown className={`w-3.5 h-3.5 text-neutral-500 transition-transform ${dropdownOpen ? 'rotate-180' : ''}`} />
              </button>

              {dropdownOpen && (
                <>
                  <div className="fixed inset-0 z-40" onClick={() => setDropdownOpen(false)} />
                  <div className="absolute right-0 top-full mt-2 w-52 bg-neutral-950 border border-neutral-800 rounded-md shadow-xl z-50 py-1 animate-in fade-in slide-in-from-top-2 duration-150">
                    <div className="px-3 py-2 border-b border-neutral-800">
                      <p className="text-sm text-white font-medium truncate">{displayName}</p>
                      <p className="text-xs text-neutral-500 truncate">{user.email}</p>
                    </div>
                    <Link
                      href="/profile"
                      className="flex items-center gap-2 px-3 py-2 text-sm text-neutral-400 hover:text-white hover:bg-neutral-900/50 transition-colors"
                    >
                      <User className="w-4 h-4" /> My Profile
                    </Link>
                    <Link
                      href="/history"
                      className="flex items-center gap-2 px-3 py-2 text-sm text-neutral-400 hover:text-white hover:bg-neutral-900/50 transition-colors"
                    >
                      <BarChart3 className="w-4 h-4" /> My History
                    </Link>
                    <div className="border-t border-neutral-800 mt-1 pt-1">
                      <button
                        onClick={signOut}
                        className="w-full flex items-center gap-2 px-3 py-2 text-sm text-red-400 hover:text-red-300 hover:bg-red-950/30 transition-colors"
                        id="nav-signout-btn"
                      >
                        <LogOut className="w-4 h-4" /> Sign Out
                      </button>
                    </div>
                  </div>
                </>
              )}
            </div>

            {/* Mobile hamburger */}
            <button
              onClick={() => setMobileOpen(!mobileOpen)}
              className="md:hidden p-1.5 text-neutral-400 hover:text-white transition-colors"
              id="nav-mobile-toggle"
            >
              {mobileOpen ? <X className="w-5 h-5" /> : <Menu className="w-5 h-5" />}
            </button>
          </div>
        </div>
      </div>

      {/* Mobile nav drawer */}
      {mobileOpen && (
        <div className="md:hidden border-t border-neutral-800 bg-neutral-900/95 backdrop-blur-xl">
          <div className="px-4 py-3 space-y-1">
            {NAV_LINKS.map(link => {
              const isActive = pathname === link.href
              return (
                <Link
                  key={link.href}
                  href={link.href}
                  className={`block px-3 py-2.5 rounded-sm text-sm font-medium transition-colors ${
                    isActive
                      ? 'bg-neutral-800 text-white'
                      : 'text-neutral-500 hover:text-white hover:bg-neutral-900/50'
                  }`}
                >
                  {link.label} {link.badge || ''}
                </Link>
              )
            })}
          </div>
        </div>
      )}
    </nav>
  )
}
