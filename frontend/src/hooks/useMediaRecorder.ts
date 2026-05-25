// frontend/src/hooks/useMediaRecorder.ts
// Audio-only recording hook. Uses MediaRecorder API with audio/webm;codecs=opus.

import { useState, useRef, useCallback, useEffect } from 'react'

export type RecordingState = 'idle' | 'requesting' | 'recording' | 'stopped' | 'error'

function getAudioMimeType(): string {
  const types = [
    'audio/webm;codecs=opus',
    'audio/webm',
    'audio/ogg;codecs=opus',
    'audio/mp4',
  ]
  for (const t of types) {
    if (typeof MediaRecorder !== 'undefined' && MediaRecorder.isTypeSupported(t)) return t
  }
  return ''
}

export interface MediaRecorderHook {
  state: RecordingState
  audioBlob: Blob | null
  durationSeconds: number
  error: string | null
  analyserNode: AnalyserNode | null
  startRecording: () => Promise<void>
  stopRecording: () => void
  resetRecording: () => void
}

export function useMediaRecorder(): MediaRecorderHook {
  const [state, setState]               = useState<RecordingState>('idle')
  const [audioBlob, setAudioBlob]       = useState<Blob | null>(null)
  const [durationSeconds, setDuration]  = useState(0)
  const [error, setError]               = useState<string | null>(null)
  const [analyserNode, setAnalyser]     = useState<AnalyserNode | null>(null)

  const recorderRef  = useRef<MediaRecorder | null>(null)
  const chunksRef    = useRef<Blob[]>([])
  const timerRef     = useRef<ReturnType<typeof setInterval> | null>(null)
  const durationRef  = useRef(0)
  const audioCtxRef  = useRef<AudioContext | null>(null)
  const streamRef    = useRef<MediaStream | null>(null)

  const startRecording = useCallback(async () => {
    setState('requesting')
    setError(null)

    try {
      const stream = await navigator.mediaDevices.getUserMedia({
        audio: {
          echoCancellation: true,
          noiseSuppression: true,
          sampleRate: 44100,
        },
        video: false,  // Audio only — no camera needed
      })
      streamRef.current = stream

      // Set up Web Audio API for real-time visualizer
      const audioCtx = new AudioContext()
      audioCtxRef.current = audioCtx
      const source = audioCtx.createMediaStreamSource(stream)
      const analyser = audioCtx.createAnalyser()
      analyser.fftSize = 256
      source.connect(analyser)
      setAnalyser(analyser)

      const mimeType = getAudioMimeType()
      const recorder = new MediaRecorder(stream, mimeType ? { mimeType } : undefined)
      recorderRef.current = recorder
      chunksRef.current = []

      recorder.ondataavailable = (e) => {
        if (e.data?.size > 0) chunksRef.current.push(e.data)
      }

      recorder.onstop = () => {
        const blob = new Blob(chunksRef.current, { type: mimeType || 'audio/webm' })
        setAudioBlob(blob)
        setState('stopped')
        // Clean up stream
        stream.getTracks().forEach(t => t.stop())
        audioCtx.close()
        setAnalyser(null)
      }

      recorder.start(500)  // Emit chunks every 500ms
      setState('recording')

      durationRef.current = 0
      timerRef.current = setInterval(() => {
        durationRef.current += 1
        setDuration(durationRef.current)
      }, 1000)

    } catch (err: unknown) {
      const domErr = err as DOMException
      const messages: Record<string, string> = {
        NotAllowedError: 'Microphone access denied. Click the lock icon in your browser to allow it.',
        NotFoundError: 'No microphone found. Please connect one and try again.',
        NotReadableError: 'Microphone is in use by another app. Close it and try again.',
        AbortError: 'Microphone access was interrupted. Please try again.',
      }
      setError(messages[domErr.name] ?? `Recording failed: ${domErr.message}`)
      setState('error')
    }
  }, [])

  const stopRecording = useCallback(() => {
    if (recorderRef.current && state === 'recording') {
      recorderRef.current.stop()
      if (timerRef.current) clearInterval(timerRef.current)
    }
  }, [state])

  const resetRecording = useCallback(() => {
    setAudioBlob(null)
    setDuration(0)
    setError(null)
    setState('idle')
    chunksRef.current = []
    durationRef.current = 0
    setAnalyser(null)
    if (streamRef.current) {
      streamRef.current.getTracks().forEach(t => t.stop())
      streamRef.current = null
    }
    if (audioCtxRef.current && audioCtxRef.current.state !== 'closed') {
      audioCtxRef.current.close()
    }
  }, [])

  // Cleanup on unmount
  useEffect(() => {
    return () => {
      if (timerRef.current) clearInterval(timerRef.current)
      if (streamRef.current) streamRef.current.getTracks().forEach(t => t.stop())
      if (audioCtxRef.current && audioCtxRef.current.state !== 'closed') {
        audioCtxRef.current.close()
      }
    }
  }, [])

  return { state, audioBlob, durationSeconds, error, analyserNode, startRecording, stopRecording, resetRecording }
}
