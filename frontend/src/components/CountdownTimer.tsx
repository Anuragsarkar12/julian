// frontend/src/components/CountdownTimer.tsx
'use client'
import { useState, useEffect } from 'react'

export function CountdownTimer() {
  const [timeLeft, setTimeLeft] = useState('')
  const [urgency, setUrgency] = useState<'normal' | 'warning' | 'urgent'>('normal')

  useEffect(() => {
    const update = () => {
      const now = new Date()
      const tomorrow = new Date(now)
      tomorrow.setUTCDate(tomorrow.getUTCDate() + 1)
      tomorrow.setUTCHours(0, 0, 0, 0)

      const diff = tomorrow.getTime() - now.getTime()
      const hours = Math.floor(diff / (1000 * 60 * 60))
      const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60))
      const seconds = Math.floor((diff % (1000 * 60)) / 1000)

      setTimeLeft(`${hours}h ${minutes}m ${seconds}s`)

      if (hours < 1) setUrgency('urgent')
      else if (hours < 4) setUrgency('warning')
      else setUrgency('normal')
    }

    update()
    const interval = setInterval(update, 1000)
    return () => clearInterval(interval)
  }, [])

  const colorClass =
    urgency === 'urgent' ? 'text-red-400' :
    urgency === 'warning' ? 'text-amber-400' :
    'text-slate-400'

  return (
    <span className={`font-mono text-sm tabular-nums ${colorClass}`}>
      {timeLeft || '—'}
    </span>
  )
}
