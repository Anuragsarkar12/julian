// frontend/src/app/page.tsx
'use client'
import { createClient } from '@/lib/supabase/client'
import { Mic, TrendingUp, Zap } from 'lucide-react'

export default function LandingPage() {
  const supabase = createClient()

  const handleGoogleSignIn = async () => {
    await supabase.auth.signInWithOAuth({
      provider: 'google',
      options: {
        redirectTo: `${window.location.origin}/auth/callback`,
      },
    })
  }

  return (
    <div className="min-h-screen bg-slate-950 flex flex-col">
      {/* Nav */}
      <nav className="flex items-center justify-between px-6 py-4 border-b border-slate-800">
        <span className="text-xl font-bold text-violet-400">Julian</span>
        <button
          onClick={handleGoogleSignIn}
          className="px-4 py-2 text-sm text-slate-300 hover:text-white transition-colors"
        >
          Sign in
        </button>
      </nav>

      {/* Hero */}
      <main className="flex-1 flex flex-col items-center justify-center px-6 text-center">
        <div className="max-w-2xl mx-auto space-y-8">
          <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-violet-950 border border-violet-800 text-violet-300 text-sm">
            <Zap className="w-3 h-3" />
            AI-powered speaking coach
          </div>

          <h1 className="text-4xl sm:text-6xl font-bold tracking-tight">
            Stop winging your
            <span className="text-violet-400"> interviews.</span>
          </h1>

          <p className="text-lg text-slate-400 max-w-lg mx-auto leading-relaxed">
            Practice behavioral questions daily. Get instant AI feedback on your pace,
            filler words, and delivery. Track your improvement over time.
          </p>

          <button
            onClick={handleGoogleSignIn}
            className="inline-flex items-center gap-3 px-8 py-4 bg-violet-600 hover:bg-violet-500 text-white rounded-full font-semibold text-lg transition-all hover:scale-105 shadow-lg shadow-violet-900/50"
          >
            <svg viewBox="0 0 24 24" className="w-5 h-5">
              <path fill="currentColor" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
              <path fill="currentColor" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
              <path fill="currentColor" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"/>
              <path fill="currentColor" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/>
            </svg>
            Continue with Google
          </button>

          <p className="text-xs text-slate-600">Free forever. No credit card required.</p>
        </div>

        {/* Feature Grid */}
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-6 max-w-3xl mx-auto mt-20 w-full">
          {[
            {
              icon: <Mic className="w-5 h-5 text-violet-400" />,
              title: "Record daily",
              desc: "New behavioral interview prompt every day. 60 seconds to prepare, then speak.",
            },
            {
              icon: <Zap className="w-5 h-5 text-emerald-400" />,
              title: "Instant AI feedback",
              desc: "Transcript, filler words, pace, pauses — full coaching in under 30 seconds.",
            },
            {
              icon: <TrendingUp className="w-5 h-5 text-amber-400" />,
              title: "Track improvement",
              desc: "Score history, streak counter, weekly leaderboard — the Strava of speaking.",
            },
          ].map((f, i) => (
            <div key={i} className="p-6 rounded-2xl bg-slate-900 border border-slate-800 text-left">
              <div className="w-10 h-10 rounded-xl bg-slate-800 flex items-center justify-center mb-4">
                {f.icon}
              </div>
              <h3 className="font-semibold text-slate-100 mb-2">{f.title}</h3>
              <p className="text-sm text-slate-400 leading-relaxed">{f.desc}</p>
            </div>
          ))}
        </div>
      </main>
    </div>
  )
}
