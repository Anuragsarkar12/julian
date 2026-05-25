# backend/app/api/users.py
import logging
from fastapi import APIRouter, Depends
from datetime import date, timedelta

from app.api.deps import get_current_user
from app.core.database import get_supabase_client
from app.schemas.session import (
    UserProfileResponse,
    FullProfileResponse, CategoryStat, BadgeInfo,
    ActivityHeatmapResponse, ActivityDay,
)

logger = logging.getLogger(__name__)
router = APIRouter()

BADGE_DEFINITIONS = [
    {"id": "first_session", "name": "First Steps", "emoji": "🎤", "description": "Complete your first practice session", "threshold": 1, "field": "total_sessions"},
    {"id": "ten_sessions", "name": "Consistent", "emoji": "🔥", "description": "Complete 10 practice sessions", "threshold": 10, "field": "total_sessions"},
    {"id": "fifty_sessions", "name": "Dedicated", "emoji": "💎", "description": "Complete 50 practice sessions", "threshold": 50, "field": "total_sessions"},
    {"id": "streak_7", "name": "Weekly Warrior", "emoji": "⚡", "description": "Maintain a 7-day practice streak", "threshold": 7, "field": "longest_streak"},
    {"id": "streak_30", "name": "Monthly Master", "emoji": "🏆", "description": "Maintain a 30-day practice streak", "threshold": 30, "field": "longest_streak"},
    {"id": "score_90", "name": "Top Performer", "emoji": "🌟", "description": "Score 90 or above on any session", "threshold": 90, "field": "best_score"},
    {"id": "solved_10", "name": "Explorer", "emoji": "🧭", "description": "Practice 10 different questions", "threshold": 10, "field": "questions_solved"},
    {"id": "solved_50", "name": "Conqueror", "emoji": "👑", "description": "Practice 50 different questions", "threshold": 50, "field": "questions_solved"},
    {"id": "potd_10", "name": "Daily Driver", "emoji": "📅", "description": "Submit 10 POTD entries", "threshold": 10, "field": "potd_days"},
    {"id": "all_categories", "name": "Well Rounded", "emoji": "🎯", "description": "Practice at least 1 question from all 10 categories", "threshold": 10, "field": "categories_attempted"},
]


@router.get("/me", response_model=UserProfileResponse)
async def get_profile(current_user: dict = Depends(get_current_user)):
    """Basic user profile."""
    db = get_supabase_client()
    user_id = current_user["user_id"]

    user_result = db.table("users").select("*").eq("id", user_id).single().execute()
    user = user_result.data

    streak_result = db.table("streaks").select("*").eq("user_id", user_id).maybe_single().execute()
    streak = streak_result.data if streak_result else None

    # Avg score
    avg_result = (
        db.table("speech_metrics")
        .select("total_score")
        .eq("user_id", user_id)
        .execute()
    )
    scores = [r["total_score"] for r in (avg_result.data or []) if r.get("total_score")]
    avg_score = round(sum(scores) / len(scores), 1) if scores else None

    return UserProfileResponse(
        id=user["id"],
        email=user.get("email", ""),
        full_name=user.get("full_name"),
        avatar_url=user.get("avatar_url"),
        username=user.get("username"),
        current_streak=streak.get("current_streak", 0) if streak else 0,
        longest_streak=streak.get("longest_streak", 0) if streak else 0,
        total_sessions=streak.get("total_sessions", 0) if streak else 0,
        avg_score=avg_score,
    )


