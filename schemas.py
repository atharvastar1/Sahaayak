"""
schemas.py — Production-grade request/response models
All inputs are validated and sanitized before processing.
"""

import re
from pydantic import BaseModel, Field, field_validator
from typing import List, Optional


# ── Inbound ────────────────────────────────────────────────────────────────────

class ChatRequest(BaseModel):
    message: str = Field(..., min_length=1, max_length=500)
    session_id: str = Field(..., min_length=1, max_length=100)
    language_hint: Optional[str] = Field(default="", max_length=5)  # e.g. "hi", "mr", "pa", "en"
    life_event: Optional[str] = Field(default="", max_length=50) # e.g., 'farmer', 'student', 'worker'

    @field_validator("message")
    @classmethod
    def sanitize_message(cls, v: str) -> str:
        # Strip leading/trailing whitespace
        v = v.strip()
        # Remove control characters (except newline/tab)
        v = re.sub(r"[\x00-\x08\x0b\x0c\x0e-\x1f\x7f]", "", v)
        if not v:
            raise ValueError("Message cannot be empty after sanitization")
        return v

    @field_validator("session_id")
    @classmethod
    def sanitize_session_id(cls, v: str) -> str:
        # Only allow alphanumeric, hyphens, underscores
        v = v.strip()
        if not re.match(r"^[a-zA-Z0-9\-_]+$", v):
            raise ValueError("session_id must be alphanumeric with hyphens/underscores only")
        return v


# ── Outbound ───────────────────────────────────────────────────────────────────

class SchemeResult(BaseModel):
    rank: int
    scheme_name: str
    category: str
    benefits: str
    eligibility: str
    scheme_id: str


class ChatResponse(BaseModel):
    request_id: str                    # Unique ID for this request (for logging/debugging)
    session_id: str
    text: str
    audio_base64: Optional[str]        # base64 MP3, None if TTS failed
    schemes: List[SchemeResult]
    language_detected: str             # "hi" or "en"
    cached: bool = False               # True if response came from cache


class HealthResponse(BaseModel):
    status: str
    environment: str
    schemes_loaded: int
    models_ready: bool
    cache_size: int
    llm_engine: str = "groq"   # "bedrock" when AWS is active, "groq" otherwise


class ErrorResponse(BaseModel):
    error: str
    detail: str
    request_id: str
