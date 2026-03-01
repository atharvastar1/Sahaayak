"""
tts.py — gTTS Text-to-Speech with async timeout wrapper
Returns base64-encoded MP3. Uses in-memory buffer — no disk writes.
"""

import io
import base64
import asyncio
import os
from concurrent.futures import ThreadPoolExecutor
from gtts import gTTS

from logger import get_logger

log = get_logger("tts")
TTS_TIMEOUT = int(os.getenv("TTS_TIMEOUT_SECONDS", 10))

# Thread pool for running blocking gTTS in async context
_executor = ThreadPoolExecutor(max_workers=2)


def _generate_audio(text: str, lang: str) -> str | None:
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


async def text_to_speech_base64(text: str, language: str = "en") -> str | None:
    """
    Async wrapper around gTTS with hard timeout.
    Returns base64 MP3 string or None on failure/timeout.
    """
    gtts_lang = "hi" if language == "hi" else "en"

    try:
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
