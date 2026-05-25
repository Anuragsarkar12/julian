# backend/app/core/database.py
from supabase import create_client, Client
from app.core.config import get_settings
from functools import lru_cache


@lru_cache()
def get_supabase_client() -> Client:
    """
    Returns a Supabase client using the SERVICE ROLE key.
    This key bypasses Row Level Security — only use in backend.
    NEVER expose this client or key to the frontend.
    """
    settings = get_settings()
    return create_client(
        settings.supabase_url,
        settings.supabase_service_role_key,
    )
