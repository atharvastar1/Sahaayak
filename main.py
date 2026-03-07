"""
main.py — Sahaayak Production API
Team Percepta | AWS AI for Bharat Hackathon

Production features:
  ✅ API Key authentication (X-API-Key header)
  ✅ Rate limiting (slowapi — per IP, configurable)
  ✅ Strict CORS (env-var controlled origins)
  ✅ Structured JSON request/response logging
  ✅ Unique request IDs (for tracing)
  ✅ LRU response cache with TTL
  ✅ Multi-turn session memory
  ✅ Async LLM + TTS with hard timeouts
  ✅ Model warmup on startup
  ✅ Graceful shutdown

Run:
  uvicorn main:app --host 0.0.0.0 --port 8000 --workers 1
  (workers=1 because models are loaded in memory — not safe to fork)
"""

import os
import uuid
import time
from contextlib import asynccontextmanager

from fastapi import FastAPI, HTTPException, Request, Depends
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from fastapi.security.api_key import APIKeyHeader
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded
from dotenv import load_dotenv

from schemas import ChatRequest, ChatResponse, SchemeResult, HealthResponse, ErrorResponse
from retriever import retrieve_async, SCHEMES_LOADED, MODELS_READY, warmup
from llm import generate_explanation, detect_language, get_active_llm_engine
from tts import text_to_speech_base64
from cache import response_cache, session_memory
from logger import get_logger, Timer

load_dotenv()
log = get_logger("main")

# ── Config from env ────────────────────────────────────────────────────────────
APP_ENV          = os.getenv("APP_ENV", "development")
SAHAAYAK_API_KEY = os.getenv("SAHAAYAK_API_KEY", "")
RATE_LIMIT       = os.getenv("RATE_LIMIT_PER_MINUTE", "30")
RAW_ORIGINS      = os.getenv("ALLOWED_ORIGINS", "*")
ALLOWED_ORIGINS  = [o.strip() for o in RAW_ORIGINS.split(",") if o.strip()]

# ── Rate limiter ───────────────────────────────────────────────────────────────
limiter = Limiter(key_func=get_remote_address)

# ── API Key auth ───────────────────────────────────────────────────────────────
api_key_header = APIKeyHeader(name="X-API-Key", auto_error=False)

async def verify_api_key(api_key: str = Depends(api_key_header)) -> str:
    """
    Validates X-API-Key header.
    If SAHAAYAK_API_KEY is not set in env, auth is DISABLED (dev mode).
    """
    if not SAHAAYAK_API_KEY:
        return "dev-mode-no-auth"  # auth disabled in dev

    if api_key != SAHAAYAK_API_KEY:
        raise HTTPException(
            status_code=401,
            detail="Invalid or missing API key. Set X-API-Key header."
        )
    return api_key


# ── Lifespan (startup + shutdown) ─────────────────────────────────────────────
@asynccontextmanager
async def lifespan(app: FastAPI):
    # ── Startup ────────────────────────────────────────────────────────────────
    log.info(f"Sahaayak API starting — env={APP_ENV}")

    if MODELS_READY:
        warmup()  # Pre-warm models so first real request is fast
        log.info(f"Startup complete — {SCHEMES_LOADED} schemes ready")
    else:
        log.error("STARTUP FAILED — data files missing. Check data/ folder.")

    if not SAHAAYAK_API_KEY:
        log.warning("SAHAAYAK_API_KEY not set — API authentication is DISABLED")

    yield  # ← server runs here

    # ── Shutdown ───────────────────────────────────────────────────────────────
    log.info("Shutting down Sahaayak API...")
    response_cache.clear()
    log.info("Cache cleared. Shutdown complete.")


# ── App init ───────────────────────────────────────────────────────────────────
app = FastAPI(
    title="Sahaayak API",
    description="Voice-first AI civic assistant — government scheme discovery for rural India",
    version="1.0.0",
    docs_url="/docs" if APP_ENV != "production" else None,   # hide docs in prod
    redoc_url=None,
    lifespan=lifespan,
)

# Register rate limit error handler
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["GET", "POST"],
    allow_headers=["*"],
)


# ── Request logging middleware ─────────────────────────────────────────────────
@app.middleware("http")
async def log_requests(request: Request, call_next):
    request_id = str(uuid.uuid4())[:8]
    request.state.request_id = request_id
    start = time.perf_counter()

    log.info(
        "Request received",
        extra={
            "ctx_request_id": request_id,
            "ctx_method":     request.method,
            "ctx_path":       request.url.path,
            "ctx_ip":         get_remote_address(request),
        }
    )

    response = await call_next(request)

    elapsed_ms = round((time.perf_counter() - start) * 1000, 1)
    log.info(
        "Request complete",
        extra={
            "ctx_request_id": request_id,
            "ctx_status":     response.status_code,
            "ctx_elapsed_ms": elapsed_ms,
        }
    )
    response.headers["X-Request-ID"] = request_id
    return response


