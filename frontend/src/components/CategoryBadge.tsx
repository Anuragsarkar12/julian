// frontend/src/components/CategoryBadge.tsx

import type { QuestionCategory, QuestionDifficulty } from '@/types'

const CATEGORY_COLORS: Record<QuestionCategory, { bg: string; text: string }> = {
  conflict:          { bg: 'bg-red-950/60',    text: 'text-red-400' },
  leadership:        { bg: 'bg-blue-950/60',   text: 'text-blue-400' },
  failure:           { bg: 'bg-orange-950/60',  text: 'text-orange-400' },
  achievement:       { bg: 'bg-amber-950/60',   text: 'text-amber-400' },
  teamwork:          { bg: 'bg-emerald-950/60', text: 'text-emerald-400' },
  communication:     { bg: 'bg-cyan-950/60',    text: 'text-cyan-400' },
  'problem-solving': { bg: 'bg-purple-950/60',  text: 'text-purple-400' },
  adaptability:      { bg: 'bg-teal-950/60',    text: 'text-teal-400' },
  initiative:        { bg: 'bg-lime-950/60',    text: 'text-lime-400' },
  growth:            { bg: 'bg-pink-950/60',    text: 'text-pink-400' },
}

const DIFFICULTY_COLORS: Record<QuestionDifficulty, { bg: string; text: string }> = {
  easy:   { bg: 'bg-emerald-950/60', text: 'text-emerald-400' },
  medium: { bg: 'bg-amber-950/60',   text: 'text-amber-400' },
  hard:   { bg: 'bg-red-950/60',     text: 'text-red-400' },
}

export function CategoryBadge({ category }: { category: QuestionCategory }) {
  const color = CATEGORY_COLORS[category] || { bg: 'bg-slate-800', text: 'text-slate-400' }
  return (
    <span className={`text-xs px-2 py-0.5 rounded-full font-medium ${color.bg} ${color.text}`}>
      {category}
    </span>
  )
}

export function DifficultyBadge({ difficulty }: { difficulty: QuestionDifficulty }) {
  const color = DIFFICULTY_COLORS[difficulty]
  return (
    <span className={`text-xs px-2 py-0.5 rounded-full font-medium ${color.bg} ${color.text}`}>
      {difficulty}
    </span>
  )
}
