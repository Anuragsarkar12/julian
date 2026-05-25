# backend/app/main.py
import logging
from contextlib import asynccontextmanager
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded

from app.core.config import get_settings
from app.core.database import get_supabase_client
from app.api import sessions, challenges, leaderboard, users, questions, potd

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(name)s: %(message)s",
)
logger = logging.getLogger(__name__)
settings = get_settings()


@asynccontextmanager
async def lifespan(app: FastAPI):
    """
    Runs on startup. Pre-loads the Whisper model so the first real
    user request does not wait 10-30 seconds for model initialization.
    """
    logger.info("Julian API starting up...")
    logger.info(f"Environment: {settings.environment}")
    logger.info(f"Whisper model: {settings.whisper_model_size}")

    # Pre-warm Whisper model in background
    try:
        from app.services.transcriber import get_whisper_model
        logger.info("Pre-loading Whisper model...")
        get_whisper_model()
        logger.info("Whisper model loaded successfully.")
    except Exception as e:
        logger.error(f"Whisper model pre-load failed: {e}")
        # App still starts — model will load on first request

    yield
    logger.info("Julian API shutting down.")


# Rate limiter (per IP — coarse protection for anonymous abuse)
limiter = Limiter(key_func=get_remote_address)

app = FastAPI(
    title="Julian API",
    version="1.0.0",
    lifespan=lifespan,
    docs_url="/docs" if not settings.is_production else None,
    redoc_url=None,
)

app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.allowed_origins_list,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Register routers
app.include_router(sessions.router,    prefix="/api/sessions",    tags=["sessions"])
app.include_router(challenges.router,  prefix="/api/challenges",  tags=["challenges"])
app.include_router(leaderboard.router, prefix="/api/leaderboard", tags=["leaderboard"])
app.include_router(users.router,       prefix="/api/users",       tags=["users"])
app.include_router(questions.router,   prefix="/api/questions",   tags=["questions"])
app.include_router(potd.router,        prefix="/api/potd",        tags=["potd"])


@app.get("/health")
async def health():
    return {"status": "ok", "app": "Julian", "environment": settings.environment}





@app.exception_handler(Exception)
async def generic_exception_handler(request: Request, exc: Exception):
    logger.error(f"Unhandled error on {request.method} {request.url}: {exc}", exc_info=True)
    return JSONResponse(
        status_code=500,
        content={"detail": "Internal server error. Please try again."},
    )