# ── Routes ─────────────────────────────────────────────────────────────────────

@app.get("/health", response_model=HealthResponse, tags=["System"])
def health_check():
    """Health check endpoint — use this for AWS ALB/EC2 health checks."""
    return HealthResponse(
        status         = "ok" if MODELS_READY else "degraded",
        environment    = APP_ENV,
        schemes_loaded = SCHEMES_LOADED,
        models_ready   = MODELS_READY,
        cache_size     = response_cache.size(),
        llm_engine     = get_active_llm_engine(),
    )


@app.get("/engine", tags=["System"])
def engine_info():
    """
    Returns the active LLM engine info.
    Frontend uses this to display the AWS Bedrock / Groq badge.
    """
    engine = get_active_llm_engine()
    return {
        "engine":      engine,
        "primary":     "Amazon Bedrock",
        "model":       __import__('os').getenv('BEDROCK_MODEL_ID', 'amazon.nova-lite-v1:0') if engine == 'bedrock' else 'llama-3.3-70b-versatile',
        "provider":    "AWS" if engine == 'bedrock' else 'Groq',
        "aws_region":  __import__('os').getenv('AWS_REGION', 'ap-south-1'),
        "status":      "active" if engine == 'bedrock' else 'fallback',
    }


@app.post(
    "/chat",
    response_model=ChatResponse,
    tags=["Core"],
    dependencies=[Depends(verify_api_key)],
)
@limiter.limit(f"{RATE_LIMIT}/minute")
async def chat(request: Request, req: ChatRequest):
    """
    Main pipeline endpoint:
      1. Check cache → return instantly if hit
      2. Detect language
      3. RAG retrieval (BGE + BM25 + CrossEncoder)
      4. Groq LLM explanation (with session memory)
      5. gTTS audio generation
      6. Cache result + return
    """
    request_id = getattr(request.state, "request_id", str(uuid.uuid4())[:8])

    if not MODELS_READY:
        raise HTTPException(
            status_code=503,
            detail="Models are loading or data files are missing. Retry in 30 seconds."
        )

    # ── 1. Cache check ─────────────────────────────────────────────────────────
    cached = response_cache.get(req.message)
    if cached:
        log.info("Cache hit", extra={"ctx_request_id": request_id, "ctx_query": req.message[:50]})
        return ChatResponse(**cached, request_id=request_id, cached=True)

    # ── 2. Language detection ──────────────────────────────────────────────────
    language_hint = getattr(req, "language_hint", "") or ""
    language = detect_language(req.message, language_hint)

    # ── 3. RAG retrieval (with auto-translation for non-English queries) ─────────
    with Timer() as t_rag:
        raw_schemes = await retrieve_async(query=req.message, language=language, top_k=5)
    log.info("RAG complete", extra={"ctx_request_id": request_id, "ctx_rag_ms": t_rag.elapsed_ms, "ctx_results": len(raw_schemes)})

    schemes_out = [
        SchemeResult(
            rank        = s["rank"],
            scheme_name = s["scheme_name"],
            category    = s["category"],
            benefits    = s["benefits"],
            eligibility = s["eligibility"],
            scheme_id   = s["scheme_id"],
        )
        for s in raw_schemes
    ]

    # ── 4. LLM explanation (async, with session memory + timeout) ──────────────
    with Timer() as t_llm:
        explanation = await generate_explanation(
            query      = req.message,
            schemes    = raw_schemes,
            language   = language,
            session_id = req.session_id,
            life_event = getattr(req, "life_event", ""),
        )
    log.info("LLM complete", extra={"ctx_request_id": request_id, "ctx_llm_ms": t_llm.elapsed_ms})

    # ── 5. TTS audio (async, with timeout) ────────────────────────────────────
    with Timer() as t_tts:
        audio_b64 = await text_to_speech_base64(text=explanation, language=language)
    log.info("TTS complete", extra={"ctx_request_id": request_id, "ctx_tts_ms": t_tts.elapsed_ms, "ctx_audio": audio_b64 is not None})

    # ── 6. Cache + return ──────────────────────────────────────────────────────
    response_data = {
        "session_id":        req.session_id,
        "text":              explanation,
        "audio_base64":      audio_b64,
        "schemes":           [s.model_dump() for s in schemes_out],
        "language_detected": language,
    }
    response_cache.set(req.message, response_data)

    return ChatResponse(**response_data, request_id=request_id, cached=False)
