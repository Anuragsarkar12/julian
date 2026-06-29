# backend/app/workers/analysis_pipeline.py
# The heart of Julian's backend.
# This function is called as a FastAPI BackgroundTask after every upload.
# It orchestrates: ffmpeg → Whisper → librosa → filler detection → Gemini → scoring

import os
import logging
from datetime import date, timedelta

from app.core.config import get_settings
from app.core.database import get_supabase_client
from app.services.audio_extractor import extract_audio_to_wav
from app.services.transcriber import transcribe_audio
from app.services.audio_analyzer import analyze_audio
from app.services.filler_detector import detect_fillers
from app.services.scoring_engine import calculate_all_scores
from app.services.llm_client import get_llm_coaching
from app.services.streak_manager import update_streak

import re

def count_syllables(word: str) -> int:
    word = word.lower()
    if not word: return 0
    count = len(re.findall(r'[aeiouy]+', word))
    if word.endswith('e') and count > 1 and not word.endswith('le'):
        count -= 1
    return max(1, count)

logger = logging.getLogger(__name__)
settings = get_settings()


async def run_analysis_pipeline(
    session_id: str,
    user_id: str,
    local_path: str,
    is_potd: bool = False,
    question_id: str | None = None,
) -> None:
    """
    Full analysis pipeline for a speech recording.
    Called as a background task — runs after the HTTP response is sent.

    On ANY unhandled exception: marks session as 'failed' so the user
    is not stuck looking at 'Analyzing...' forever.
    """
    db = get_supabase_client()
    wav_path = None

    try:
        logger.info(f"[Pipeline] Starting analysis for session {session_id}")

        # ── Step 1: Validate file exists ──────────────────────────────────
        if not os.path.exists(local_path):
            raise FileNotFoundError(f"Recording not found at {local_path}")

        # ── Step 2: Convert to WAV ─────────────────────────────────────────
        wav_path = local_path.replace(".webm", ".wav").replace(".mp4", ".wav")
        if not wav_path.endswith(".wav"):
            wav_path = local_path + ".wav"

        logger.info(f"[Pipeline] Converting audio: {local_path} → {wav_path}")
        extract_audio_to_wav(local_path, wav_path)

        # ── Step 3: Transcribe ─────────────────────────────────────────────
        logger.info(f"[Pipeline] Transcribing: {wav_path}")
        transcription = transcribe_audio(wav_path)
        transcript_text = transcription["text"]
        word_count = transcription["word_count"]
        duration_seconds = transcription["duration_seconds"]
        words = transcription["words"]

        # ── Step 4: Acoustic analysis ──────────────────────────────────────
        logger.info("[Pipeline] Running acoustic analysis")
        acoustic = analyze_audio(wav_path)

        # Update duration from acoustic analysis if transcription was off
        duration_seconds = acoustic["duration_seconds"] or duration_seconds

        # ── Step 5: Filler word detection ──────────────────────────────────
        logger.info("[Pipeline] Detecting filler words")
        filler_result = detect_fillers(transcript_text, words)
        filler_count = filler_result["total_count"]
        filler_words_found = filler_result["by_word"]

        # ── Step 6: Compute New Metrics (PTR, MLR, Artic Rate, Disfluency) ─
        total_syllables = sum(count_syllables(w.get("word", "")) for w in words)
        pause_count = acoustic["pause_count"]
        pause_total_seconds = acoustic["pause_total_seconds"]
        
        active_speech_time = max(0.1, duration_seconds - pause_total_seconds)
        ptr = (active_speech_time / duration_seconds * 100.0) if duration_seconds > 0 else 0.0
        articulation_rate = total_syllables / active_speech_time
        mlr = total_syllables / (pause_count + 1)
        
        minutes = duration_seconds / 60.0 if duration_seconds > 0 else 1.0
        disfluency_density = round(filler_count / minutes, 4)

        # ── Step 7: Fetch challenge prompt (for Gemini context) ────────────
        challenge_prompt = ""
        # Try new questions table first
        if question_id:
            try:
                q_result = (
                    db.table("questions")
                    .select("prompt_text")
                    .eq("id", question_id)
                    .single()
                    .execute()
                )
                if q_result.data:
                    challenge_prompt = q_result.data.get("prompt_text", "")
            except Exception:
                pass

        # Fall back to legacy daily_challenges
        if not challenge_prompt:
            session_result = (
                db.table("speech_sessions")
                .select("challenge_id")
                .eq("id", session_id)
                .single()
                .execute()
            )
            if session_result.data and session_result.data.get("challenge_id"):
                challenge_result = (
                    db.table("daily_challenges")
                    .select("prompt_text")
                    .eq("id", session_result.data["challenge_id"])
                    .single()
                    .execute()
                )
                if challenge_result.data:
                    challenge_prompt = challenge_result.data.get("prompt_text", "")

        # ── Step 8: Get LLM coaching ───────────────────────────────────────
        logger.info("[Pipeline] Calling LLM (Groq) for coaching feedback")
        # Ensure we pass all needed metrics for logging or context if desired,
        # but the new llm_client only STRICTLY needs the dynamic question and transcript.
        metrics_for_gemini = {} 
        gemini_feedback = await get_llm_coaching(
            transcript_text, metrics_for_gemini, challenge_prompt
        )

        # ── Step 9: Fetch previous score for improvement calculation ───────
        previous_score_result = (
            db.table("speech_metrics")
            .select("total_score")
            .eq("user_id", user_id)
            .order("created_at", desc=True)
            .limit(1)
            .execute()
        )
        previous_total_score = None
        if previous_score_result.data:
            previous_total_score = previous_score_result.data[0].get("total_score")

        # ── Step 10: Fetch current streak ─────────────────────────────────
        current_streak = 0
        try:
            streak_result = (
                db.table("streaks")
                .select("current_streak")
                .eq("user_id", user_id)
                .maybe_single()
                .execute()
            )
            if streak_result and streak_result.data:
                current_streak = streak_result.data.get("current_streak", 0)
        except Exception:
            pass

        # ── Step 11: Calculate scores ──────────────────────────────────────
        logger.info("[Pipeline] Calculating scores")
        scores = calculate_all_scores(
            articulation_rate=articulation_rate,
            mlr=mlr,
            ptr=ptr,
            pitch_variance=acoustic["pitch_variance"],
            energy_variance=acoustic["energy_variance"],
            disfluency_density=disfluency_density,
            gemini_feedback=gemini_feedback,
        )

        # ── Step 12: Write metrics to database ────────────────────────────
        logger.info("[Pipeline] Writing metrics to database")
        db.table("speech_metrics").insert({
            "session_id": session_id,
            "user_id": user_id,
            "transcript_text": transcript_text,
            "word_count": word_count,
            "wpm": round(word_count / minutes, 2) if minutes > 0 else 0.0,
            "filler_count": filler_count,
            "filler_rate": disfluency_density,
            "filler_words_found": filler_words_found,
            "pause_count": acoustic["pause_count"],
            "pause_total_seconds": acoustic["pause_total_seconds"],
            "longest_pause_seconds": acoustic["longest_pause_seconds"],
            "pitch_variance": acoustic["pitch_variance"],
            "energy_variance": acoustic["energy_variance"],
            "delivery_score": scores["delivery_score"],
            "content_score": scores["content_score"],
            "total_score": scores["total_score"],
            "gemini_feedback": gemini_feedback,
        }).execute()

        # ── Step 13: Update session duration and mark completed ────────────
        db.table("speech_sessions").update({
            "status": "completed",
            "duration_seconds": duration_seconds,
            "completed_at": "now()",
        }).eq("id", session_id).execute()

        # ── Step 14: Update streak ─────────────────────────────────────────
        new_streak = update_streak(db, user_id)

        # ── Step 15: Update weekly leaderboard (legacy) ────────────────────
        _update_leaderboard(db, user_id, scores["total_score"])

        # ── Step 16: Update question attempts ──────────────────────────────
        if question_id:
            _update_question_attempts(db, user_id, question_id, session_id, scores["total_score"])

        # ── Step 17: Handle POTD-specific logic ────────────────────────────
        if is_potd and question_id:
            _handle_potd_submission(db, user_id, question_id, session_id, scores["total_score"])

        logger.info(
            f"[Pipeline] Session {session_id} completed. "
            f"total_score={scores['total_score']}, streak={new_streak}"
        )

    except Exception as e:
        logger.error(
            f"[Pipeline] Analysis FAILED for session {session_id}: {e}",
            exc_info=True,
        )
        # Mark session as failed so the user sees an error instead of spinning forever
        try:
            db.table("speech_sessions").update({
                "status": "failed",
                "error_message": str(e)[:500],
            }).eq("id", session_id).execute()
        except Exception as db_err:
            logger.error(f"[Pipeline] Could not mark session as failed: {db_err}")

    finally:
        # ── Cleanup: delete local temp files ──────────────────────────────
        for path in [local_path, wav_path]:
            if path and os.path.exists(path):
                try:
                    os.remove(path)
                    logger.debug(f"Cleaned up temp file: {path}")
                except OSError as e:
                    logger.warning(f"Could not delete {path}: {e}")


