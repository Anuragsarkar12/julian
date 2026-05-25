# backend/app/api/questions.py
import logging
from fastapi import APIRouter, Depends, HTTPException, Query
from typing import Optional

from app.api.deps import get_current_user
from app.core.database import get_supabase_client
from app.schemas.session import (
    QuestionListItem, QuestionListResponse,
    QuestionDetailResponse, QuestionUserStatsResponse,
)

logger = logging.getLogger(__name__)
router = APIRouter()


@router.get("", response_model=QuestionListResponse)
async def list_questions(
    current_user: dict = Depends(get_current_user),
    category: Optional[str] = Query(None),
    difficulty: Optional[str] = Query(None),
    status: Optional[str] = Query(None, description="all|solved|not_attempted"),
    search: Optional[str] = Query(None),
    page: int = Query(1, ge=1),
    limit: int = Query(25, ge=1, le=100),
):
    """List questions with filters, including user solve status."""
    db = get_supabase_client()
    user_id = current_user["user_id"]

    # Build base query
    query = db.table("questions").select("*", count="exact")

    if category:
        categories = [c.strip() for c in category.split(",")]
        if len(categories) == 1:
            query = query.eq("category", categories[0])
        else:
            query = query.in_("category", categories)

    if difficulty:
        difficulties = [d.strip() for d in difficulty.split(",")]
        if len(difficulties) == 1:
            query = query.eq("difficulty", difficulties[0])
        else:
            query = query.in_("difficulty", difficulties)

    if search:
        query = query.or_(f"title.ilike.%{search}%,prompt_text.ilike.%{search}%")

    # Pagination
    offset = (page - 1) * limit
    query = query.order("category").order("difficulty")
    query = query.range(offset, offset + limit - 1)

    result = query.execute()
    questions_data = result.data or []
    total = result.count or 0

    # Fetch user attempts for these questions
    question_ids = [q["id"] for q in questions_data]
    user_attempts = {}
    if question_ids:
        attempts_result = (
            db.table("user_question_attempts")
            .select("question_id, best_score, attempts")
            .eq("user_id", user_id)
            .in_("question_id", question_ids)
            .execute()
        )
        for a in (attempts_result.data or []):
            user_attempts[a["question_id"]] = a

    # Check which questions were ever a POTD
    potd_questions = set()
    if question_ids:
        potd_result = (
            db.table("potd")
            .select("question_id")
            .in_("question_id", question_ids)
            .execute()
        )
        potd_questions = {p["question_id"] for p in (potd_result.data or [])}

    # Build response
    items = []
    for q in questions_data:
        attempt = user_attempts.get(q["id"])
        user_status = "attempted" if attempt else "not_attempted"
        user_best = attempt["best_score"] if attempt else None

        items.append(QuestionListItem(
            id=q["id"],
            slug=q["slug"],
            title=q["title"],
            prompt_text=q["prompt_text"],
            category=q["category"],
            difficulty=q["difficulty"],
            times_attempted=q.get("times_attempted", 0),
            avg_score=float(q.get("avg_score", 0)),
            is_potd_eligible=q.get("is_potd_eligible", True),
            user_status=user_status,
            user_best_score=user_best,
            was_potd=q["id"] in potd_questions,
        ))

    # Filter by status after fetching (since it requires user data join)
    if status == "solved":
        items = [i for i in items if i.user_status == "attempted"]
        total = len(items)
    elif status == "not_attempted":
        items = [i for i in items if i.user_status == "not_attempted"]
        total = len(items)

    return QuestionListResponse(
        questions=items,
        total=total,
        page=page,
        limit=limit,
    )


@router.get("/{slug}", response_model=QuestionDetailResponse)
async def get_question(
    slug: str,
    current_user: dict = Depends(get_current_user),
):
    """Get a single question by slug with user stats."""
    db = get_supabase_client()
    user_id = current_user["user_id"]

    result = (
        db.table("questions")
        .select("*")
        .eq("slug", slug)
        .single()
        .execute()
    )
    if not result.data:
        raise HTTPException(status_code=404, detail="Question not found.")

    q = result.data

    # User attempts
    try:
        attempt_result = (
            db.table("user_question_attempts")
            .select("*")
            .eq("user_id", user_id)
            .eq("question_id", q["id"])
            .maybe_single()
            .execute()
        )
        attempt = attempt_result.data if attempt_result else None
    except Exception:
        attempt = None

    # POTD history
    try:
        potd_result = (
            db.table("potd")
            .select("potd_date")
            .eq("question_id", q["id"])
            .order("potd_date", desc=True)
            .limit(1)
            .execute()
        )
        potd_data = potd_result.data[0] if potd_result.data else None
    except Exception:
        potd_data = None

    return QuestionDetailResponse(
        id=q["id"],
        slug=q["slug"],
        title=q["title"],
        prompt_text=q["prompt_text"],
        category=q["category"],
        difficulty=q["difficulty"],
        tips=q.get("tips") or [],
        example_answer=q.get("example_answer"),
        times_attempted=q.get("times_attempted", 0),
        avg_score=float(q.get("avg_score", 0)),
        added_date=q.get("added_date"),
        user_attempts=attempt["attempts"] if attempt else 0,
        user_best_score=attempt["best_score"] if attempt else None,
        was_potd=potd_data is not None,
        potd_date=potd_data["potd_date"] if potd_data else None,
    )


@router.get("/{question_id}/user-stats", response_model=QuestionUserStatsResponse)
async def get_question_user_stats(
    question_id: str,
    current_user: dict = Depends(get_current_user),
):
    """Get the user's attempts and best score for a specific question."""
    db = get_supabase_client()
    user_id = current_user["user_id"]

    try:
        result = (
            db.table("user_question_attempts")
            .select("*")
            .eq("user_id", user_id)
            .eq("question_id", question_id)
            .maybe_single()
            .execute()
        )
        attempt = result.data if result else None
    except Exception:
        attempt = None

    if not attempt:
        return QuestionUserStatsResponse(question_id=question_id)

    return QuestionUserStatsResponse(
        question_id=question_id,
        attempts=attempt.get("attempts", 0),
        best_score=attempt.get("best_score"),
        last_attempted_at=attempt.get("last_attempted_at"),
    )
