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

      ctx.fillStyle = 'rgb(0, 0, 0)'  // black
      ctx.fillRect(0, 0, canvas.width, canvas.height)

      const barW = (canvas.width / bufLen) * 2.5
      let x = 0
      for (let i = 0; i < bufLen; i++) {
        const h = (dataArr[i] / 255) * canvas.height
        ctx.fillStyle = 'rgba(255, 255, 255, 0.8)'
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
        className="w-full rounded-sm bg-neutral-900 border border-neutral-800"
      />

      {/* Duration + progress bar */}
      {state !== 'idle' && state !== 'requesting' && (
        <div className="w-full space-y-2">
          <div className="flex justify-between text-sm text-neutral-500">
            <span className="font-mono font-bold text-white text-2xl">
              {formatTime(durationSeconds)}
            </span>
            <span>max {formatTime(maxDurationSeconds)}</span>
          </div>
          <div className="h-1.5 w-full bg-neutral-800 rounded-sm overflow-hidden">
            <div
              className="h-full bg-white rounded-sm transition-all duration-1000"
              style={{ width: `${Math.min(pct, 100)}%` }}
            />
          </div>
        </div>
      )}

      {/* Error message */}
      {error && (
        <div className="flex items-start gap-3 w-full bg-red-950/50 border border-red-900 rounded-md p-4">
          <AlertCircle className="w-5 h-5 text-red-400 mt-0.5 flex-shrink-0" />
          <p className="text-sm text-red-300">{error}</p>
        </div>
      )}

      {/* Controls */}
      <div className="flex items-center gap-4">
        {state === 'idle' && (
          <button
            onClick={onStart}
            className="flex items-center gap-3 px-8 py-4 bg-white hover:bg-neutral-200
                       text-black rounded-md font-semibold text-base transition-colors"
          >
            <Mic className="w-5 h-5" />
            Start Recording
          </button>
        )}

        {state === 'requesting' && (
          <p className="text-neutral-500 text-sm animate-pulse">
            Requesting microphone access...
          </p>
        )}

        {state === 'recording' && (
          <button
            onClick={onStop}
            className="flex items-center gap-3 px-8 py-4 bg-red-600 hover:bg-red-500
                       text-white rounded-md font-semibold text-base transition-colors"
          >
            <Square className="w-4 h-4 fill-white" />
            Stop Recording
          </button>
        )}

        {(state === 'stopped' || state === 'error') && (
          <button
            onClick={onReset}
            className="flex items-center gap-2 px-6 py-3 border border-neutral-700
                       hover:border-neutral-500 text-neutral-300 hover:text-white
                       rounded-md text-sm transition-colors"
          >
            <RotateCcw className="w-4 h-4" />
            Record Again
          </button>
        )}
      </div>
    </div>
  )
}
