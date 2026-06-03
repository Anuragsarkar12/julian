# backend/app/services/streak_manager.py
import logging
from datetime import date, timedelta

logger = logging.getLogger(__name__)


def get_display_streak(streak_record: dict | None) -> int:
    """
    Returns the current streak value for display purposes.
    If the user has a gap > 1 day since their last_activity_date,
    their streak is mathematically broken, so we return 0.
    """
    if not streak_record:
        return 0

    current = streak_record.get("current_streak", 0)
    last_date_str = streak_record.get("last_activity_date")

    if last_date_str:
        try:
            last_date = date.fromisoformat(last_date_str[:10])
            if last_date < date.today() - timedelta(days=1):
                return 0
        except ValueError:
            pass

    return current


def update_streak(db, user_id: str) -> int:
    """
    Updates the user's streak after a completed session.

    Rules:
    - If last_activity_date is today: no change (already practiced today)
    - If last_activity_date is yesterday: increment streak by 1
    - If last_activity_date is older: reset streak to 1
    - If no streak record exists: create it with streak=1

    Returns the new current_streak value.
    """
    today = date.today()

    # Fetch existing streak record
    try:
        result = (
            db.table("streaks")
            .select("*")
            .eq("user_id", user_id)
            .maybe_single()
            .execute()
        )
    except Exception:
        result = None

    if not result or not result.data:
        # First ever session — create streak record
        db.table("streaks").insert({
            "user_id": user_id,
            "current_streak": 1,
            "longest_streak": 1,
            "last_activity_date": today.isoformat(),
            "total_sessions": 1,
        }).execute()
        logger.info(f"Created streak for user {user_id}: streak=1")
        return 1

    streak = result.data
    last_date_str = streak.get("last_activity_date")
    current = streak.get("current_streak", 0)
    longest = streak.get("longest_streak", 0)
    total = streak.get("total_sessions", 0)

    if last_date_str:
        last_date = date.fromisoformat(last_date_str)
        if last_date == today:
            # Already practiced today — just increment total sessions
            db.table("streaks").update({
                "total_sessions": total + 1,
            }).eq("user_id", user_id).execute()
            return current
        elif last_date == today - timedelta(days=1):
            # Practiced yesterday — extend streak
            new_streak = current + 1
            new_longest = max(longest, new_streak)
        else:
            # Gap in practice — reset streak
            new_streak = 1
            new_longest = max(longest, 1)
    else:
        new_streak = 1
        new_longest = max(longest, 1)

    db.table("streaks").update({
        "current_streak": new_streak,
        "longest_streak": new_longest,
        "last_activity_date": today.isoformat(),
        "total_sessions": total + 1,
        "updated_at": "now()",
    }).eq("user_id", user_id).execute()

    logger.info(f"Streak updated for user {user_id}: {current} → {new_streak}")
    return new_streak
