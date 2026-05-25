// frontend/src/app/questions/[slug]/page.tsx
'use client'
import { useEffect, useState } from 'react'
import Link from 'next/link'
import { useParams } from 'next/navigation'
import { ChevronLeft, ChevronDown, ChevronUp, Users, BarChart3, Lightbulb, BookOpen, Mic } from 'lucide-react'
import { getQuestion } from '@/lib/api'
import { CategoryBadge, DifficultyBadge } from '@/components/CategoryBadge'
import { SkeletonCard } from '@/components/Skeleton'
import type { QuestionDetail } from '@/types'

export default function QuestionDetailPage() {
  const { slug } = useParams<{ slug: string }>()
  const [question, setQuestion] = useState<QuestionDetail | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [tipsOpen, setTipsOpen] = useState(false)
  const [exampleOpen, setExampleOpen] = useState(false)

  useEffect(() => {
    getQuestion(slug)
      .then(setQuestion)
      .catch(e => setError(e.message))
      .finally(() => setLoading(false))
  }, [slug])

  if (loading) {
    return (
      <div className="max-w-3xl mx-auto px-4 sm:px-6 py-8">
        <SkeletonCard className="h-64" />
      </div>
    )
  }

  if (error || !question) {
    return (
      <div className="max-w-3xl mx-auto px-4 sm:px-6 py-8 text-center">
        <p className="text-red-400">{error || 'Question not found'}</p>
        <Link href="/questions" className="text-violet-400 text-sm hover:underline mt-4 inline-block">
          Back to Questions
        </Link>
      </div>
    )
  }

  return (
    <div className="max-w-3xl mx-auto px-4 sm:px-6 py-8 animate-fade-in">
      {/* Back link */}
      <Link
        href="/questions"
        className="inline-flex items-center gap-1 text-sm text-slate-400 hover:text-white transition-colors mb-6"
      >
        <ChevronLeft className="w-4 h-4" /> Back to Questions
      </Link>

      {/* Question card */}
      <div className="bg-slate-900 rounded-2xl border border-slate-800 p-6 mb-6">
        <div className="flex items-center gap-2 mb-4">
          <CategoryBadge category={question.category} />
          <DifficultyBadge difficulty={question.difficulty} />
          {question.was_potd && (
            <span className="text-[10px] px-1.5 py-0.5 bg-violet-950 text-violet-400 rounded-full">
              POTD {question.potd_date || ''}
            </span>
          )}
        </div>

        <h1 className="text-xl font-bold text-white mb-4">{question.title}</h1>
        <p className="text-slate-300 leading-relaxed text-base">{question.prompt_text}</p>
      </div>

      {/* Platform stats + user stats */}
      <div className="grid grid-cols-2 sm:grid-cols-4 gap-3 mb-6 stagger-children">
        <div className="bg-slate-900 rounded-xl border border-slate-800 p-4 animate-fade-in">
          <div className="flex items-center gap-1.5 mb-1">
            <Users className="w-3.5 h-3.5 text-slate-500" />
            <span className="text-xs text-slate-500">Attempted</span>
          </div>
          <p className="text-lg font-bold text-white">{question.times_attempted}</p>
        </div>
        <div className="bg-slate-900 rounded-xl border border-slate-800 p-4 animate-fade-in">
          <div className="flex items-center gap-1.5 mb-1">
            <BarChart3 className="w-3.5 h-3.5 text-slate-500" />
            <span className="text-xs text-slate-500">Avg Score</span>
          </div>
          <p className="text-lg font-bold text-white">{question.avg_score > 0 ? Math.round(question.avg_score) : '—'}</p>
        </div>
        <div className="bg-slate-900 rounded-xl border border-slate-800 p-4 animate-fade-in">
          <div className="flex items-center gap-1.5 mb-1">
            <Mic className="w-3.5 h-3.5 text-violet-400" />
            <span className="text-xs text-slate-500">Your Attempts</span>
          </div>
          <p className="text-lg font-bold text-white">{question.user_attempts}</p>
        </div>
        <div className="bg-slate-900 rounded-xl border border-slate-800 p-4 animate-fade-in">
          <div className="flex items-center gap-1.5 mb-1">
            <BarChart3 className="w-3.5 h-3.5 text-violet-400" />
            <span className="text-xs text-slate-500">Your Best</span>
          </div>
          <p className="text-lg font-bold text-violet-400">
            {question.user_best_score != null ? question.user_best_score : '—'}
          </p>
        </div>
      </div>

      {/* Tips accordion */}
      {question.tips.length > 0 && (
        <div className="bg-slate-900 rounded-2xl border border-slate-800 mb-4 overflow-hidden">
          <button
            onClick={() => setTipsOpen(!tipsOpen)}
            className="w-full flex items-center justify-between p-4 text-left hover:bg-slate-800/30 transition-colors"
          >
            <div className="flex items-center gap-2">
              <Lightbulb className="w-4 h-4 text-amber-400" />
              <span className="text-sm font-semibold text-slate-300">Tips for This Question</span>
            </div>
            {tipsOpen ? <ChevronUp className="w-4 h-4 text-slate-500" /> : <ChevronDown className="w-4 h-4 text-slate-500" />}
          </button>
          {tipsOpen && (
            <div className="px-4 pb-4 space-y-2 animate-fade-in">
              {question.tips.map((tip, i) => (
                <div key={i} className="flex gap-2 text-sm text-slate-400">
                  <span className="text-amber-500 mt-0.5 shrink-0">💡</span>
                  <span>{tip}</span>
                </div>
              ))}
            </div>
          )}
        </div>
      )}

      {/* Example answer accordion */}
      {question.example_answer && (
        <div className="bg-slate-900 rounded-2xl border border-slate-800 mb-6 overflow-hidden">
          <button
            onClick={() => setExampleOpen(!exampleOpen)}
            className="w-full flex items-center justify-between p-4 text-left hover:bg-slate-800/30 transition-colors"
          >
            <div className="flex items-center gap-2">
              <BookOpen className="w-4 h-4 text-emerald-400" />
              <span className="text-sm font-semibold text-slate-300">STAR Example Skeleton</span>
            </div>
            {exampleOpen ? <ChevronUp className="w-4 h-4 text-slate-500" /> : <ChevronDown className="w-4 h-4 text-slate-500" />}
          </button>
          {exampleOpen && (
            <div className="px-4 pb-4 animate-fade-in">
              <p className="text-sm text-slate-400 leading-relaxed whitespace-pre-wrap">
                {question.example_answer}
              </p>
            </div>
          )}
        </div>
      )}

      {/* CTA */}
      <Link
        href={`/practice/${question.id}`}
        className="w-full flex items-center justify-center gap-2 py-3 bg-violet-600 hover:bg-violet-500 text-white rounded-full font-semibold transition-all hover:shadow-lg hover:shadow-violet-500/25"
      >
        <Mic className="w-4 h-4" />
        Practice This Question
      </Link>
    </div>
  )
}
