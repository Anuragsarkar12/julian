// frontend/src/app/potd/page.tsx
'use client'
import { useState, useEffect } from 'react'
import { useRouter } from 'next/navigation'
import Link from 'next/link'
import { Zap, Clock, ChevronRight } from 'lucide-react'
import { useMediaRecorder } from '@/hooks/useMediaRecorder'
import { useSessionPolling } from '@/hooks/useSessionPolling'
import { RecorderPanel } from '@/components/RecorderPanel'
import { CountdownTimer } from '@/components/CountdownTimer'
import { CategoryBadge, DifficultyBadge } from '@/components/CategoryBadge'
import { ScoreRing } from '@/components/ScoreRing'
import { SkeletonCard } from '@/components/Skeleton'
import { getPOTDToday, submitPOTD, getSessionResults, getPOTDLeaderboard } from '@/lib/api'
import type { POTD, SessionResults, DailyLeaderboardEntry } from '@/types'

type Stage = 'loading' | 'prep' | 'record' | 'uploading' | 'analyzing' | 'results' | 'error'

const PREP_SECONDS = 60

export default function POTDPage() {
  const router = useRouter()
  const [potd, setPotd] = useState<POTD | null>(null)
  const [stage, setStage] = useState<Stage>('loading')
  const [prepRemaining, setPrepLeft] = useState(PREP_SECONDS)
  const [sessionId, setSessionId] = useState<string | null>(null)
  const [results, setResults] = useState<SessionResults | null>(null)
  const [leaderboard, setLeaderboard] = useState<DailyLeaderboardEntry[]>([])
  const [uploadError, setUploadError] = useState<string | null>(null)

  const { state, audioBlob, durationSeconds, error: recError, analyserNode,
    startRecording, stopRecording, resetRecording } = useMediaRecorder()
  const { status: pollStatus, error: pollError } = useSessionPolling(sessionId)

  // Load POTD
  useEffect(() => {
    Promise.allSettled([
      getPOTDToday().then(p => {
        setPotd(p)
        if (p.user_submitted && p.user_session_id) {
          setSessionId(p.user_session_id)
          getSessionResults(p.user_session_id).then(r => {
            setResults(r)
            setStage('results')
          }).catch(() => setStage('prep'))
        } else {
          setStage('prep')
        }
      }),
      getPOTDLeaderboard().then(r => setLeaderboard(r.entries)),
    ]).catch(() => setStage('error'))
  }, [])

  // Prep countdown
  useEffect(() => {
    if (stage !== 'prep' || prepRemaining <= 0) return
    const timer = setInterval(() => {
      setPrepLeft(p => { if (p <= 1) { clearInterval(timer); return 0 } return p - 1 })
    }, 1000)
    return () => clearInterval(timer)
  }, [stage, prepRemaining])

  useEffect(() => {
    if (stage === 'prep' && prepRemaining === 0) setStage('record')
  }, [stage, prepRemaining])

  // Upload on stop
  useEffect(() => {
    if (state === 'stopped' && audioBlob && stage === 'record') {
      handleUpload(audioBlob)
    }
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [state, audioBlob, stage])

  // Poll → results
  useEffect(() => {
    if (pollStatus?.status === 'completed' && sessionId) {
      getSessionResults(sessionId).then(r => {
        setResults(r)
        setStage('results')
      }).catch(() => {})
    }
  }, [pollStatus, sessionId])

  const handleUpload = async (blob: Blob) => {
    setStage('uploading')
    try {
      const { session_id } = await submitPOTD(blob)
      setSessionId(session_id)
      setStage('analyzing')
    } catch (e: unknown) {
      setUploadError(e instanceof Error ? e.message : 'Upload failed')
      setStage('error')
    }
  }

  if (stage === 'loading') {
    return (
      <div className="max-w-3xl mx-auto px-4 sm:px-6 py-8">
        <SkeletonCard className="h-64" />
      </div>
    )
  }

  return (
    <div className="max-w-3xl mx-auto px-4 sm:px-6 py-8 animate-fade-in">
      {/* Header */}
      <div className="flex items-center justify-between mb-6">
        <div className="flex items-center gap-2">
          <Zap className="w-5 h-5 text-white" />
          <h1 className="text-xl font-bold text-white">Problem of the Day</h1>
        </div>
        <div className="flex items-center gap-2 text-xs text-neutral-500">
          <Clock className="w-3.5 h-3.5" />
          <CountdownTimer />
        </div>
      </div>

      {/* Question card */}
      {potd && (
        <div className="bg-neutral-950 rounded-md border border-neutral-800 p-6 mb-6">
          <div className="flex items-center gap-2 mb-3">
            <CategoryBadge category={potd.question.category} />
            <DifficultyBadge difficulty={potd.question.difficulty} />
          </div>
          <h2 className="text-lg font-semibold text-white mb-2">{potd.question.title}</h2>
          <p className="text-sm text-neutral-300 leading-relaxed">{potd.question.prompt_text}</p>
        </div>
      )}

      {/* Prep */}
      {stage === 'prep' && (
        <div className="bg-neutral-950 rounded-md border border-neutral-800 p-6 text-left space-y-6">
          <div className="flex items-center justify-start gap-2 text-neutral-400">
            <Clock className="w-4 h-4" />
            <span className="text-sm">Preparation time</span>
          </div>
          <div className="flex items-center justify-start">
            <div className="relative w-24 h-24">
              <svg className="w-full h-full -rotate-90" viewBox="0 0 96 96">
                <circle cx="48" cy="48" r="40" fill="none" stroke="#27272a" strokeWidth="6" />
                <circle cx="48" cy="48" r="40" fill="none" stroke="#ffffff" strokeWidth="6"
                  strokeDasharray={`${2 * Math.PI * 40}`}
                  strokeDashoffset={`${2 * Math.PI * 40 * (1 - prepRemaining / PREP_SECONDS)}`}
                  strokeLinecap="round"
                  style={{ transition: 'stroke-dashoffset 1s linear' }}
                />
              </svg>
              <div className="absolute inset-0 flex items-center justify-center">
                <span className="text-2xl font-mono font-bold text-white">{prepRemaining}</span>
              </div>
            </div>
          </div>
          {potd?.question.tips && potd.question.tips.length > 0 && (
            <div className="text-left space-y-2">
              <p className="text-xs text-neutral-500 uppercase tracking-widest">Tips</p>
              {potd.question.tips.map((tip, i) => (
                <div key={i} className="flex gap-2 text-sm text-neutral-400">
                  <span className="text-white mt-0.5">•</span>
                  <span>{tip}</span>
                </div>
              ))}
            </div>
          )}
          <button
            onClick={() => { setPrepLeft(0); setStage('record') }}
            className="text-sm text-neutral-500 hover:text-neutral-300 transition-colors underline"
          >
            Skip prep, I&apos;m ready
          </button>
        </div>
      )}

      {/* Record */}
      {stage === 'record' && (
        <div className="bg-neutral-950 rounded-md border border-neutral-800 p-6 space-y-4">
          <p className="text-sm text-neutral-400 text-left">
            {state === 'idle' ? "Click to start recording" :
              state === 'recording' ? "Recording... click Stop when you're done" :
                "Processing..."}
          </p>
          <RecorderPanel
            state={state}
            durationSeconds={durationSeconds}
            error={recError}
            analyserNode={analyserNode}
            onStart={startRecording}
            onStop={stopRecording}
            onReset={() => { resetRecording(); setStage('record') }}
            maxDurationSeconds={300}
          />
        </div>
      )}

      {/* Uploading */}
      {stage === 'uploading' && (
        <div className="bg-neutral-950 rounded-md border border-neutral-800 p-8 text-left space-y-4 flex flex-col items-start">
          <div className="w-10 h-10 border-2 border-neutral-500 border-t-transparent rounded-sm animate-spin" />
          <p className="text-neutral-300">Uploading your recording...</p>
        </div>
      )}

      {/* Analyzing */}
      {stage === 'analyzing' && (
        <div className="bg-neutral-950 rounded-md border border-neutral-800 p-8 text-left space-y-4 flex flex-col items-start">
          <div className="w-10 h-10 border-2 border-neutral-500 border-t-transparent rounded-sm animate-spin" />
          <div className="space-y-1">
            <p className="text-neutral-300 font-medium">Analyzing your speech...</p>
            <p className="text-sm text-neutral-500">This usually takes 15-30 seconds</p>
          </div>
          {pollError && <p className="text-red-400 text-sm">{pollError}</p>}
        </div>
      )}

      {/* Inline Results */}
      {stage === 'results' && results && (
        <div className="space-y-6">
          {/* Score */}
          <div className="bg-neutral-950 rounded-md border border-neutral-800 p-6 text-left">
            <p className="text-xs text-neutral-500 uppercase tracking-widest mb-4">Your Score</p>
            <div className="text-6xl font-bold text-white mb-3 animate-count-up font-mono">{results.scores.total_score}</div>
            <div className="h-1.5 w-full max-w-[200px] bg-neutral-800 rounded-sm overflow-hidden">
              <div className="h-full bg-white rounded-sm" style={{ width: `${results.scores.total_score}%`, transition: 'width 1.5s ease' }} />
            </div>
          </div>

          {/* Score breakdown */}
          <div className="bg-neutral-950 rounded-md border border-neutral-800 p-6">
            <h3 className="text-sm font-semibold text-neutral-400 mb-4">Score Breakdown</h3>
            <div className="grid grid-cols-2 gap-4">
              <ScoreRing score={results.scores.delivery_score} label="Delivery" color="#8b5cf6" size={72} strokeWidth={5} />
              <ScoreRing score={results.scores.content_score} label="Content" color="#06b6d4" size={72} strokeWidth={5} />
            </div>
          </div>

          {/* AI Coaching */}
          {results.feedback.overall_summary && (
            <div className="bg-neutral-950 rounded-md border border-neutral-800 p-6">
              <h3 className="text-sm font-semibold text-neutral-300 mb-3">AI Coaching</h3>
              <p className="text-sm text-neutral-300 leading-relaxed mb-4">{results.feedback.overall_summary}</p>
              {results.feedback.coaching_tip && (
                <div className="p-3 bg-neutral-900 border border-neutral-800 rounded-md">
                  <p className="text-xs text-white font-medium mb-1">COACHING TIP</p>
                  <p className="text-sm text-neutral-300">{results.feedback.coaching_tip}</p>
                </div>
              )}
            </div>
          )}

          {/* CTAs */}
          <div className="flex gap-4">
            <Link href="/questions" className="flex-1 text-center py-3 bg-white text-black hover:bg-neutral-200 rounded-sm font-semibold transition-colors">
              Browse Questions
            </Link>
            <Link href="/dashboard" className="flex-1 text-center py-3 border border-neutral-700 hover:border-slate-500 text-neutral-300 rounded-sm transition-colors">
              Dashboard
            </Link>
          </div>
        </div>
      )}

      {/* Error */}
      {stage === 'error' && (
        <div className="bg-red-950/50 rounded-md border border-red-900 p-8 text-left space-y-4">
          <p className="text-red-300">{uploadError || 'Something went wrong'}</p>
          <button
            onClick={() => { setStage('record'); resetRecording(); setUploadError(null) }}
            className="px-6 py-2 border border-red-700 text-red-300 rounded-sm text-sm hover:bg-red-900/50 transition-colors"
          >
            Try Again
          </button>
        </div>
      )}

      {/* Daily Leaderboard */}
      {leaderboard.length > 0 && (
        <div className="bg-neutral-950 rounded-md border border-neutral-800 p-6 mt-6">
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-sm font-semibold text-neutral-300">Today&apos;s Leaderboard</h3>
            <Link href="/leaderboard" className="text-xs text-neutral-400 hover:text-white">
              View full →
            </Link>
          </div>
          <div className="space-y-1.5">
            {leaderboard.slice(0, 10).map(entry => (
              <div
                key={entry.user_id}
                className={`flex items-center gap-3 p-2.5 rounded-sm ${entry.is_current_user ? 'bg-neutral-900 border border-neutral-800' : ''}`}
              >
                <span className={`w-6 text-center text-xs font-bold ${
                  entry.rank <= 3 ? 'text-amber-400' : 'text-slate-600'
                }`}>
                  {entry.rank <= 3 ? ['🥇','🥈','🥉'][entry.rank - 1] : `#${entry.rank}`}
                </span>
                <div className="flex-1 min-w-0">
                  <span className="text-sm text-neutral-300 truncate">
                    {entry.full_name || 'Anonymous'}
                    {entry.is_current_user && <span className="text-white ml-1">(you)</span>}
                  </span>
                </div>
                <span className="text-sm font-bold text-white font-mono">{entry.score}</span>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  )
}
