// frontend/src/app/questions/page.tsx
'use client'
import { useEffect, useState, useCallback } from 'react'
import Link from 'next/link'
import { Search, Filter, CheckCircle2, Circle, ChevronLeft, ChevronRight } from 'lucide-react'
import { getQuestions } from '@/lib/api'
import { CategoryBadge, DifficultyBadge } from '@/components/CategoryBadge'
import { SkeletonTable } from '@/components/Skeleton'
import { EmptyState } from '@/components/EmptyState'
import type { QuestionListItem, QuestionCategory, QuestionDifficulty } from '@/types'

const ALL_CATEGORIES: QuestionCategory[] = [
  'conflict','leadership','failure','achievement','teamwork',
  'communication','problem-solving','adaptability','initiative','growth',
]

const ALL_DIFFICULTIES: QuestionDifficulty[] = ['easy', 'medium', 'hard']

export default function QuestionsPage() {
  const [questions, setQuestions] = useState<QuestionListItem[]>([])
  const [total, setTotal] = useState(0)
  const [page, setPage] = useState(1)
  const [loading, setLoading] = useState(true)

  // Filters
  const [search, setSearch] = useState('')
  const [selectedCats, setSelectedCats] = useState<string[]>([])
  const [selectedDiffs, setSelectedDiffs] = useState<string[]>([])
  const [statusFilter, setStatusFilter] = useState<string>('all')

  const limit = 25

  const fetchQuestions = useCallback(async () => {
    setLoading(true)
    try {
      const result = await getQuestions({
        category: selectedCats.length > 0 ? selectedCats.join(',') : undefined,
        difficulty: selectedDiffs.length > 0 ? selectedDiffs.join(',') : undefined,
        status: statusFilter !== 'all' ? statusFilter : undefined,
        search: search || undefined,
        page,
        limit,
      })
      setQuestions(result.questions)
      setTotal(result.total)
    } catch (e) {
      console.error('Failed to fetch questions:', e)
    } finally {
      setLoading(false)
    }
  }, [selectedCats, selectedDiffs, statusFilter, search, page])

  useEffect(() => { fetchQuestions() }, [fetchQuestions])

  // Reset page when filters change
  useEffect(() => { setPage(1) }, [selectedCats, selectedDiffs, statusFilter, search])

  const solvedCount = questions.filter(q => q.user_status === 'attempted').length
  const totalPages = Math.ceil(total / limit)

  const toggleCat = (cat: string) => {
    setSelectedCats(prev => prev.includes(cat) ? prev.filter(c => c !== cat) : [...prev, cat])
  }
  const toggleDiff = (diff: string) => {
    setSelectedDiffs(prev => prev.includes(diff) ? prev.filter(d => d !== diff) : [...prev, diff])
  }

  return (
    <div className="max-w-6xl mx-auto px-4 sm:px-6 py-8 animate-fade-in">
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-white">Question Bank</h1>
        <p className="text-sm text-neutral-400 mt-1">100 curated behavioral interview questions across 10 categories</p>
      </div>

      {/* Stats bar */}
      <div className="bg-neutral-950 rounded-md border border-neutral-800 p-4 mb-6 flex items-center gap-6">
        <div className="flex-1">
          <div className="flex items-center justify-between mb-1.5">
            <span className="text-xs text-neutral-400">Progress</span>
            <span className="text-xs font-bold text-white">{solvedCount} / {total} attempted</span>
          </div>
          <div className="h-2 bg-neutral-900 rounded-sm overflow-hidden">
            <div
              className="h-full bg-emerald-600 rounded-sm transition-all duration-700"
              style={{ width: `${total > 0 ? (solvedCount / total) * 100 : 0}%` }}
            />
          </div>
        </div>
      </div>

      {/* Filters */}
      <div className="bg-neutral-950 rounded-md border border-neutral-800 p-4 mb-6 space-y-4">
        {/* Search */}
        <div className="relative">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-neutral-500" />
          <input
            type="text"
            placeholder="Search questions..."
            value={search}
            onChange={e => setSearch(e.target.value)}
            className="w-full pl-10 pr-4 py-2 bg-neutral-900 border border-neutral-700 rounded-sm text-sm text-white placeholder:text-neutral-500 focus:outline-none focus:border-violet-500 transition-colors"
            id="questions-search"
          />
        </div>

        <div className="flex flex-wrap gap-4">
          {/* Category filters */}
          <div className="flex-1 min-w-0">
            <p className="text-xs text-neutral-500 mb-2 flex items-center gap-1">
              <Filter className="w-3 h-3" /> Category
            </p>
            <div className="flex flex-wrap gap-1.5">
              {ALL_CATEGORIES.map(cat => (
                <button
                  key={cat}
                  onClick={() => toggleCat(cat)}
                  className={`text-xs px-2.5 py-1 rounded-sm transition-all ${
                    selectedCats.includes(cat)
                      ? 'bg-white text-black'
                      : 'bg-neutral-900 text-neutral-400 hover:bg-neutral-800'
                  }`}
                >
                  {cat}
                </button>
              ))}
            </div>
          </div>

          {/* Difficulty + Status */}
          <div className="flex gap-4">
            <div>
              <p className="text-xs text-neutral-500 mb-2">Difficulty</p>
              <div className="flex gap-1.5">
                {ALL_DIFFICULTIES.map(diff => (
                  <button
                    key={diff}
                    onClick={() => toggleDiff(diff)}
                    className={`text-xs px-2.5 py-1 rounded-sm capitalize transition-all ${
                      selectedDiffs.includes(diff)
                        ? 'bg-white text-black'
                        : 'bg-neutral-900 text-neutral-400 hover:bg-neutral-800'
                    }`}
                  >
                    {diff}
                  </button>
                ))}
              </div>
            </div>
            <div>
              <p className="text-xs text-neutral-500 mb-2">Status</p>
              <div className="flex gap-1.5">
                {[
                  { value: 'all', label: 'All' },
                  { value: 'solved', label: 'Solved' },
                  { value: 'not_attempted', label: 'Unsolved' },
                ].map(s => (
                  <button
                    key={s.value}
                    onClick={() => setStatusFilter(s.value)}
                    className={`text-xs px-2.5 py-1 rounded-sm transition-all ${
                      statusFilter === s.value
                        ? 'bg-white text-black'
                        : 'bg-neutral-900 text-neutral-400 hover:bg-neutral-800'
                    }`}
                  >
                    {s.label}
                  </button>
                ))}
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Table */}
      {loading ? (
        <SkeletonTable rows={10} />
      ) : questions.length === 0 ? (
        <EmptyState
          icon="🔍"
          title="No questions found"
          description="Try adjusting your filters or search query."
        />
      ) : (
        <div className="space-y-1.5">
          {questions.map((q, i) => (
            <Link
              key={q.id}
              href={`/questions/${q.slug}`}
              className={`flex items-center gap-4 p-3.5 rounded-md border transition-all group card-hover animate-fade-in ${
                q.user_status === 'attempted'
                  ? 'border-l-emerald-500/50 border-l-[3px] border-neutral-800 bg-neutral-950'
                  : 'border-neutral-800 bg-neutral-950'
              }`}
              style={{ animationDelay: `${i * 30}ms` }}
            >
              {/* Status icon */}
              <div className="shrink-0">
                {q.user_status === 'attempted' ? (
                  <CheckCircle2 className="w-5 h-5 text-emerald-500" />
                ) : (
                  <Circle className="w-5 h-5 text-slate-700" />
                )}
              </div>

              {/* Title + category */}
              <div className="flex-1 min-w-0">
                <p className="text-sm font-medium text-neutral-300 group-hover:text-white transition-colors truncate">
                  {q.title}
                </p>
                <div className="flex items-center gap-2 mt-1">
                  <CategoryBadge category={q.category} />
                  <DifficultyBadge difficulty={q.difficulty} />
                  {q.was_potd && (
                    <span className="text-[10px] px-1.5 py-0.5 bg-violet-950 text-white rounded-sm">POTD</span>
                  )}
                </div>
              </div>

              {/* Stats */}
              <div className="hidden sm:flex items-center gap-6 text-right shrink-0">
                <div>
                  <p className="text-xs text-slate-600">Avg Score</p>
                  <p className="text-sm font-medium text-neutral-300">{q.avg_score > 0 ? Math.round(q.avg_score) : '—'}</p>
                </div>
                {q.user_best_score != null && (
                  <div>
                    <p className="text-xs text-slate-600">Your Best</p>
                    <p className="text-sm font-bold text-white">{q.user_best_score}</p>
                  </div>
                )}
              </div>

              <ChevronRight className="w-4 h-4 text-slate-700 group-hover:text-neutral-400 transition-colors shrink-0" />
            </Link>
          ))}
        </div>
      )}

      {/* Pagination */}
      {totalPages > 1 && (
        <div className="flex items-center justify-center gap-4 mt-8">
          <button
            onClick={() => setPage(p => Math.max(1, p - 1))}
            disabled={page === 1}
            className="flex items-center gap-1 text-sm text-neutral-400 hover:text-white disabled:opacity-30 disabled:hover:text-neutral-400 transition-colors"
          >
            <ChevronLeft className="w-4 h-4" /> Previous
          </button>
          <span className="text-sm text-neutral-500">
            Page {page} of {totalPages}
          </span>
          <button
            onClick={() => setPage(p => Math.min(totalPages, p + 1))}
            disabled={page === totalPages}
            className="flex items-center gap-1 text-sm text-neutral-400 hover:text-white disabled:opacity-30 disabled:hover:text-neutral-400 transition-colors"
          >
            Next <ChevronRight className="w-4 h-4" />
          </button>
        </div>
      )}
    </div>
  )
}
