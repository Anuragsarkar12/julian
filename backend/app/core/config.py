# backend/app/core/config.py
from pydantic_settings import BaseSettings
from functools import lru_cache


class Settings(BaseSettings):
    # Supabase
    supabase_url: str
    supabase_anon_key: str
    supabase_service_role_key: str
    supabase_storage_bucket: str = "recordings"
    supabase_jwt_secret: str  # Settings > API > JWT Settings > JWT Secret

    # Gemini
    gemini_api_key: str
    
    # Groq
    groq_api_key: str

    # App
    environment: str = "development"
    allowed_origins: str = "http://localhost:3000"
    tmp_dir: str = "/tmp"

    # Whisper
    whisper_model_size: str = "base"
    max_recording_duration_seconds: int = 300

    class Config:
        env_file = ".env"
        case_sensitive = False

    @property
    def allowed_origins_list(self) -> list[str]:
        return [o.strip() for o in self.allowed_origins.split(",")]

    @property
    def is_production(self) -> bool:
        return self.environment == "production"


@lru_cache()
def get_settings() -> Settings:
    return Settings()
