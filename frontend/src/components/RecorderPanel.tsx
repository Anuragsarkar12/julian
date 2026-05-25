// frontend/src/components/RecorderPanel.tsx
'use client'
import { useEffect, useRef } from 'react'
import { Mic, Square, RotateCcw, AlertCircle } from 'lucide-react'
import type { RecordingState } from '@/hooks/useMediaRecorder'

interface Props {
  state: RecordingState
  durationSeconds: number
  error: string | null
  analyserNode: AnalyserNode | null
  onStart: () => void
  onStop: () => void
  onReset: () => void
  maxDurationSeconds?: number
}

export function RecorderPanel({
  state, durationSeconds, error, analyserNode,
  onStart, onStop, onReset, maxDurationSeconds = 300
}: Props) {
  const canvasRef = useRef<HTMLCanvasElement>(null)
  const animRef   = useRef<number>(0)

  // Audio visualizer
  useEffect(() => {
    if (!analyserNode || !canvasRef.current || state !== 'recording') return

    const canvas  = canvasRef.current
    const ctx     = canvas.getContext('2d')!
    const bufLen  = analyserNode.frequencyBinCount
    const dataArr = new Uint8Array(bufLen)

    const draw = () => {
      animRef.current = requestAnimationFrame(draw)
      analyserNode.getByteFrequencyData(dataArr)

      ctx.fillStyle = 'rgb(2, 6, 23)'  // slate-950
      ctx.fillRect(0, 0, canvas.width, canvas.height)

      const barW = (canvas.width / bufLen) * 2.5
      let x = 0
      for (let i = 0; i < bufLen; i++) {
        const h = (dataArr[i] / 255) * canvas.height
        const hue = 258 + (i / bufLen) * 20  // violet-to-purple range
        ctx.fillStyle = `hsla(${hue}, 70%, 60%, 0.9)`
        ctx.fillRect(x, canvas.height - h, barW - 1, h)
        x += barW
      }
    }
    draw()

    return () => cancelAnimationFrame(animRef.current)
  }, [analyserNode, state])

  const formatTime = (s: number) =>
    `${Math.floor(s / 60)}:${String(s % 60).padStart(2, '0')}`

  const pct = (durationSeconds / maxDurationSeconds) * 100

  return (
    <div className="flex flex-col items-center gap-6 w-full">
      {/* Visualizer canvas */}
      <canvas
        ref={canvasRef}
        width={480}
        height={80}
        className="w-full rounded-xl bg-slate-950 border border-slate-800"
      />

      {/* Duration + progress bar */}
      {state !== 'idle' && state !== 'requesting' && (
        <div className="w-full space-y-2">
          <div className="flex justify-between text-sm text-slate-400">
            <span className="font-mono font-bold text-violet-400 text-2xl">
              {formatTime(durationSeconds)}
            </span>
            <span>max {formatTime(maxDurationSeconds)}</span>
          </div>
          <div className="h-1.5 w-full bg-slate-800 rounded-full overflow-hidden">
            <div
              className="h-full bg-violet-500 rounded-full transition-all duration-1000"
              style={{ width: `${Math.min(pct, 100)}%` }}
            />
          </div>
        </div>
      )}

      {/* Error message */}
      {error && (
        <div className="flex items-start gap-3 w-full bg-red-950/50 border border-red-900 rounded-xl p-4">
          <AlertCircle className="w-5 h-5 text-red-400 mt-0.5 flex-shrink-0" />
          <p className="text-sm text-red-300">{error}</p>
        </div>
      )}

      {/* Controls */}
      <div className="flex items-center gap-4">
        {state === 'idle' && (
          <button
            onClick={onStart}
            className="flex items-center gap-3 px-8 py-4 bg-violet-600 hover:bg-violet-500
                       text-white rounded-full font-semibold text-base transition-all
                       hover:scale-105 shadow-lg shadow-violet-900/40"
          >
            <Mic className="w-5 h-5" />
            Start Recording
          </button>
        )}

        {state === 'requesting' && (
          <p className="text-slate-400 text-sm animate-pulse">
            Requesting microphone access...
          </p>
        )}

        {state === 'recording' && (
          <button
            onClick={onStop}
            className="flex items-center gap-3 px-8 py-4 bg-red-600 hover:bg-red-500
                       text-white rounded-full font-semibold text-base transition-all
                       shadow-lg shadow-red-900/40"
          >
            <Square className="w-4 h-4 fill-white" />
            Stop Recording
          </button>
        )}

        {(state === 'stopped' || state === 'error') && (
          <button
            onClick={onReset}
            className="flex items-center gap-2 px-6 py-3 border border-slate-700
                       hover:border-slate-500 text-slate-300 hover:text-white
                       rounded-full text-sm transition-all"
          >
            <RotateCcw className="w-4 h-4" />
            Record Again
          </button>
        )}
      </div>
    </div>
  )
}
