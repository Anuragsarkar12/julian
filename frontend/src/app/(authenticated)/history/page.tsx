// frontend/src/app/history/page.tsx
'use client'
import { useEffect, useState } from 'react'
import Link from 'next/link'
import { ChevronLeft, ChevronRight, Clock } from 'lucide-react'
import { getHistory } from '@/lib/api'
import type { HistorySession } from '@/types'
import { format } from 'date-fns'

export default function HistoryPage() {
  const [sessions, setSessions] = useState<HistorySession[]>([])
  const [loading, setLoading]   = useState(true)

  useEffect(() => {
    getHistory()
      .then(d => setSessions(d.sessions.reverse())) // newest first for list view
      .catch(console.error)
      .finally(() => setLoading(false))
  }, [])

  const scoreColor = (score: number) => {
    if (score >= 80) return 'text-emerald-400'
    if (score >= 60) return 'text-amber-400'
    return 'text-red-400'
  }

  return (
    <div className="min-h-screen bg-neutral-900">
      <header className="border-b border-neutral-800 px-6 py-4 flex items-center gap-4">
        <Link href="/dashboard" className="text-neutral-400 hover:text-white transition-colors">
          <ChevronLeft className="w-5 h-5" />
        </Link>
        <span className="font-semibold text-white">Session History</span>
      </header>

      <main className="max-w-2xl mx-auto px-6 py-6">
        {loading ? (
          <div className="text-center text-neutral-500 text-sm animate-pulse py-20">Loading...</div>
        ) : sessions.length === 0 ? (
          <div className="text-center py-20 space-y-3">
            <Clock className="w-10 h-10 text-slate-700 mx-auto" />
            <p className="text-neutral-500">No sessions yet.</p>
            <Link href="/challenge" className="text-white text-sm hover:underline">
              Complete your first challenge
            </Link>
          </div>
        ) : (
          <div className="space-y-2">
            {sessions.map(session => (
              <Link
                key={session.session_id}
                href={`/results/${session.session_id}`}
                className="flex items-center gap-4 p-4 bg-neutral-950 rounded-md border border-neutral-800 hover:border-slate-600 transition-colors"
              >
                <div className={`text-2xl font-bold w-12 text-center ${scoreColor(session.total_score)}`}>
                  {session.total_score}
                </div>

                <div className="flex-1 min-w-0">
                  <p className="text-sm text-neutral-300">
                    {format(new Date(session.created_at), 'MMM d, yyyy · h:mm a')}
                  </p>
                  <p className="text-xs text-neutral-500">
                    {Math.round(session.wpm)} WPM · {session.filler_count} fillers
                  </p>
                </div>

                <ChevronRight className="w-4 h-4 text-slate-600" />
              </Link>
            ))}
          </div>
        )}
      </main>
    </div>
  )
}
