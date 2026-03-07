"""
llm_bedrock.py — Amazon Bedrock LLM integration for Sahaayak
Team Percepta | AWS AI for Bharat Hackathon

- Primary model: Amazon Nova Lite (ap-south-1 region)
- Falls back gracefully when AWS credentials are not configured
- Exposes the same async interface as llm.py (generate_explanation)
- Supports all 22+ Indian scheduled languages via structured prompting

Model options:
  amazon.nova-lite-v1:0     ← fast, cost-efficient (default)
  amazon.nova-pro-v1:0      ← higher quality
  anthropic.claude-3-haiku-20240307-v1:0  ← Claude Haiku
  anthropic.claude-3-sonnet-20240229-v1:0 ← Claude Sonnet
"""

import os
import json
import asyncio
import logging
from typing import List, Dict, Optional
from concurrent.futures import ThreadPoolExecutor

from dotenv import load_dotenv

load_dotenv()
log = logging.getLogger("llm_bedrock")

# ── Config ─────────────────────────────────────────────────────────────────────
AWS_REGION        = os.getenv("AWS_REGION", "ap-south-1")
BEDROCK_MODEL_ID  = os.getenv("BEDROCK_MODEL_ID", "amazon.nova-lite-v1:0")
BEDROCK_TIMEOUT   = int(os.getenv("BEDROCK_TIMEOUT_SECONDS", "20"))

# Thread pool for blocking boto3 calls in async context
_executor = ThreadPoolExecutor(max_workers=2, thread_name_prefix="bedrock")

# Boto3 client — lazy-initialized so missing credentials don't crash startup
_bedrock_client = None
_bedrock_ready  = False

def _init_client() -> bool:
    """
    Try to initialize the Bedrock Runtime client.
    Returns True if successful, False if credentials/region are missing.
    """
    global _bedrock_client, _bedrock_ready
    if _bedrock_ready:
        return True

    aws_key    = os.getenv("AWS_ACCESS_KEY_ID", "")
    aws_secret = os.getenv("AWS_SECRET_ACCESS_KEY", "")

    if not aws_key or not aws_secret:
        log.info("Bedrock: AWS credentials not set — using Groq fallback.")
        return False

    try:
        import boto3
        _bedrock_client = boto3.client(
            service_name="bedrock-runtime",
            region_name=AWS_REGION,
            aws_access_key_id=aws_key,
            aws_secret_access_key=aws_secret,
        )
        # Quick connectivity check with a tiny prompt
        _ping_bedrock(_bedrock_client)
        _bedrock_ready = True
        log.info(f"Bedrock: Connected ✅  model={BEDROCK_MODEL_ID}  region={AWS_REGION}")
        return True
    except ImportError:
        log.warning("Bedrock: boto3 not installed. Run: pip install boto3")
        return False
    except Exception as e:
        log.warning(f"Bedrock: Could not connect ({e}) — using Groq fallback.")
        return False


def _ping_bedrock(client) -> None:
    """
    Send a minimal 1-token request to confirm the endpoint is reachable.
    Raises on failure.
    """
    _invoke_model_sync(client, "Hello", "en")


def bedrock_available() -> bool:
    """
    Public check: returns True if Bedrock is configured and reachable.
    Cached after first successful check.
    """
    return _init_client()


# ── Language prompt helpers (shared with llm.py concept) ─────────────────────

