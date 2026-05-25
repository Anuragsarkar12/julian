# backend/app/api/deps.py
# Validates the user by calling Supabase's auth.get_user() with the access token.
# This approach works regardless of the JWT signing algorithm (HS256, ES256, etc.)

import logging
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from supabase import create_client
from app.core.config import get_settings

logger = logging.getLogger(__name__)
security = HTTPBearer()


async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
) -> dict:
    """
    FastAPI dependency that validates the Supabase JWT by calling
    Supabase's auth.get_user() endpoint. This is the recommended
    approach and works with any signing algorithm (HS256, ES256, etc.)

    Usage in any route:
        @router.get("/protected")
        async def my_route(current_user = Depends(get_current_user)):
            user_id = current_user["user_id"]
    """
    settings = get_settings()
    token = credentials.credentials

    try:
        # Create a lightweight Supabase client with the user's token
        supabase = create_client(
            settings.supabase_url,
            settings.supabase_anon_key,
        )

        # Verify the token by calling Supabase's auth API
        user_response = supabase.auth.get_user(token)

        if not user_response or not user_response.user:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid or expired token.",
            )

        user = user_response.user
        return {
            "user_id": user.id,
            "email": user.email or "",
        }

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Auth verification failed: {e}")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authentication failed. Please sign in again.",
        )