@router.get("/me/full-profile", response_model=FullProfileResponse)
async def get_full_profile(current_user: dict = Depends(get_current_user)):
    """Full profile with stats, badges, and category breakdown."""
    db = get_supabase_client()
    user_id = current_user["user_id"]

    # User info
    user_result = db.table("users").select("*").eq("id", user_id).single().execute()
    user = user_result.data

    # Streak
    streak_result = db.table("streaks").select("*").eq("user_id", user_id).maybe_single().execute()
    streak = (streak_result.data if streak_result else None) or {}

    # Global ranking
    try:
        gr_result = db.table("global_rankings").select("*").eq("user_id", user_id).maybe_single().execute()
        global_data = (gr_result.data if gr_result else None) or {}
    except Exception:
        global_data = {}

    # Scores
    scores_result = (
        db.table("speech_metrics")
        .select("total_score")
        .eq("user_id", user_id)
        .execute()
    )
    all_scores = [r["total_score"] for r in (scores_result.data or []) if r.get("total_score")]
    avg_score = round(sum(all_scores) / len(all_scores), 1) if all_scores else None
    best_score = max(all_scores) if all_scores else None

    # Questions solved + category breakdown
    attempts_result = (
        db.table("user_question_attempts")
        .select("*, questions(category)")
        .eq("user_id", user_id)
        .execute()
    )
    attempts = attempts_result.data or []
    questions_solved = len(attempts)

    # Category stats
    cat_map = {}
    for a in attempts:
        cat = (a.get("questions") or {}).get("category", "unknown")
        if cat not in cat_map:
            cat_map[cat] = {"attempted": 0, "solved": 0, "scores": [], "best": 0}
        cat_map[cat]["attempted"] += a.get("attempts", 1)
        cat_map[cat]["solved"] += 1
        if a.get("best_score"):
            cat_map[cat]["scores"].append(a["best_score"])
            cat_map[cat]["best"] = max(cat_map[cat]["best"], a["best_score"])

    categories = []
    for cat_name in sorted(cat_map.keys()):
        c = cat_map[cat_name]
        categories.append(CategoryStat(
            category=cat_name,
            attempted=c["attempted"],
            solved=c["solved"],
            avg_score=round(sum(c["scores"]) / len(c["scores"]), 1) if c["scores"] else 0,
            best_score=c["best"],
        ))

    # POTD days
    try:
        potd_days_result = (
            db.table("daily_leaderboard")
            .select("potd_date")
            .eq("user_id", user_id)
            .execute()
        )
        potd_days = len(potd_days_result.data or [])
    except Exception:
        potd_days = 0

    # Compute badges
    stats_for_badges = {
        "total_sessions": streak.get("total_sessions", 0),
        "longest_streak": streak.get("longest_streak", 0),
        "best_score": best_score or 0,
        "questions_solved": questions_solved,
        "potd_days": potd_days,
        "categories_attempted": len(cat_map),
    }

    badges = []
    for bd in BADGE_DEFINITIONS:
        value = stats_for_badges.get(bd["field"], 0)
        earned = value >= bd["threshold"]
        progress = f"{value}/{bd['threshold']}" if not earned else None
        badges.append(BadgeInfo(
            id=bd["id"],
            name=bd["name"],
            emoji=bd["emoji"],
            description=bd["description"],
            earned=earned,
            progress=progress,
        ))

    return FullProfileResponse(
        id=user["id"],
        email=user.get("email", ""),
        full_name=user.get("full_name"),
        avatar_url=user.get("avatar_url"),
        username=user.get("username"),
        created_at=user.get("created_at"),
        current_streak=streak.get("current_streak", 0),
        longest_streak=streak.get("longest_streak", 0),
        total_sessions=streak.get("total_sessions", 0),
        avg_score=avg_score,
        best_score=best_score,
        questions_solved=questions_solved,
        global_rank=global_data.get("global_rank"),
        total_potd_points=global_data.get("total_potd_points", 0),
        categories=categories,
        badges=badges,
    )


@router.get("/me/activity-heatmap", response_model=ActivityHeatmapResponse)
async def get_activity_heatmap(current_user: dict = Depends(get_current_user)):
    """Last 365 days of session activity for the contribution heatmap."""
    db = get_supabase_client()
    user_id = current_user["user_id"]

    cutoff = (date.today() - timedelta(days=365)).isoformat()
    result = (
        db.table("speech_sessions")
        .select("created_at")
        .eq("user_id", user_id)
        .eq("status", "completed")
        .gte("created_at", cutoff)
        .execute()
    )

    # Count sessions per day
    day_counts: dict[str, int] = {}
    for row in (result.data or []):
        day = row["created_at"][:10]  # Extract YYYY-MM-DD
        day_counts[day] = day_counts.get(day, 0) + 1

    days = [ActivityDay(date=d, count=c) for d, c in sorted(day_counts.items())]
    return ActivityHeatmapResponse(days=days)
