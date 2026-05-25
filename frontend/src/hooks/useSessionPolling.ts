// frontend/src/hooks/useSessionPolling.ts
import { useState, useEffect, useRef } from 'react'
import { getSessionStatus } from '@/lib/api'
import type { SessionStatus } from '@/types'

export function useSessionPolling(sessionId: string | null) {
  const [status, setStatus] = useState<SessionStatus | null>(null)
  const [error, setError]   = useState<string | null>(null)
  const intervalRef = useRef<ReturnType<typeof setInterval> | null>(null)

  useEffect(() => {
    if (!sessionId) return

    const poll = async () => {
      try {
        const data = await getSessionStatus(sessionId)
        setStatus(data)

        if (data.status === 'completed' || data.status === 'failed') {
          if (intervalRef.current) clearInterval(intervalRef.current)
          if (data.status === 'failed') {
            setError(data.error_message ?? 'Analysis failed. Please try again.')
          }
        }
      } catch (e: unknown) {
        const msg = e instanceof Error ? e.message : 'Connection error'
        setError(msg)
        if (intervalRef.current) clearInterval(intervalRef.current)
      }
    }

    poll()  // Immediate poll on mount
    intervalRef.current = setInterval(poll, 3000)

    return () => {
      if (intervalRef.current) clearInterval(intervalRef.current)
    }
  }, [sessionId])

  return { status, error }
}
