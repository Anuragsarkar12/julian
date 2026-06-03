// frontend/src/app/page.tsx
'use client'
import { createClient } from '@/lib/supabase/client'
import { Mic, TrendingUp, Zap } from 'lucide-react'
import { useRouter } from 'next/navigation'
import { useUser } from '@/hooks/useUser'
import { useEffect } from 'react'

export default function LandingPage() {
  const supabase = createClient()
  const { user, loading } = useUser()
  const router = useRouter()

  useEffect(() => {
    if (!loading && user) {
      router.push('/dashboard')
    }
  }, [user, loading, router])

  const handleGoogleSignIn = async () => {
    await supabase.auth.signInWithOAuth({
      provider: 'google',
      options: {
        redirectTo: `${window.location.origin}/auth/callback`,
      },
    })
  }

  return (
    <div className="min-h-screen bg-black flex flex-col">
      {/* Nav */}
      <nav className="flex items-center justify-between px-6 py-4 border-b border-zinc-800">
        <span className="text-xl font-bold text-white tracking-tight">Julian</span>
        <button
          onClick={handleGoogleSignIn}
          className="px-4 py-2 text-sm font-medium text-zinc-400 hover:text-white transition-colors"
        >
          Sign in
        </button>
      </nav>

      {/* Hero */}
      <main className="flex-1 flex flex-col items-start justify-center px-6 md:px-12 max-w-5xl">
        <div className="space-y-6 max-w-2xl text-left">
          <div className="inline-flex items-center gap-2 px-3 py-1 rounded-sm bg-zinc-900 border border-zinc-800 text-zinc-300 text-xs font-mono uppercase tracking-widest">
            <Zap className="w-3 h-3 text-zinc-400" />
            Precision Speech Coaching
          </div>

          <h1 className="text-5xl sm:text-7xl font-bold tracking-tight text-white leading-tight">
            Master your delivery<br />
            <span className="text-zinc-500">Backed by data</span>
          </h1>

          <p className="text-lg text-zinc-400 max-w-lg leading-relaxed">
            Practice behavioral questions and get detailed, data-driven feedback on your pacing, filler words, and delivery in under 30 seconds.
          </p>

          <div className="pt-4 flex flex-col sm:flex-row items-start gap-4">
            <button
              onClick={handleGoogleSignIn}
              className="inline-flex items-center gap-3 px-6 py-3 bg-white text-black hover:bg-zinc-200 rounded-md font-semibold text-sm transition-colors border border-transparent"
            >
              <svg viewBox="0 0 24 24" className="w-5 h-5">
                <path fill="currentColor" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z" />
                <path fill="currentColor" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" />
                <path fill="currentColor" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z" />
                <path fill="currentColor" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" />
              </svg>
              Continue with Google
            </button>
            <span className="text-xs text-zinc-600 mt-3 sm:mt-0 sm:self-center font-mono uppercase tracking-widest"></span>
          </div>
        </div>

        {/* Feature Grid */}
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-6 mt-24 w-full">
          {[
            {
              icon: <Mic className="w-5 h-5 text-zinc-300" />,
              title: "Daily Practice",
              desc: "New behavioral interview prompt every day. 60 seconds to prepare, then speak.",
            },
            {
              icon: <Zap className="w-5 h-5 text-zinc-300" />,
              title: "Instant Feedback",
              desc: "Transcript, filler words, pace, pauses — full coaching in under 30 seconds.",
            },
            {
              icon: <TrendingUp className="w-5 h-5 text-zinc-300" />,
              title: "Track Your Progress",
              desc: "Score history, streak counter, weekly leaderboard — the Strava of speaking.",
            },
          ].map((f, i) => (
            <div key={i} className="p-6 rounded-md bg-zinc-950 border border-zinc-800 text-left flex flex-col items-start gap-4">
              <div className="w-10 h-10 rounded-sm bg-zinc-900 border border-zinc-800 flex items-center justify-center">
                {f.icon}
              </div>
              <div>
                <h3 className="font-semibold text-white tracking-tight mb-1">{f.title}</h3>
                <p className="text-sm text-zinc-500 leading-relaxed">{f.desc}</p>
              </div>
            </div>
          ))}
        </div>
      </main>
    </div>
  )
}
