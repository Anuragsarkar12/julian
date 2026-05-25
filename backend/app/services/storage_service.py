# backend/app/services/storage_service.py
import logging
from app.core.config import get_settings

logger = logging.getLogger(__name__)
settings = get_settings()


def upload_recording(db, user_id: str, session_id: str, file_data: bytes, ext: str = "webm") -> str:
    """
    Uploads a recording to Supabase Storage.
    Returns the storage path on success, empty string on failure.
    """
    storage_path = f"recordings/{user_id}/{session_id}.{ext}"
    try:
        db.storage.from_(settings.supabase_storage_bucket).upload(
            path=storage_path,
            file=file_data,
            file_options={"content-type": f"audio/{ext}"},
        )
        logger.info(f"Uploaded recording to {storage_path}")
        return storage_path
    except Exception as e:
        logger.error(f"Storage upload failed: {e}")
        return ""


def get_signed_url(db, storage_path: str, expires_in: int = 3600) -> str | None:
    """
    Returns a temporary signed URL for accessing a private recording.
    Expires after expires_in seconds (default: 1 hour).
    """
    try:
        result = db.storage.from_(settings.supabase_storage_bucket).create_signed_url(
            path=storage_path,
            expires_in=expires_in,
        )
        return result.get("signedURL")
    except Exception as e:
        logger.error(f"Signed URL generation failed for {storage_path}: {e}")
        return None
