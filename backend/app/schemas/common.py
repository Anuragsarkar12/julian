# backend/app/schemas/common.py
from pydantic import BaseModel
from typing import Optional


class ErrorResponse(BaseModel):
    detail: str


class HealthResponse(BaseModel):
    status: str
    app: str
    environment: str
