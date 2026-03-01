"""
llm.py — Production Groq LLM service
- Async with configurable timeout
- Injects session conversation history for multi-turn memory
- Hindi/English language detection
- Graceful fallback on timeout or API error
"""

import os
import asyncio
from groq import AsyncGroq
from typing import List, Dict
from dotenv import load_dotenv

from cache import session_memory
from logger import get_logger

load_dotenv()
log = get_logger("llm")

# ── Async Groq client (one instance, reused) ───────────────────────────────────
_client = AsyncGroq(api_key=os.getenv("GROQ_API_KEY"))
LLM_TIMEOUT = int(os.getenv("LLM_TIMEOUT_SECONDS", 15))


# ── Language detection ─────────────────────────────────────────────────────────
def detect_language(text: str) -> str:
    """Returns 'hi' for Hindi (Devanagari or romanized), 'en' otherwise."""
    if any('\u0900' <= c <= '\u097F' for c in text):
        return "hi"

    hindi_words = {
        "kisan", "yojana", "sahayata", "madad", "sarkari", "garib",
        "ghar", "baccha", "mahila", "pension", "ration", "paisa",
        "loan", "subsidy", "bima", "shiksha", "swasthya", "rozgar",
        "hum", "main", "mera", "hamara", "aap", "chahiye", "milega",
        "hai", "hain", "kya", "kaun", "kaise", "kab", "kahan",
    }
    if set(text.lower().split()) & hindi_words:
        return "hi"
    return "en"


# ── System prompts ─────────────────────────────────────────────────────────────
SYSTEM_PROMPT_HI = """
Aap ek sahaayak government scheme advisor hain jo rural Indian citizens ki madad karte hain.
Aapka kaam hai unhein sahi sarkari yojanaon ki jaankari dena.

Niyam:
1. Sirf neeche diye gaye schemes ke baare mein batao — kuch bhi naya mat banao.
2. Simple aur seedhi bhasha use karo — jaise kisi gaon ke insaan se baat kar rahe ho.
3. Batao ki user ke liye kaunsi scheme sabse zyada helpful hai aur kyun.
4. Agar pichle sawaal ka context ho, toh usse dhyan mein rakho.
5. Response 3-4 sentences mein rakho — zyada lamba mat karo.
6. Hindi mein jawab do.
"""

SYSTEM_PROMPT_EN = """
You are a helpful Indian Government Scheme advisor for rural and underserved citizens.

Rules:
1. Only reference the schemes listed below — never invent schemes.
2. Use simple, clear language — as if speaking to someone unfamiliar with bureaucracy.
3. Tell the user which scheme is most relevant and why, in 3-4 sentences.
4. If there is prior conversation context, use it to give a better answer.
5. Be empathetic and encouraging. These users need real help.
6. Respond in English.
"""


# ── Main async function ────────────────────────────────────────────────────────
async def generate_explanation(
    query: str,
    schemes: List[Dict],
    language: str = "en",
    session_id: str = "",
) -> str:
    """
    Generate LLM explanation for matched schemes.
    Includes conversation history from session_memory for multi-turn context.
    Enforces a hard timeout — returns a polite fallback if exceeded.
    """
    if not schemes:
        return (
            "Maafi kijiye, aapke sawaal se milti-julti koi sarkari yojana abhi nahi mili. Kripya alag shabdon mein poochhen."
            if language == "hi"
            else "Sorry, I couldn't find matching government schemes for your query. Please try rephrasing."
        )

    # Build scheme context block
    context = "\n".join(
        f"Scheme: {s['scheme_name']}\nBenefits: {s['benefits']}\nEligibility: {s['eligibility']}\n"
        for s in schemes
    )

    system_prompt = SYSTEM_PROMPT_HI if language == "hi" else SYSTEM_PROMPT_EN

    # Build messages: system + history (last 6 turns) + current query
    history = session_memory.get_history(session_id)[-6:]  # last 3 exchanges
    messages = [{"role": "system", "content": system_prompt}]
    messages.extend(history)
    messages.append({
        "role": "user",
        "content": f"User Query: {query}\n\nRetrieved Schemes:\n{context}\n\nPlease explain which schemes are most relevant."
    })

    try:
        response = await asyncio.wait_for(
            _client.chat.completions.create(
                model="llama3-8b-8192",
                messages=messages,
                temperature=0.4,
                max_tokens=300,
            ),
            timeout=LLM_TIMEOUT,
        )
        explanation = response.choices[0].message.content.strip()

        # Save this turn to session memory
        if session_id:
            session_memory.add_turn(session_id, "user", query)
            session_memory.add_turn(session_id, "assistant", explanation)

        return explanation

    except asyncio.TimeoutError:
        log.warning("LLM timeout", extra={"ctx_session": session_id, "ctx_timeout": LLM_TIMEOUT})
        return (
            "Iss waqt server busy hai. Kripya thodi der baad try karein."
            if language == "hi"
            else "The service is busy right now. Please try again in a moment."
        )
    except Exception as e:
        log.error(f"Groq LLM error: {e}", extra={"ctx_session": session_id})
        return (
            "Iss samay jawab dene mein takleef ho rahi hai. Kripya thodi der baad try karein."
            if language == "hi"
            else "Unable to generate explanation at this time. Please try again shortly."
        )
