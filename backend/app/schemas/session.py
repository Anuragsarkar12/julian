# backend/app/schemas/session.py
from pydantic import BaseModel
from typing import Optional, Any
from datetime import datetime, date


class SessionStatusResponse(BaseModel):
    session_id: str
    status: str  # uploading | processing | completed | failed
    error_message: Optional[str] = None


class FillerWordsFound(BaseModel):
    um: int = 0
    uh: int = 0
    like: int = 0
    you_know: int = 0
    so: int = 0
    basically: int = 0
    literally: int = 0
    actually: int = 0
    right: int = 0
    okay: int = 0


class MetricsData(BaseModel):
    wpm: float = 0
    word_count: int = 0
    duration_seconds: float = 0
    filler_count: int = 0
    filler_rate: float = 0
    filler_words_found: dict[str, int] = {}
    pause_count: int = 0
    pause_total_seconds: float = 0
    longest_pause_seconds: float = 0
    pitch_variance: float = 0
    energy_variance: float = 0


class ScoresData(BaseModel):
    delivery_score: int = 0
    content_score: int = 0
    improvement_score: int = 0
    consistency_score: int = 0
    total_score: int = 0


class FeedbackData(BaseModel):
    overall_summary: str = ""
    strengths: list[str] = []
    improvements: list[str] = []
    structure_score: int = 5
    clarity_score: int = 5
    engagement_score: int = 5
    coaching_tip: str = ""
    next_focus: str = ""
    is_fallback: bool = False


class SessionResultsResponse(BaseModel):
    session_id: str
    status: str
    transcript: str
    metrics: MetricsData
    scores: ScoresData
    feedback: FeedbackData
    challenge_prompt: Optional[str] = None
    question_title: Optional[str] = None
    created_at: Optional[datetime] = None


class UploadResponse(BaseModel):
    session_id: str
    status: str = "processing"
    message: str = "Upload received. Analysis started."


class ChallengeResponse(BaseModel):
    id: str
    challenge_date: str
    prompt_text: str
    category: str
    difficulty: str
    tips: list[str] = []


class LeaderboardEntry(BaseModel):
    rank: int
    user_id: str
    full_name: Optional[str] = None
    avatar_url: Optional[str] = None
    total_score: int
    sessions_count: int
    avg_score: float
    is_current_user: bool = False


class LeaderboardResponse(BaseModel):
    week_start: str
    entries: list[LeaderboardEntry]


class UserProfileResponse(BaseModel):
    id: str
    email: str
    full_name: Optional[str] = None
    avatar_url: Optional[str] = None
    username: Optional[str] = None
    current_streak: int = 0
    longest_streak: int = 0
    total_sessions: int = 0
    avg_score: Optional[float] = None


class HistorySession(BaseModel):
    session_id: str
    total_score: int
    wpm: float
    filler_count: int
    created_at: datetime
    question_title: Optional[str] = None


class HistoryResponse(BaseModel):
    sessions: list[HistorySession]


# ── New V2 schemas ──────────────────────────────────────────────────────────


class QuestionListItem(BaseModel):
    id: str
    slug: str
    title: str
    prompt_text: str
    category: str
    difficulty: str
    times_attempted: int = 0
    avg_score: float = 0
    is_potd_eligible: bool = True
    user_status: str = "not_attempted"  # not_attempted | attempted
    user_best_score: Optional[int] = None
    was_potd: bool = False


class QuestionListResponse(BaseModel):
    questions: list[QuestionListItem]
    total: int
    page: int
    limit: int


class QuestionDetailResponse(BaseModel):
    id: str
    slug: str
    title: str
    prompt_text: str
    category: str
    difficulty: str
    tips: list[str] = []
    example_answer: Optional[str] = None
    times_attempted: int = 0
    avg_score: float = 0
    added_date: Optional[str] = None
    user_attempts: int = 0
    user_best_score: Optional[int] = None
    was_potd: bool = False
    potd_date: Optional[str] = None


class QuestionUserStatsResponse(BaseModel):
    question_id: str
    attempts: int = 0
    best_score: Optional[int] = None
    last_attempted_at: Optional[datetime] = None


class POTDResponse(BaseModel):
    potd_id: str
    potd_date: str
    question: QuestionDetailResponse
    user_submitted: bool = False
    user_score: Optional[int] = None
    user_session_id: Optional[str] = None


class POTDSubmitResponse(BaseModel):
    session_id: str
    status: str = "processing"
    message: str = "POTD submission received. Analysis started."


class DailyLeaderboardEntry(BaseModel):
    rank: int
    user_id: str
    full_name: Optional[str] = None
    avatar_url: Optional[str] = None
    score: int
    submitted_at: Optional[datetime] = None
    is_current_user: bool = False


class DailyLeaderboardResponse(BaseModel):
    date: str
    question_title: Optional[str] = None
    total_submissions: int = 0
    entries: list[DailyLeaderboardEntry]


class GlobalRankingEntry(BaseModel):
    rank: int
    user_id: str
    full_name: Optional[str] = None
    avatar_url: Optional[str] = None
    questions_solved: int = 0
    avg_potd_score: float = 0
    potd_days_participated: int = 0
    current_streak: int = 0
    is_current_user: bool = False


class GlobalRankingResponse(BaseModel):
    total_users: int
    user_rank: Optional[int] = None
    page: int
    limit: int
    entries: list[GlobalRankingEntry]


class CategoryStat(BaseModel):
    category: str
    attempted: int = 0
    solved: int = 0
    avg_score: float = 0
    best_score: int = 0


class BadgeInfo(BaseModel):
    id: str
    name: str
    emoji: str
    description: str
    earned: bool = False
    earned_at: Optional[datetime] = None
    progress: Optional[str] = None


class FullProfileResponse(BaseModel):
    id: str
    email: str
    full_name: Optional[str] = None
    avatar_url: Optional[str] = None
    username: Optional[str] = None
    created_at: Optional[datetime] = None
    current_streak: int = 0
    longest_streak: int = 0
    total_sessions: int = 0
    avg_score: Optional[float] = None
    best_score: Optional[int] = None
    questions_solved: int = 0
    global_rank: Optional[int] = None
    total_potd_points: int = 0
    categories: list[CategoryStat] = []
    badges: list[BadgeInfo] = []


class ActivityDay(BaseModel):
    date: str
    count: int


class ActivityHeatmapResponse(BaseModel):
    days: list[ActivityDay]


class POTDArchiveEntry(BaseModel):
    potd_date: str
    question_title: str
    question_category: str
    question_difficulty: str
    question_id: str
    top_score: Optional[int] = None
    top_user_name: Optional[str] = None


class POTDArchiveResponse(BaseModel):
    entries: list[POTDArchiveEntry]
