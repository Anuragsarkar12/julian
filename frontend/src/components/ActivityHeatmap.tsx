// frontend/src/components/ActivityHeatmap.tsx
'use client'
import type { ActivityDay } from '@/types'

interface Props {
  days: ActivityDay[]
}

function getColor(count: number): string {
  if (count === 0) return 'bg-slate-800/50'
  if (count === 1) return 'bg-violet-900/60'
  if (count === 2) return 'bg-violet-700/70'
  if (count <= 4) return 'bg-violet-600/80'
  return 'bg-violet-500'
}

export function ActivityHeatmap({ days }: Props) {
  // Build a map for quick lookup
  const dayMap = new Map(days.map(d => [d.date, d.count]))

  // Generate 52 weeks of dates ending today
  const today = new Date()
  const cells: { date: string; count: number; dayOfWeek: number }[] = []

  for (let i = 364; i >= 0; i--) {
    const d = new Date(today)
    d.setDate(d.getDate() - i)
    const dateStr = d.toISOString().split('T')[0]
    cells.push({
      date: dateStr,
      count: dayMap.get(dateStr) || 0,
      dayOfWeek: d.getDay(),
    })
  }

  // Group by week
  const weeks: typeof cells[] = []
  let currentWeek: typeof cells = []
  for (const cell of cells) {
    if (cell.dayOfWeek === 0 && currentWeek.length > 0) {
      weeks.push(currentWeek)
      currentWeek = []
    }
    currentWeek.push(cell)
  }
  if (currentWeek.length > 0) weeks.push(currentWeek)

  const totalSessions = days.reduce((sum, d) => sum + d.count, 0)
  const activeDays = days.filter(d => d.count > 0).length

  return (
    <div>
      <div className="flex items-center justify-between mb-3">
        <p className="text-xs text-slate-500">
          {totalSessions} sessions across {activeDays} active days
        </p>
        <div className="flex items-center gap-1 text-xs text-slate-600">
          <span>Less</span>
          {[0, 1, 2, 3, 5].map((n, i) => (
            <div key={i} className={`w-2.5 h-2.5 rounded-sm ${getColor(n)}`} />
          ))}
          <span>More</span>
        </div>
      </div>

      <div className="overflow-x-auto">
        <div className="flex gap-[3px]" style={{ minWidth: '720px' }}>
          {weeks.map((week, wi) => (
            <div key={wi} className="flex flex-col gap-[3px]">
              {/* Pad first week if it doesn't start on Sunday */}
              {wi === 0 && week[0]?.dayOfWeek > 0 && (
                Array.from({ length: week[0].dayOfWeek }).map((_, i) => (
                  <div key={`pad-${i}`} className="w-[13px] h-[13px]" />
                ))
              )}
              {week.map((cell) => (
                <div
                  key={cell.date}
                  className={`w-[13px] h-[13px] rounded-sm ${getColor(cell.count)} transition-colors hover:ring-1 hover:ring-violet-400/50`}
                  title={`${cell.date}: ${cell.count} session${cell.count !== 1 ? 's' : ''}`}
                />
              ))}
            </div>
          ))}
        </div>
      </div>
    </div>
  )
}
