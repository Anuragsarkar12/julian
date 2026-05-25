// frontend/src/lib/api.ts
import { createClient } from '@/lib/supabase/client'
import type {
  SessionStatus, SessionResults, Challenge, HistorySession,
  QuestionListResponse, QuestionDetail,
  POTD, POTDArchiveEntry,
  DailyLeaderboard, GlobalRankings, WeeklyLeaderboard,
  FullProfile, ActivityDay, UserProfile,
} from '@/types'

async function getAuthHeaders(): Promise<Record<string, string>> {
  const supabase = createClient()
  const { data: { session } } = await supabase.auth.getSession()
  if (!session?.access_token) throw new Error('Not authenticated')
  return {
    Authorization: `Bearer ${session.access_token}`,
  }
}

const API = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000'

async function apiFetch<T>(path: string, options: RequestInit = {}): Promise<T> {
  const headers = await getAuthHeaders()
  const res = await fetch(`${API}${path}`, {
    ...options,
    headers: { ...headers, ...options.headers },
  })
  if (!res.ok) {
    const body = await res.json().catch(() => ({}))
    throw new Error(body.detail || `API error: ${res.status}`)
  }
  return res.json()
}

// ── Sessions (existing) ────────────────────────────────────────────────────

export async function uploadSession(blob: Blob, challengeId?: string, questionId?: string) {
  const headers = await getAuthHeaders()
  const form = new FormData()
  form.append('file', blob, 'recording.webm')
  if (challengeId) form.append('challenge_id', challengeId)
  if (questionId) form.append('question_id', questionId)

  const res = await fetch(`${API}/api/sessions/upload`, {
    method: 'POST',
    headers,
    body: form,
  })
  if (!res.ok) {
    const body = await res.json().catch(() => ({}))
    throw new Error(body.detail || 'Upload failed')
  }
  return res.json() as Promise<{ session_id: string }>
}

export function getSessionStatus(sessionId: string) {
  return apiFetch<SessionStatus>(`/api/sessions/${sessionId}/status`)
}

export function getSessionResults(sessionId: string) {
  return apiFetch<SessionResults>(`/api/sessions/${sessionId}/results`)
}

export function getHistory(limit = 20) {
  return apiFetch<{ sessions: HistorySession[] }>(`/api/sessions/history/me?limit=${limit}`)
}

// ── Legacy challenge ───────────────────────────────────────────────────────

export function getTodaysChallenge() {
  return apiFetch<Challenge>('/api/challenges/today')
}

// ── Questions ──────────────────────────────────────────────────────────────

export function getQuestions(params: {
  category?: string
  difficulty?: string
  status?: string
  search?: string
  page?: number
  limit?: number
} = {}) {
  const searchParams = new URLSearchParams()
  if (params.category) searchParams.set('category', params.category)
  if (params.difficulty) searchParams.set('difficulty', params.difficulty)
  if (params.status) searchParams.set('status', params.status)
  if (params.search) searchParams.set('search', params.search)
  if (params.page) searchParams.set('page', String(params.page))
  if (params.limit) searchParams.set('limit', String(params.limit))
  const qs = searchParams.toString()
  return apiFetch<QuestionListResponse>(`/api/questions${qs ? `?${qs}` : ''}`)
}

export function getQuestion(slug: string) {
  return apiFetch<QuestionDetail>(`/api/questions/${slug}`)
}

// ── POTD ───────────────────────────────────────────────────────────────────

export function getPOTDToday() {
  return apiFetch<POTD>('/api/potd/today')
}

export async function submitPOTD(blob: Blob) {
  const headers = await getAuthHeaders()
  const form = new FormData()
  form.append('file', blob, 'recording.webm')

  const res = await fetch(`${API}/api/potd/submit`, {
    method: 'POST',
    headers,
    body: form,
  })
  if (!res.ok) {
    const body = await res.json().catch(() => ({}))
    throw new Error(body.detail || 'POTD submission failed')
  }
  return res.json() as Promise<{ session_id: string }>
}

export function getPOTDLeaderboard(dateStr?: string) {
  const qs = dateStr ? `?date_str=${dateStr}` : ''
  return apiFetch<DailyLeaderboard>(`/api/potd/leaderboard${qs}`)
}

export function getPOTDArchive(limit = 7) {
  return apiFetch<{ entries: POTDArchiveEntry[] }>(`/api/potd/archive?limit=${limit}`)
}

// ── Leaderboard ────────────────────────────────────────────────────────────

export function getDailyLeaderboard(dateStr?: string) {
  const qs = dateStr ? `?date=${dateStr}` : ''
  return apiFetch<DailyLeaderboard>(`/api/leaderboard/daily${qs}`)
}

export function getGlobalLeaderboard(page = 1, limit = 50) {
  return apiFetch<GlobalRankings>(`/api/leaderboard/global?page=${page}&limit=${limit}`)
}

export function getWeeklyLeaderboard() {
  return apiFetch<WeeklyLeaderboard>('/api/leaderboard/weekly')
}

// ── Users ──────────────────────────────────────────────────────────────────

export function getUserProfile() {
  return apiFetch<UserProfile>('/api/users/me')
}

export function getFullProfile() {
  return apiFetch<FullProfile>('/api/users/me/full-profile')
}

export function getActivityHeatmap() {
  return apiFetch<{ days: ActivityDay[] }>('/api/users/me/activity-heatmap')
}