def _update_leaderboard(db, user_id: str, total_score: int) -> None:
    """
    Updates or creates the user's leaderboard entry for the current week.
    Week starts on Monday.
    """
    today = date.today()
    week_start = (today - timedelta(days=today.weekday())).isoformat()

    try:
        existing = (
            db.table("leaderboard")
            .select("*")
            .eq("user_id", user_id)
            .eq("week_start", week_start)
            .maybe_single()
            .execute()
        )
    except Exception:
        existing = None

    if existing and existing.data:
        row = existing.data
        new_total = (row.get("total_score") or 0) + total_score
        new_count = (row.get("sessions_count") or 0) + 1
        db.table("leaderboard").update({
            "total_score": new_total,
            "sessions_count": new_count,
            "avg_score": round(new_total / new_count, 2),
            "updated_at": "now()",
        }).eq("user_id", user_id).eq("week_start", week_start).execute()
    else:
        db.table("leaderboard").insert({
            "user_id": user_id,
            "week_start": week_start,
            "total_score": total_score,
            "sessions_count": 1,
            "avg_score": float(total_score),
        }).execute()


def _update_question_attempts(
    db, user_id: str, question_id: str, session_id: str, total_score: int
) -> None:
    """
    Upsert the user_question_attempts row and update question-level stats.
    """
    try:
        existing = (
            db.table("user_question_attempts")
            .select("*")
            .eq("user_id", user_id)
            .eq("question_id", question_id)
            .maybe_single()
            .execute()
        )
    except Exception:
        existing = None

    if existing and existing.data:
        row = existing.data
        new_best = max(row.get("best_score") or 0, total_score)
        db.table("user_question_attempts").update({
            "best_score": new_best,
            "attempts": (row.get("attempts") or 0) + 1,
            "session_id": session_id,
            "last_attempted_at": "now()",
        }).eq("user_id", user_id).eq("question_id", question_id).execute()
    else:
        db.table("user_question_attempts").insert({
            "user_id": user_id,
            "question_id": question_id,
            "session_id": session_id,
            "best_score": total_score,
            "attempts": 1,
        }).execute()

    # Update question-level aggregate stats
    try:
        all_attempts = (
            db.table("user_question_attempts")
            .select("best_score")
            .eq("question_id", question_id)
            .execute()
        )
        scores = [a["best_score"] for a in (all_attempts.data or []) if a.get("best_score")]
        if scores:
            db.table("questions").update({
                "times_attempted": len(scores),
                "avg_score": round(sum(scores) / len(scores), 2),
            }).eq("id", question_id).execute()
    except Exception as e:
        logger.warning(f"Could not update question stats: {e}")

    # Update global rankings: questions_solved count
    try:
        solved_count = (
            db.table("user_question_attempts")
            .select("id", count="exact")
            .eq("user_id", user_id)
            .execute()
        )
        questions_solved = solved_count.count or 0

        # Upsert global_rankings
        try:
            gr_existing = (
                db.table("global_rankings")
                .select("id")
                .eq("user_id", user_id)
                .maybe_single()
                .execute()
            )
        except Exception:
            gr_existing = None

        if gr_existing and gr_existing.data:
            db.table("global_rankings").update({
                "questions_solved": questions_solved,
                "updated_at": "now()",
            }).eq("user_id", user_id).execute()
        else:
            db.table("global_rankings").insert({
                "user_id": user_id,
                "questions_solved": questions_solved,
            }).execute()
    except Exception as e:
        logger.warning(f"Could not update global rankings: {e}")


