// frontend/src/app/practice/[id]/page.tsx
'use client'
import { useState, useEffect } from 'react'
import { useParams, useRouter } from 'next/navigation'
import Link from 'next/link'
import { Mic, ChevronLeft, Clock } from 'lucide-react'
import { useMediaRecorder } from '@/hooks/useMediaRecorder'
import { useSessionPolling } from '@/hooks/useSessionPolling'
import { RecorderPanel } from '@/components/RecorderPanel'
import { CategoryBadge, DifficultyBadge } from '@/components/CategoryBadge'
import { ScoreRing } from '@/components/ScoreRing'
import { SkeletonCard } from '@/components/Skeleton'
import { uploadSession, getSessionResults } from '@/lib/api'
import { createClient } from '@/lib/supabase/client'
import type { QuestionDetail, SessionResults } from '@/types'

type Stage = 'loading' | 'prep' | 'record' | 'uploading' | 'analyzing' | 'results' | 'error'

const PREP_SECONDS = 45

export default function PracticePage() {
  const { id: questionId } = useParams<{ id: string }>()
  const router = useRouter()
  const [question, setQuestion] = useState<QuestionDetail | null>(null)
  const [stage, setStage] = useState<Stage>('loading')
  const [prepRemaining, setPrepLeft] = useState(PREP_SECONDS)
  const [sessionId, setSessionId] = useState<string | null>(null)
  const [results, setResults] = useState<SessionResults | null>(null)
  const [uploadError, setUploadError] = useState<string | null>(null)

  const { state, audioBlob, durationSeconds, error: recError, analyserNode,
    startRecording, stopRecording, resetRecording } = useMediaRecorder()
  const { status: pollStatus, error: pollError } = useSessionPolling(sessionId)

  // Load question by ID
  useEffect(() => {
    const db = createClient()
    ;(async () => {
      const { data } = await db.from('questions').select('*').eq('id', questionId).single()
      if (data) {
        setQuestion(data as unknown as QuestionDetail)
        setStage('prep')
      } else {
        setStage('error')
        setUploadError('Question not found')
      }
    })()
  }, [questionId])

  // Prep countdown
  useEffect(() => {
    if (stage !== 'prep' || prepRemaining <= 0) return
    const t = setInterval(() => setPrepLeft(p => p <= 1 ? (clearInterval(t), 0) : p - 1), 1000)
    return () => clearInterval(t)
  }, [stage, prepRemaining])

  useEffect(() => {
    if (stage === 'prep' && prepRemaining === 0) setStage('record')
  }, [stage, prepRemaining])

  // Upload on stop
  useEffect(() => {
    if (state === 'stopped' && audioBlob && stage === 'record') handleUpload(audioBlob)
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [state, audioBlob, stage])

  // Poll → results
  useEffect(() => {
    if (pollStatus?.status === 'completed' && sessionId) {
      getSessionResults(sessionId).then(r => { setResults(r); setStage('results') }).catch(() => {})
    }
  }, [pollStatus, sessionId])

  const handleUpload = async (blob: Blob) => {
    setStage('uploading')
    try {
      const { session_id } = await uploadSession(blob, undefined, questionId)
      setSessionId(session_id)
      setStage('analyzing')
    } catch (e: unknown) {
      setUploadError(e instanceof Error ? e.message : 'Upload failed')
      setStage('error')
    }
  }

  const handleRetry = () => {
    resetRecording()
    setPrepLeft(PREP_SECONDS)
    setStage('prep')
    setSessionId(null)
    setResults(null)
    setUploadError(null)
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
      {/* Back */}
      <Link href="/questions" className="inline-flex items-center gap-1 text-sm text-neutral-400 hover:text-white mb-6 transition-colors">
        <ChevronLeft className="w-4 h-4" /> Back to Questions
      </Link>

      {/* Question */}
      {question && (
        <div className="bg-neutral-950 rounded-md border border-neutral-800 p-6 mb-6">
          <div className="flex items-center gap-2 mb-3">
            <CategoryBadge category={question.category} />
            <DifficultyBadge difficulty={question.difficulty} />
          </div>
          <h1 className="text-lg font-semibold text-white mb-2">{question.title}</h1>
          <p className="text-sm text-neutral-300 leading-relaxed">{question.prompt_text}</p>
        </div>
      )}

      {/* Prep */}
      {stage === 'prep' && (
        <div className="bg-neutral-950 rounded-md border border-neutral-800 p-6 text-center space-y-6">
          <div className="flex items-center justify-center gap-2 text-neutral-400">
            <Clock className="w-4 h-4" />
            <span className="text-sm">Preparation Time — {prepRemaining}s</span>
          </div>
          {question?.tips && question.tips.length > 0 && (
            <div className="text-left space-y-2">
              <p className="text-xs text-neutral-500 uppercase tracking-widest">Tips</p>
              {question.tips.map((tip: string, i: number) => (
                <p key={i} className="text-sm text-neutral-400 flex gap-2">
                  <span className="text-white">•</span>{tip}
                </p>
              ))}
            </div>
          )}
          <button
            onClick={() => { setPrepLeft(0) }}
            className="text-sm text-neutral-500 hover:text-neutral-300 transition-colors underline"
          >
            Skip, I&apos;m ready
          </button>
        </div>
      )}

      {/* Record */}
      {stage === 'record' && (
        <div className="bg-neutral-950 rounded-md border border-neutral-800 p-6">
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

      {/* Uploading / Analyzing */}
      {(stage === 'uploading' || stage === 'analyzing') && (
        <div className="bg-neutral-950 rounded-md border border-neutral-800 p-8 text-center space-y-4">
          <div className="w-10 h-10 border-2 border-violet-500 border-t-transparent rounded-sm animate-spin mx-auto" />
          <p className="text-neutral-300">{stage === 'uploading' ? 'Uploading...' : 'Analyzing your speech...'}</p>
          <p className="text-xs text-neutral-500">{stage === 'analyzing' && 'This usually takes 15-30 seconds'}</p>
          {pollError && <p className="text-red-400 text-sm">{pollError}</p>}
        </div>
      )}

      {/* Results */}
      {stage === 'results' && results && (
        <div className="space-y-6">
          <div className="bg-neutral-950 rounded-md border border-neutral-800 p-6 text-center">
            <div className="text-6xl font-bold text-white mb-3 animate-count-up">{results.scores.total_score}</div>
            <div className="h-1.5 w-32 mx-auto bg-neutral-900 rounded-sm overflow-hidden">
              <div className="h-full bg-violet-500 rounded-sm" style={{ width: `${results.scores.total_score}%`, transition: 'width 1.5s ease' }} />
            </div>
          </div>

          <div className="bg-neutral-950 rounded-md border border-neutral-800 p-6">
            <div className="grid grid-cols-4 gap-4">
              <ScoreRing score={results.scores.delivery_score} label="Delivery" color="#8b5cf6" size={72} strokeWidth={5} />
              <ScoreRing score={results.scores.content_score} label="Content" color="#06b6d4" size={72} strokeWidth={5} />
              <ScoreRing score={results.scores.improvement_score} label="Growth" color="#10b981" size={72} strokeWidth={5} />
              <ScoreRing score={results.scores.consistency_score} label="Streak" color="#f59e0b" size={72} strokeWidth={5} />
            </div>
          </div>

          {results.feedback.overall_summary && (
            <div className="bg-neutral-950 rounded-md border border-neutral-800 p-6">
              <h3 className="text-sm font-semibold text-neutral-300 mb-3">AI Coaching</h3>
              <p className="text-sm text-neutral-300 leading-relaxed mb-4">{results.feedback.overall_summary}</p>
              {results.feedback.coaching_tip && (
                <div className="p-3 bg-violet-950/50 border border-violet-900 rounded-md">
                  <p className="text-xs text-white font-medium mb-1">COACHING TIP</p>
                  <p className="text-sm text-neutral-300">{results.feedback.coaching_tip}</p>
                </div>
              )}
            </div>
          )}

          <div className="flex gap-4">
            <button
              onClick={handleRetry}
              className="flex-1 py-3 bg-white text-black hover:bg-violet-500 text-white rounded-sm font-semibold transition-colors"
            >
              Practice Again
            </button>
            <Link href="/questions" className="flex-1 text-center py-3 border border-neutral-700 hover:border-slate-500 text-neutral-300 rounded-sm transition-colors">
              Browse More
            </Link>
          </div>
        </div>
      )}

      {/* Error */}
      {stage === 'error' && (
        <div className="bg-red-950/50 rounded-md border border-red-900 p-8 text-center space-y-4">
          <p className="text-red-300">{uploadError || 'Something went wrong'}</p>
          <button onClick={handleRetry} className="px-6 py-2 border border-red-700 text-red-300 rounded-sm text-sm hover:bg-red-900/50 transition-colors">
            Try Again
          </button>
        </div>
      )}
    </div>
  )
}
