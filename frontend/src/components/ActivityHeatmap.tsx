// frontend/src/components/ActivityHeatmap.tsx
'use client'
import { useState } from 'react'
import type { ActivityDay } from '@/types'

interface Props {
  days: ActivityDay[]
}

function getColor(count: number): string {
  if (count === 0) return 'bg-neutral-900'
  if (count <= 2) return 'bg-neutral-700'
  if (count <= 4) return 'bg-neutral-500'
  if (count <= 6) return 'bg-neutral-300'
  return 'bg-white'
}

export function ActivityHeatmap({ days }: Props) {
  const [selectedCell, setSelectedCell] = useState<{ date: string; count: number } | null>(null)

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

  // Compute month labels
  const monthLabels: { label: string; weekIndex: number }[] = []
  let currentMonth = -1

  for (let i = 0; i < weeks.length; i++) {
    const week = weeks[i]
    if (!week || week.length === 0) continue
    const firstCell = week[0]
    // Use UTC to prevent timezone shifts when computing month name
    const [year, month, day] = firstCell.date.split('-').map(Number)
    const dateObj = new Date(Date.UTC(year, month - 1, day))
    const m = dateObj.getUTCMonth()
    
    // Only add a label if the month changes and we aren't too close to the previous label
    if (m !== currentMonth) {
      if (monthLabels.length === 0 || i - monthLabels[monthLabels.length - 1].weekIndex > 2) {
        monthLabels.push({
          label: dateObj.toLocaleString('default', { month: 'short', timeZone: 'UTC' }),
          weekIndex: i,
        })
      }
      currentMonth = m
    }
  }

  const totalSessions = days.reduce((sum, d) => sum + d.count, 0)
  const activeDays = days.filter(d => d.count > 0).length

  return (
    <div>
      <div className="flex items-center justify-between mb-4">
        <p className="text-sm font-medium text-white">
          {totalSessions} submissions in the last year
        </p>
        <div className="flex items-center gap-1.5 text-xs text-neutral-500 font-medium">
          <span>Less</span>
          {[0, 1, 3, 5, 7].map((n, i) => (
            <div key={i} className={`w-3 h-3 rounded-sm ${getColor(n)} border border-neutral-800`} />
          ))}
          <span>More</span>
        </div>
      </div>

      <div className="overflow-x-auto pb-2">
        <div className="inline-flex flex-col">
          {/* Months Row */}
          <div className="flex mb-1.5 relative h-4">
             <div className="w-8 shrink-0"></div>
             <div className="flex-1 relative">
               {monthLabels.map(m => (
                 <span 
                   key={m.weekIndex} 
                   className="absolute text-xs text-neutral-500 font-medium tracking-wide"
                   style={{ left: `${m.weekIndex * 16}px` }}
                 >
                   {m.label}
                 </span>
               ))}
             </div>
          </div>
          
          <div className="flex">
            {/* Days Column */}
            <div className="w-8 shrink-0 flex flex-col gap-[3px] text-xs text-neutral-500 font-medium leading-[13px] pt-[1px]">
              <div className="h-[13px]"></div>
              <div className="h-[13px]">Mon</div>
              <div className="h-[13px]"></div>
              <div className="h-[13px]">Wed</div>
              <div className="h-[13px]"></div>
              <div className="h-[13px]">Fri</div>
              <div className="h-[13px]"></div>
            </div>

            {/* Grid */}
            <div className="flex gap-[3px]">
              {weeks.map((week, wi) => (
                <div key={wi} className="flex flex-col gap-[3px]">
                  {wi === 0 && week[0]?.dayOfWeek > 0 && (
                    Array.from({ length: week[0].dayOfWeek }).map((_, i) => (
                      <div key={`pad-${i}`} className="w-[13px] h-[13px] rounded-sm bg-transparent" />
                    ))
                  )}
                  {week.map((cell) => (
                    <button
                      key={cell.date}
                      onClick={() => setSelectedCell(cell)}
                      className={`w-[13px] h-[13px] rounded-sm ${getColor(cell.count)} transition-all hover:ring-1 hover:ring-neutral-400 focus:outline-none ${selectedCell?.date === cell.date ? 'ring-2 ring-white z-10 scale-110' : 'border border-neutral-800/50'}`}
                      aria-label={`${cell.count} submissions on ${cell.date}`}
                    />
                  ))}
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>

      {/* Interactive Data Panel */}
      <div className="mt-6 p-4 border border-neutral-800 rounded-md bg-neutral-950/50 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 h-[76px]">
        {selectedCell ? (
          <div className="flex items-center gap-4 animate-fade-in">
            <div className={`w-8 h-8 rounded-sm ${getColor(selectedCell.count)} border border-neutral-700 shadow-sm shrink-0`} />
            <div>
              <p className="text-sm text-white font-semibold">
                {new Date(selectedCell.date + 'T00:00:00Z').toLocaleDateString('en-US', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric', timeZone: 'UTC' })}
              </p>
              <p className="text-sm text-neutral-400 font-mono mt-0.5">
                <span className="text-white font-bold">{selectedCell.count}</span> {selectedCell.count === 1 ? 'submission' : 'submissions'}
              </p>
            </div>
          </div>
        ) : (
          <div className="flex items-center gap-3 text-neutral-500 text-sm animate-fade-in">
            <div className="w-8 h-8 rounded-sm bg-neutral-900 border border-neutral-800 flex items-center justify-center text-xs">👆</div>
            Click on any grid cell to view its daily submission details.
          </div>
        )}
      </div>
    </div>
  )
}
