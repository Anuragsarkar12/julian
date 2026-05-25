// frontend/src/app/challenge/page.tsx
'use client'
import { useState, useEffect } from 'react'
import { useRouter } from 'next/navigation'
import Link from 'next/link'
import { ChevronLeft, Clock, AlertCircle } from 'lucide-react'
import { useMediaRecorder } from '@/hooks/useMediaRecorder'
import { useSessionPolling } from '@/hooks/useSessionPolling'
import { RecorderPanel } from '@/components/RecorderPanel'
import { getTodaysChallenge, uploadSession } from '@/lib/api'
import type { Challenge } from '@/types'

type Stage = 'loading' | 'prep' | 'record' | 'uploading' | 'analyzing' | 'error'

const PREP_SECONDS = 60

export default function ChallengePage() {
  const router = useRouter()
  const [stage, setStage]             = useState<Stage>('loading')
  const [challenge, setChallenge]     = useState<Challenge | null>(null)
  const [prepRemaining, setPrepLeft]  = useState(PREP_SECONDS)
  const [sessionId, setSessionId]     = useState<string | null>(null)
  const [uploadError, setUploadError] = useState<string | null>(null)

  const { state, audioBlob, durationSeconds, error, analyserNode,
          startRecording, stopRecording, resetRecording } = useMediaRecorder()

  const { status: pollStatus, error: pollError } = useSessionPolling(sessionId)

  // Load today's challenge
  useEffect(() => {
    getTodaysChallenge()
      .then(c => { setChallenge(c); setStage('prep') })
      .catch(() => setStage('error'))
  }, [])

  // Prep countdown timer
  useEffect(() => {
    if (stage !== 'prep') return
    if (prepRemaining <= 0) return

    const timer = setInterval(() => {
      setPrepLeft(p => {
        if (p <= 1) { clearInterval(timer); return 0 }
        return p - 1
      })
    }, 1000)

    return () => clearInterval(timer)
  }, [stage, prepRemaining])

  // Move to record stage when prep ends
  useEffect(() => {
    if (stage === 'prep' && prepRemaining === 0) {
      setStage('record')
    }
  }, [stage, prepRemaining])

  // Upload when recording stops
  useEffect(() => {
    if (state === 'stopped' && audioBlob && stage === 'record') {
      handleUpload(audioBlob)
    }
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [state, audioBlob, stage])

  // Navigate to results when analysis completes
  useEffect(() => {
    if (pollStatus?.status === 'completed' && sessionId) {
      router.push(`/results/${sessionId}`)
    }
  }, [pollStatus, sessionId, router])

  const handleUpload = async (blob: Blob) => {
    setStage('uploading')
    try {
      const { session_id } = await uploadSession(blob, challenge?.id)
      setSessionId(session_id)
      setStage('analyzing')
    } catch (e: unknown) {
      const msg = e instanceof Error ? e.message : 'Upload failed'
      setUploadError(msg)
      setStage('error')
    }
  }

  const skipPrep = () => {
    setPrepLeft(0)
    setStage('record')
  }

  return (
    <div className="min-h-screen bg-slate-950">
      <header className="border-b border-slate-800 px-6 py-4 flex items-center gap-4">
        <Link href="/dashboard" className="text-slate-400 hover:text-white transition-colors">
          <ChevronLeft className="w-5 h-5" />
        </Link>
        <span className="text-sm text-slate-400">Today&apos;s Challenge</span>
      </header>

      <main className="max-w-2xl mx-auto px-6 py-8 space-y-6">
        {stage === 'loading' && (
          <div className="text-center text-slate-500 animate-pulse py-20">Loading challenge...</div>
        )}

        {/* Challenge prompt (always visible once loaded) */}
        {challenge && stage !== 'loading' && (
          <div className="bg-slate-900 rounded-2xl border border-slate-800 p-6">
            <div className="flex gap-2 mb-4">
              <span className="text-xs px-2 py-0.5 rounded-full bg-slate-800 text-slate-400">
                {challenge.category}
              </span>
            </div>
            <p className="text-lg text-slate-100 leading-relaxed">{challenge.prompt_text}</p>
          </div>
        )}

        {/* PREP STAGE */}
        {stage === 'prep' && (
          <div className="bg-slate-900 rounded-2xl border border-slate-800 p-6 text-center space-y-6">
            <div className="flex items-center justify-center gap-2 text-slate-400">
              <Clock className="w-4 h-4" />
              <span className="text-sm">Preparation time</span>
            </div>

            {/* Countdown circle */}
            <div className="flex items-center justify-center">
              <div className="relative w-24 h-24">
                <svg className="w-full h-full -rotate-90" viewBox="0 0 96 96">
                  <circle cx="48" cy="48" r="40" fill="none" stroke="#1e293b" strokeWidth="6" />
                  <circle
                    cx="48" cy="48" r="40" fill="none"
                    stroke="#8b5cf6" strokeWidth="6"
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

            {/* Tips */}
            {challenge?.tips && challenge.tips.length > 0 && (
              <div className="text-left space-y-2">
                <p className="text-xs text-slate-500 uppercase tracking-widest">Tips</p>
                {challenge.tips.map((tip, i) => (
                  <div key={i} className="flex gap-2 text-sm text-slate-400">
                    <span className="text-violet-500 mt-0.5">•</span>
                    <span>{tip}</span>
                  </div>
                ))}
              </div>
            )}

            <button
              onClick={skipPrep}
              className="text-sm text-slate-500 hover:text-slate-300 transition-colors underline"
            >
              Skip prep, I&apos;m ready
            </button>
          </div>
        )}

        {/* RECORD STAGE */}
        {stage === 'record' && (
          <div className="bg-slate-900 rounded-2xl border border-slate-800 p-6 space-y-4">
            <p className="text-sm text-slate-400 text-center">
              {state === 'idle' ? "Click to start — speak for 30 seconds to 5 minutes" :
               state === 'recording' ? "Recording... click Stop when you're done" :
               "Recording complete — uploading now"}
            </p>
            <RecorderPanel
              state={state}
              durationSeconds={durationSeconds}
              error={error}
              analyserNode={analyserNode}
              onStart={startRecording}
              onStop={stopRecording}
              onReset={() => { resetRecording(); setStage('record') }}
              maxDurationSeconds={300}
            />
          </div>
        )}

        {/* UPLOADING STAGE */}
        {stage === 'uploading' && (
          <div className="bg-slate-900 rounded-2xl border border-slate-800 p-8 text-center space-y-4">
            <div className="w-10 h-10 border-2 border-violet-500 border-t-transparent rounded-full animate-spin mx-auto" />
            <p className="text-slate-300">Uploading your recording...</p>
          </div>
        )}

        {/* ANALYZING STAGE */}
        {stage === 'analyzing' && (
          <div className="bg-slate-900 rounded-2xl border border-slate-800 p-8 text-center space-y-4">
            <div className="w-10 h-10 border-2 border-violet-500 border-t-transparent rounded-full animate-spin mx-auto" />
            <div className="space-y-1">
              <p className="text-slate-200 font-medium">Analyzing your speech...</p>
              <p className="text-sm text-slate-500">Transcribing · Detecting fillers · Computing metrics · Generating coaching</p>
            </div>
            {pollError && (
              <p className="text-red-400 text-sm">{pollError}</p>
            )}
          </div>
        )}

        {/* ERROR STAGE */}
        {stage === 'error' && (
          <div className="bg-red-950/50 rounded-2xl border border-red-900 p-8 text-center space-y-4">
            <AlertCircle className="w-10 h-10 text-red-400 mx-auto" />
            <p className="text-red-300">{uploadError ?? 'Something went wrong. Please try again.'}</p>
            <button
              onClick={() => { setStage('record'); resetRecording(); setUploadError(null) }}
              className="px-6 py-2 border border-red-700 text-red-300 rounded-full text-sm hover:bg-red-900/50 transition-colors"
            >
              Try Again
            </button>
          </div>
        )}
      </main>
    </div>
  )
}
