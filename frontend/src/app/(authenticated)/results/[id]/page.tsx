// frontend/src/app/results/[id]/page.tsx
'use client'
import { useEffect, useState } from 'react'
import Link from 'next/link'
import { useParams } from 'next/navigation'
import { ChevronLeft, Mic, BarChart2, MessageSquare } from 'lucide-react'
import { getSessionResults } from '@/lib/api'
import { ScoreRing } from '@/components/ScoreRing'
import type { SessionResults } from '@/types'

const SCORE_COLORS: Record<string, string> = {
  delivery:    '#8b5cf6',
  content:     '#06b6d4',
}

export default function ResultsPage() {
  const params = useParams()
  const id = params.id as string
  const [results, setResults] = useState<SessionResults | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError]     = useState<string | null>(null)

  useEffect(() => {
    getSessionResults(id)
      .then(setResults)
      .catch(e => setError(e.message))
      .finally(() => setLoading(false))
  }, [id])

  if (loading) return (
    <div className="min-h-screen bg-neutral-900 flex items-center justify-center">
      <div className="text-neutral-500 text-sm animate-pulse">Loading results...</div>
    </div>
  )

  if (error || !results) return (
    <div className="min-h-screen bg-neutral-900 flex items-center justify-center">
      <div className="text-center space-y-4">
        <p className="text-red-400">{error ?? 'Results not found'}</p>
        <Link href="/dashboard" className="text-white text-sm hover:underline">
          Back to Dashboard
        </Link>
      </div>
    </div>
  )

  const { scores, metrics, feedback, transcript } = results

  const fillerEntries = Object.entries(metrics.filler_words_found)
    .filter(([, count]) => count > 0)
    .sort(([, a], [, b]) => b - a)

  return (
    <div className="min-h-screen bg-neutral-900">
      <header className="border-b border-neutral-800 px-6 py-4 flex items-center gap-4">
        <Link href="/dashboard" className="text-neutral-400 hover:text-white transition-colors">
          <ChevronLeft className="w-5 h-5" />
        </Link>
        <span className="text-sm text-neutral-400">Session Results</span>
      </header>

      <main className="max-w-2xl mx-auto px-6 py-8 space-y-6">
        {/* Total Score */}
        <div className="bg-neutral-950 rounded-md border border-neutral-800 p-6 text-center">
          <p className="text-xs text-neutral-500 uppercase tracking-widest mb-4">Overall Score</p>
          <div className="text-7xl font-bold text-white mb-2">{scores.total_score}</div>
          <div className="h-1.5 w-32 mx-auto bg-neutral-900 rounded-sm overflow-hidden">
            <div
              className="h-full bg-violet-500 rounded-sm"
              style={{ width: `${scores.total_score}%`, transition: 'width 1.5s ease' }}
            />
          </div>
        </div>

        {/* Score breakdown rings */}
        <div className="bg-neutral-950 rounded-md border border-neutral-800 p-6">
          <h2 className="text-sm font-semibold text-neutral-400 mb-6">Score Breakdown</h2>
          <div className="grid grid-cols-2 gap-4">
            <ScoreRing score={scores.delivery_score}    label="Delivery"    color={SCORE_COLORS.delivery}    size={80} strokeWidth={6} />
            <ScoreRing score={scores.content_score}     label="Content"     color={SCORE_COLORS.content}     size={80} strokeWidth={6} />
          </div>
          <p className="text-xs text-slate-600 text-center mt-4">
            Delivery 50% · Content 50%
          </p>
        </div>

        {/* Delivery metrics */}
        <div className="bg-neutral-950 rounded-md border border-neutral-800 p-6">
          <div className="flex items-center gap-2 mb-4">
            <BarChart2 className="w-4 h-4 text-white" />
            <h2 className="text-sm font-semibold text-neutral-300">Delivery Metrics</h2>
          </div>
          <div className="grid grid-cols-2 gap-4">
            {[
              { label: 'Speaking Pace', value: `${Math.round(metrics.wpm)} WPM`, note: 'ideal: 110-160' },
              { label: 'Filler Words', value: String(metrics.filler_count), note: `${metrics.filler_rate.toFixed(1)}/min` },
              { label: 'Pauses', value: String(metrics.pause_count), note: `${metrics.pause_total_seconds.toFixed(0)}s total` },
              { label: 'Duration', value: `${Math.round(metrics.duration_seconds)}s`, note: `${metrics.word_count} words` },
            ].map(m => (
              <div key={m.label} className="bg-neutral-900/50 rounded-md p-4">
                <p className="text-xs text-neutral-500 mb-1">{m.label}</p>
                <p className="text-xl font-bold text-white">{m.value}</p>
                <p className="text-xs text-slate-600 mt-0.5">{m.note}</p>
              </div>
            ))}
          </div>

          {fillerEntries.length > 0 && (
            <div className="mt-4 pt-4 border-t border-neutral-800">
              <p className="text-xs text-neutral-500 mb-2">Filler word breakdown</p>
              <div className="flex flex-wrap gap-2">
                {fillerEntries.map(([word, count]) => (
                  <span key={word} className="text-xs px-2 py-1 bg-neutral-900 rounded-sm text-neutral-400">
                    &ldquo;{word}&rdquo; × {count}
                  </span>
                ))}
              </div>
            </div>
          )}
        </div>

        {/* AI Coaching */}
        <div className="bg-neutral-950 rounded-md border border-neutral-800 p-6">
          <div className="flex items-center gap-2 mb-4">
            <MessageSquare className="w-4 h-4 text-white" />
            <h2 className="text-sm font-semibold text-neutral-300">AI Coaching</h2>
            {feedback.is_fallback && (
              <span className="text-xs px-2 py-0.5 bg-amber-950 text-amber-400 rounded-sm">
                generic feedback
              </span>
            )}
          </div>

          <p className="text-neutral-300 leading-relaxed mb-4">{feedback.overall_summary}</p>

          {feedback.strengths.length > 0 && (
            <div className="mb-4">
              <p className="text-xs text-emerald-400 font-medium mb-2">STRENGTHS</p>
              <ul className="space-y-1">
                {feedback.strengths.map((s, i) => (
                  <li key={i} className="text-sm text-neutral-400 flex gap-2">
                    <span className="text-emerald-500 mt-0.5">✓</span>
                    {s}
                  </li>
                ))}
              </ul>
            </div>
          )}

          {feedback.improvements.length > 0 && (
            <div className="mb-4">
              <p className="text-xs text-amber-400 font-medium mb-2">IMPROVEMENTS</p>
              <ul className="space-y-1">
                {feedback.improvements.map((imp, i) => (
                  <li key={i} className="text-sm text-neutral-400 flex gap-2">
                    <span className="text-amber-500 mt-0.5">→</span>
                    {imp}
                  </li>
                ))}
              </ul>
            </div>
          )}

          {feedback.coaching_tip && (
            <div className="mt-4 p-4 bg-violet-950/50 border border-violet-900 rounded-md">
              <p className="text-xs text-white font-medium mb-1">TODAY&apos;S COACHING TIP</p>
              <p className="text-sm text-neutral-300">{feedback.coaching_tip}</p>
            </div>
          )}

          {feedback.next_focus && (
            <p className="text-xs text-slate-600 mt-4">
              Next session focus: <span className="text-neutral-400">{feedback.next_focus}</span>
            </p>
          )}
        </div>

        {/* Transcript */}
        {transcript && (
          <div className="bg-neutral-950 rounded-md border border-neutral-800 p-6">
            <div className="flex items-center gap-2 mb-4">
              <Mic className="w-4 h-4 text-white" />
              <h2 className="text-sm font-semibold text-neutral-300">Transcript</h2>
            </div>
            <p className="text-sm text-neutral-400 leading-relaxed">{transcript}</p>
          </div>
        )}

        {/* Continue CTA */}
        <div className="flex gap-4">
          <Link
            href="/challenge"
            className="flex-1 text-center py-3 bg-white text-black hover:bg-violet-500 text-white rounded-sm font-semibold transition-colors"
          >
            Practice Again
          </Link>
          <Link
            href="/dashboard"
            className="flex-1 text-center py-3 border border-neutral-700 hover:border-slate-500 text-neutral-300 rounded-sm transition-colors"
          >
            Dashboard
          </Link>
        </div>
      </main>
    </div>
  )
}
