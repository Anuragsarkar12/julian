# backend/app/api/leaderboard.py
from fastapi import APIRouter, Depends, Query
from datetime import date, timedelta

from app.api.deps import get_current_user
from app.core.database import get_supabase_client
from app.schemas.session import (
    LeaderboardResponse, LeaderboardEntry,
    DailyLeaderboardEntry, DailyLeaderboardResponse,
    GlobalRankingEntry, GlobalRankingResponse,
)

router = APIRouter()


def get_week_start(d: date) -> date:
    """Returns the most recent Monday for a given date."""
    return d - timedelta(days=d.weekday())


@router.get("/weekly", response_model=LeaderboardResponse)
async def get_weekly_leaderboard(
    current_user: dict = Depends(get_current_user),
):
    """Returns this week's top 25 users by cumulative score (legacy)."""
    db = get_supabase_client()
    user_id = current_user["user_id"]
    week_start = get_week_start(date.today()).isoformat()

    result = (
        db.table("leaderboard")
        .select("*, users(full_name, avatar_url)")
        .eq("week_start", week_start)
        .order("total_score", desc=True)
        .limit(25)
        .execute()
    )

    entries = []
    for rank, row in enumerate(result.data or [], start=1):
        user_info = row.get("users") or {}
        entries.append(
            LeaderboardEntry(
                rank=rank,
                user_id=row["user_id"],
                full_name=user_info.get("full_name"),
                avatar_url=user_info.get("avatar_url"),
                total_score=row.get("total_score") or 0,
                sessions_count=row.get("sessions_count") or 0,
                avg_score=float(row.get("avg_score") or 0),
                is_current_user=(row["user_id"] == user_id),
            )
        )

    return LeaderboardResponse(week_start=week_start, entries=entries)


@router.get("/daily", response_model=DailyLeaderboardResponse)
async def get_daily_leaderboard(
    current_user: dict = Depends(get_current_user),
    date_str: str = Query(None, alias="date"),
):
    """Daily POTD leaderboard for a specific date."""
    db = get_supabase_client()
    user_id = current_user["user_id"]
    target_date = date_str or date.today().isoformat()

    # Get question title
    question_title = None
    try:
        potd_result = (
            db.table("potd")
            .select("questions(title)")
            .eq("potd_date", target_date)
            .maybe_single()
            .execute()
        )
        if potd_result and potd_result.data:
            question_title = (potd_result.data.get("questions") or {}).get("title")
    except Exception:
        pass

    result = (
        db.table("daily_leaderboard")
        .select("*, users(full_name, avatar_url)")
        .eq("potd_date", target_date)
        .order("score", desc=True)
        .order("submitted_at")
        .limit(100)
        .execute()
    )

    entries = []
    for rank, row in enumerate(result.data or [], start=1):
        user_info = row.get("users") or {}
        entries.append(DailyLeaderboardEntry(
            rank=rank,
            user_id=row["user_id"],
            full_name=user_info.get("full_name"),
            avatar_url=user_info.get("avatar_url"),
            score=row["score"],
            submitted_at=row.get("submitted_at"),
            is_current_user=(row["user_id"] == user_id),
        ))

    return DailyLeaderboardResponse(
        date=target_date,
        question_title=question_title,
        total_submissions=len(entries),
        entries=entries,
    )


@router.get("/global", response_model=GlobalRankingResponse)
async def get_global_leaderboard(
    current_user: dict = Depends(get_current_user),
    page: int = Query(1, ge=1),
    limit: int = Query(50, ge=1, le=100),
):
    """Global all-time rankings by questions solved."""
    db = get_supabase_client()
    user_id = current_user["user_id"]
    offset = (page - 1) * limit

    # Fetch rankings with user info
    result = (
        db.table("global_rankings")
        .select("*, users(full_name, avatar_url)", count="exact")
        .order("questions_solved", desc=True)
        .order("avg_potd_score", desc=True)
        .range(offset, offset + limit - 1)
        .execute()
    )

    total_users = result.count or 0

    # Get current user's rank
    user_rank = None
    try:
        ur_result = (
            db.table("global_rankings")
            .select("global_rank")
            .eq("user_id", user_id)
            .maybe_single()
            .execute()
        )
        if ur_result and ur_result.data:
            user_rank = ur_result.data.get("global_rank")
    except Exception:
        pass

    # Get streaks for displayed users
    user_ids = [r["user_id"] for r in (result.data or [])]
    streaks = {}
    if user_ids:
        try:
            streak_result = (
                db.table("streaks")
                .select("user_id, current_streak")
                .in_("user_id", user_ids)
                .execute()
            )
            streaks = {s["user_id"]: s.get("current_streak", 0) for s in (streak_result.data or [])}
        except Exception:
            pass

    entries = []
    for idx, row in enumerate(result.data or []):
        user_info = row.get("users") or {}
        entries.append(GlobalRankingEntry(
            rank=row.get("global_rank") or (offset + idx + 1),
            user_id=row["user_id"],
            full_name=user_info.get("full_name"),
            avatar_url=user_info.get("avatar_url"),
            questions_solved=row.get("questions_solved", 0),
            avg_potd_score=float(row.get("avg_potd_score", 0)),
            potd_days_participated=row.get("potd_days_participated", 0),
            current_streak=streaks.get(row["user_id"], 0),
            is_current_user=(row["user_id"] == user_id),
        ))

    return GlobalRankingResponse(
        total_users=total_users,
        user_rank=user_rank,
        page=page,
        limit=limit,
        entries=entries,
    )
