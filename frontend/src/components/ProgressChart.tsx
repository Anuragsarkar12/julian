// frontend/src/components/ProgressChart.tsx
'use client'
import {
  LineChart, Line, XAxis, YAxis, CartesianGrid,
  Tooltip, ResponsiveContainer
} from 'recharts'
import type { HistorySession } from '@/types'
import { format } from 'date-fns'

interface Props { sessions: HistorySession[] }

export function ProgressChart({ sessions }: Props) {
  if (sessions.length === 0) {
    return (
      <div className="flex items-center justify-center h-40 text-neutral-500 text-sm">
        No sessions yet. Complete your first challenge to see progress.
      </div>
    )
  }

  const data = sessions.map(s => ({
    date: format(new Date(s.created_at), 'MMM d'),
    score: s.total_score,
  }))

  return (
    <ResponsiveContainer width="100%" height={160}>
      <LineChart data={data} margin={{ top: 5, right: 5, bottom: 5, left: -20 }}>
        <CartesianGrid strokeDasharray="3 3" stroke="#27272a" />
        <XAxis dataKey="date" tick={{ fill: '#71717a', fontSize: 11 }} />
        <YAxis domain={[0, 100]} tick={{ fill: '#71717a', fontSize: 11 }} />
        <Tooltip
          contentStyle={{ background: '#09090b', border: '1px solid #27272a', borderRadius: 4 }}
          labelStyle={{ color: '#a1a1aa' }}
          itemStyle={{ color: '#ffffff' }}
        />
        <Line
          type="monotone" dataKey="score" stroke="#ffffff" strokeWidth={2}
          dot={{ fill: '#ffffff', r: 3 }} activeDot={{ r: 5 }}
        />
      </LineChart>
    </ResponsiveContainer>
  )
}