def _build_prompt(query: str, schemes: List[Dict], language: str) -> str:
    """Build the full user prompt with retrieved scheme context."""
    context_parts = []
    for s in schemes:
        context_parts.append(
            f"Scheme: {s['scheme_name']}\n"
            f"Benefits: {s['benefits']}\n"
            f"Eligibility: {s['eligibility']}\n"
        )
    context = "\n".join(context_parts)

    lang_instructions = {
        "en":  "Respond in clear, simple English.",
        "hi":  "केवल हिंदी में उत्तर दें, देवनागरी लिपि में।",
        "mr":  "फक्त मराठीत उत्तर द्या, देवनागरी लिपीत।",
        "pa":  "ਸਿਰਫ਼ ਪੰਜਾਬੀ ਵਿੱਚ ਜਵਾਬ ਦਿਓ, ਗੁਰਮੁਖੀ ਲਿਪੀ ਵਿੱਚ।",
        "te":  "తెలుగులో మాత్రమే సమాధానం చెప్పండి.",
        "ta":  "தமிழில் மட்டும் பதில் சொல்லுங்கள்.",
        "kn":  "ಕನ್ನಡದಲ್ಲಿ ಮಾತ್ರ ಉತ್ತರಿಸಿ.",
        "ml":  "മലയാളത്തിൽ മാത്രം ഉത്തരം നൽകുക.",
        "bn":  "শুধুমাত্র বাংলায় উত্তর দিন।",
        "gu":  "ફક્ત ગુજરાતીમાં જવાબ આપો.",
        "or":  "ଓଡ଼ିଆରେ ଉତ୍ତର ଦିଅ।",
        "as":  "অসমীয়াত উত্তৰ দিয়া।",
        "ur":  "صرف اردو میں جواب دیں۔",
        "ne":  "नेपालीमा मात्र उत्तर दिनुहोस्।",
    }
    lang_note = lang_instructions.get(language, lang_instructions["en"])

    return (
        f"You are Sahaayak, an AI assistant helping rural Indian citizens access government schemes.\n\n"
        f"Rules:\n"
        f"1. Only reference schemes listed below — never invent schemes.\n"
        f"2. Use simple, clear language.\n"
        f"3. Identify the most relevant scheme and explain why it fits.\n"
        f"4. Keep response to 3-5 sentences maximum.\n"
        f"5. Be empathetic and encouraging.\n"
        f"6. CRITICAL: {lang_note}\n\n"
        f"User Query: {query}\n\n"
        f"Retrieved Government Schemes:\n{context}\n\n"
        f"Please explain which scheme(s) are most relevant for this user."
    )


# ── Bedrock invocation ─────────────────────────────────────────────────────────

def _invoke_model_sync(client, prompt: str, language: str) -> str:
    """
    Synchronous Bedrock invocation. Handles both Nova and Claude model formats.
    """
    model_id = BEDROCK_MODEL_ID

    # Amazon Nova / Titan text format
    if "nova" in model_id or "titan" in model_id:
        body = {
            "messages": [
                {"role": "user", "content": [{"text": prompt}]}
            ],
            "inferenceConfig": {
                "max_new_tokens": 400,
                "temperature": 0.3,
            }
        }
        response = client.invoke_model(
            modelId=model_id,
            body=json.dumps(body),
            contentType="application/json",
            accept="application/json",
        )
        result = json.loads(response["body"].read())
        return result["output"]["message"]["content"][0]["text"].strip()

    # Anthropic Claude format
    elif "claude" in model_id:
        body = {
            "anthropic_version": "bedrock-2023-05-31",
            "max_tokens": 400,
            "temperature": 0.3,
            "messages": [
                {"role": "user", "content": prompt}
            ]
        }
        response = client.invoke_model(
            modelId=model_id,
            body=json.dumps(body),
            contentType="application/json",
            accept="application/json",
        )
        result = json.loads(response["body"].read())
        return result["content"][0]["text"].strip()

    else:
        raise ValueError(f"Unsupported Bedrock model: {model_id}")


# ── Public async function ──────────────────────────────────────────────────────

async def generate_explanation_bedrock(
    query: str,
    schemes: List[Dict],
    language: str = "en",
    session_id: str = "",
) -> Optional[str]:
    """
    Generate an explanation using Amazon Bedrock.
    Returns the explanation string, or None if Bedrock is unavailable/fails.
    This allows llm.py to fall back to Groq seamlessly.
    """
    if not schemes:
        return None   # Let llm.py handle the no-results fallback

    if not _init_client():
        return None   # Credentials not available — fall back to Groq

    prompt = _build_prompt(query, schemes, language)

    try:
        loop = asyncio.get_event_loop()
        result: str = await asyncio.wait_for(
            loop.run_in_executor(
                _executor,
                _invoke_model_sync,
                _bedrock_client,
                prompt,
                language,
            ),
            timeout=BEDROCK_TIMEOUT,
        )
        log.info(
            f"Bedrock: OK  model={BEDROCK_MODEL_ID}  lang={language}  "
            f"session={session_id[:8] if session_id else '-'}"
        )
        return result

    except asyncio.TimeoutError:
        log.warning(f"Bedrock: Timeout after {BEDROCK_TIMEOUT}s — falling back to Groq")
        return None
    except Exception as e:
        log.error(f"Bedrock: Invocation error — {e}")
        return None
