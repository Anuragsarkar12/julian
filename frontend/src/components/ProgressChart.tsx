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
      <div className="flex items-center justify-center h-40 text-slate-600 text-sm">
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
        <CartesianGrid strokeDasharray="3 3" stroke="#1e293b" />
        <XAxis dataKey="date" tick={{ fill: '#64748b', fontSize: 11 }} />
        <YAxis domain={[0, 100]} tick={{ fill: '#64748b', fontSize: 11 }} />
        <Tooltip
          contentStyle={{ background: '#0f172a', border: '1px solid #1e293b', borderRadius: 8 }}
          labelStyle={{ color: '#94a3b8' }}
          itemStyle={{ color: '#a78bfa' }}
        />
        <Line
          type="monotone" dataKey="score" stroke="#8b5cf6" strokeWidth={2}
          dot={{ fill: '#8b5cf6', r: 3 }} activeDot={{ r: 5 }}
        />
      </LineChart>
    </ResponsiveContainer>
  )
}