def _handle_potd_submission(
    db, user_id: str, question_id: str, session_id: str, total_score: int
) -> None:
    """
    Handle POTD-specific logic:
    - Write to daily_leaderboard (first submission only)
    - Update global_rankings POTD stats
    """
    today = date.today().isoformat()

    # Only first submission counts for leaderboard
    try:
        existing_sub = (
            db.table("daily_leaderboard")
            .select("id")
            .eq("user_id", user_id)
            .eq("potd_date", today)
            .maybe_single()
            .execute()
        )
        if existing_sub and existing_sub.data:
            logger.info(f"[POTD] User {user_id} already submitted for {today}, skipping leaderboard")
            return
    except Exception:
        pass

    # Insert into daily leaderboard
    try:
        db.table("daily_leaderboard").insert({
            "user_id": user_id,
            "potd_date": today,
            "question_id": question_id,
            "session_id": session_id,
            "score": total_score,
        }).execute()
    except Exception as e:
        logger.error(f"[POTD] Failed to insert daily leaderboard entry: {e}")
        return

    # Update global rankings POTD stats
    try:
        gr_result = (
            db.table("global_rankings")
            .select("*")
            .eq("user_id", user_id)
            .maybe_single()
            .execute()
        )
        gr = gr_result.data if gr_result else None

        if gr:
            new_total = (gr.get("total_potd_points") or 0) + total_score
            new_days = (gr.get("potd_days_participated") or 0) + 1
            new_best = max(gr.get("best_potd_score") or 0, total_score)
            new_avg = round(new_total / new_days, 2) if new_days > 0 else 0

            db.table("global_rankings").update({
                "total_potd_points": new_total,
                "potd_days_participated": new_days,
                "best_potd_score": new_best,
                "avg_potd_score": new_avg,
                "updated_at": "now()",
            }).eq("user_id", user_id).execute()
        else:
            db.table("global_rankings").insert({
                "user_id": user_id,
                "total_potd_points": total_score,
                "potd_days_participated": 1,
                "best_potd_score": total_score,
                "avg_potd_score": float(total_score),
            }).execute()
    except Exception as e:
        logger.error(f"[POTD] Failed to update global rankings: {e}")
