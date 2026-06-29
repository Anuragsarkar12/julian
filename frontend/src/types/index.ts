// frontend/src/types/index.ts

// ── Auth / User ────────────────────────────────────────────────────────────
export interface SessionStatus {
  session_id: string
  status: 'uploading' | 'processing' | 'completed' | 'failed'
  error_message?: string
}

export interface Challenge {
  id: string
  challenge_date: string
  prompt_text: string
  category: string
  difficulty: string
  tips: string[]
}

export interface HistorySession {
  session_id: string
  total_score: number
  wpm: number
  filler_count: number
  created_at: string
  question_title?: string
}

export interface SessionResults {
  session_id: string
  status: string
  transcript: string
  metrics: {
    wpm: number
    word_count: number
    duration_seconds: number
    filler_count: number
    filler_rate: number
    filler_words_found: Record<string, number>
    pause_count: number
    pause_total_seconds: number
    longest_pause_seconds: number
    pitch_variance: number
    energy_variance: number
  }
  scores: {
    delivery_score: number
    content_score: number
    total_score: number
  }
  feedback: {
    overall_summary: string
    strengths: string[]
    improvements: string[]
    structure_score: number
    clarity_score: number
    engagement_score: number
    coaching_tip: string
    next_focus: string
    is_fallback: boolean
  }
  challenge_prompt?: string
  question_title?: string
  created_at?: string
}

export interface UserProfile {
  id: string
  email: string
  full_name?: string
  avatar_url?: string
  username?: string
  current_streak: number
  longest_streak: number
  total_sessions: number
  avg_score?: number
}

// ── V2: Questions ──────────────────────────────────────────────────────────

export type QuestionCategory =
  | 'conflict' | 'leadership' | 'failure' | 'achievement'
  | 'teamwork' | 'communication' | 'problem-solving'
  | 'adaptability' | 'initiative' | 'growth'

export type QuestionDifficulty = 'easy' | 'medium' | 'hard'

export interface QuestionListItem {
  id: string
  slug: string
  title: string
  prompt_text: string
  category: QuestionCategory
  difficulty: QuestionDifficulty
  times_attempted: number
  avg_score: number
  is_potd_eligible: boolean
  user_status: 'not_attempted' | 'attempted'
  user_best_score?: number
  was_potd: boolean
}

export interface QuestionListResponse {
  questions: QuestionListItem[]
  total: number
  page: number
  limit: number
}

export interface QuestionDetail {
  id: string
  slug: string
  title: string
  prompt_text: string
  category: QuestionCategory
  difficulty: QuestionDifficulty
  tips: string[]
  example_answer?: string
  times_attempted: number
  avg_score: number
  added_date?: string
  user_attempts: number
  user_best_score?: number
  was_potd: boolean
  potd_date?: string
}

// ── V2: POTD ───────────────────────────────────────────────────────────────

export interface POTD {
  potd_id: string
  potd_date: string
  question: QuestionDetail
  user_submitted: boolean
  user_score?: number
  user_session_id?: string
}

export interface POTDArchiveEntry {
  potd_date: string
  question_title: string
  question_category: string
  question_difficulty: string
  question_id: string
  top_score?: number
  top_user_name?: string
}

// ── V2: Leaderboard ────────────────────────────────────────────────────────

export interface DailyLeaderboardEntry {
  rank: number
  user_id: string
  full_name?: string
  avatar_url?: string
  score: number
  submitted_at?: string
  is_current_user: boolean
}

export interface DailyLeaderboard {
  date: string
  question_title?: string
  total_submissions: number
  entries: DailyLeaderboardEntry[]
}

export interface GlobalRankingEntry {
  rank: number
  user_id: string
  full_name?: string
  avatar_url?: string
  questions_solved: number
  avg_potd_score: number
  potd_days_participated: number
  current_streak: number
  is_current_user: boolean
}

export interface GlobalRankings {
  total_users: number
  user_rank?: number
  page: number
  limit: number
  entries: GlobalRankingEntry[]
}

// ── V2: Profile ────────────────────────────────────────────────────────────

export interface CategoryStat {
  category: string
  attempted: number
  solved: number
  avg_score: number
  best_score: number
}

export interface Badge {
  id: string
  name: string
  emoji: string
  description: string
  earned: boolean
  earned_at?: string
  progress?: string
}

export interface FullProfile {
  id: string
  email: string
  full_name?: string
  avatar_url?: string
  username?: string
  created_at?: string
  current_streak: number
  longest_streak: number
  total_sessions: number
  avg_score?: number
  best_score?: number
  questions_solved: number
  global_rank?: number
  total_potd_points: number
  categories: CategoryStat[]
  badges: Badge[]
}

export interface ActivityDay {
  date: string
  count: number
}

// ── V2: Legacy Leaderboard (keep for backward compat) ──────────────────────

export interface LeaderboardEntry {
  rank: number
  user_id: string
  full_name?: string
  avatar_url?: string
  total_score: number
  sessions_count: number
  avg_score: number
  is_current_user: boolean
}

export interface WeeklyLeaderboard {
  week_start: string
  entries: LeaderboardEntry[]
}
