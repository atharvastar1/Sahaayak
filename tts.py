"""
tts.py — gTTS Text-to-Speech with async timeout wrapper
Returns base64-encoded MP3. Uses in-memory buffer — no disk writes.
"""

import io
import base64
import asyncio
import os
from typing import Optional
from concurrent.futures import ThreadPoolExecutor
from gtts import gTTS

from logger import get_logger
from llm_polly import generate_polly_audio_base64, polly_available

log = get_logger("tts")
TTS_TIMEOUT = int(os.getenv("TTS_TIMEOUT_SECONDS", 18))

# Thread pool for running blocking gTTS in async context
_executor = ThreadPoolExecutor(max_workers=2)


def _generate_audio(text: str, lang: str) -> Optional[str]:
    """Blocking gTTS call — runs in thread pool."""
    try:
        tts = gTTS(text=text, lang=lang, slow=False)
        buf = io.BytesIO()
        tts.write_to_fp(buf)
        buf.seek(0)
        return base64.b64encode(buf.read()).decode("utf-8")
    except Exception as e:
        log.error(f"gTTS error: {e}")
        return None


async def text_to_speech_base64(text: str, language: str = "en") -> Optional[str]:
    """
    Async wrapper around gTTS with hard timeout.
    Returns base64 MP3 string or None on failure/timeout.
    """
    # Map internal codes to gTTS supported codes
    # hi=Hindi, mr=Marathi, pa=Punjabi (Gurmukhi), en=English
    lang_map = {
        "hi": "hi",
        "mr": "mr",
        "pa": "pa",
        "en": "en"
    }
    gtts_lang = lang_map.get(language, "en")

    try:
        # Prioritize Amazon Polly (AWS Native)
        if polly_available():
            polly_result = generate_polly_audio_base64(text, language)
            if polly_result:
                log.info(f"TTS complete via Amazon Polly [{language}]")
                return polly_result

        # Fallback to gTTS
        loop   = asyncio.get_event_loop()
        result = await asyncio.wait_for(
            loop.run_in_executor(_executor, _generate_audio, text, gtts_lang),
            timeout=TTS_TIMEOUT,
        )
        return result
    except asyncio.TimeoutError:
        log.warning("TTS timeout — returning text-only response")
        return None
    except Exception as e:
        log.error(f"TTS wrapper error: {e}")
        return None
