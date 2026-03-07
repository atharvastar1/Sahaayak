"""
llm_polly.py — Amazon Polly Text-to-Speech Integration
AWS Service: Polly (Neural Engine for high quality)
"""

import boto3
import os
import base64
from typing import Optional
from botocore.config import Config

from logger import get_logger

log = get_logger("polly")

# ── Config ─────────────────────────────────────────────────────────────────────
region   = os.getenv("AWS_REGION", "ap-south-1")
voice_id = os.getenv("POLLY_VOICE_ID", "Aditi")  # Hindi/English neutral female voice

_client = None

def _init_client():
    global _client
    if _client: return True
    
    # Check for credentials
    access_key = os.getenv("AWS_ACCESS_KEY_ID")
    secret_key = os.getenv("AWS_SECRET_ACCESS_KEY")
    
    if not (access_key and secret_key):
        return False
        
    try:
        _client = boto3.client(
            service_name='polly',
            region_name=region,
            aws_access_key_id=access_key,
            aws_secret_access_key=secret_key
        )
        return True
    except Exception as e:
        log.error(f"Failed to initialize Polly client: {e}")
        return False

def generate_polly_audio_base64(text: str, language: str = "en") -> Optional[str]:
    """
    Synchronous call to generate audio using Amazon Polly.
    Returns base64-encoded MP3 or None on failure.
    """
    if not _init_client():
        return None
        
    # Language Code Mapping for Polly
    # Polly supports en-IN (Aditi, Raveena), hi-IN (Aditi), mr-IN (expected soon)
    # Falling back to hi-IN for Hindi/Marathi/Punjabi for now as Aditi is polyglot
    lang_code_map = {
        "en": "en-IN",
        "hi": "hi-IN",
        "mr": "hi-IN",
        "pa": "hi-IN"
    }
    target_lang = lang_code_map.get(language, "en-IN")
    
    try:
        response = _client.synthesize_speech(
            Text=text,
            OutputFormat='mp3',
            VoiceId=voice_id,
            Engine='neural',  # Use Neural for better quality
            LanguageCode=target_lang
        )
        
        if "AudioStream" in response:
            audio_data = response["AudioStream"].read()
            return base64.b64encode(audio_data).decode("utf-8")
        else:
            return None
            
    except Exception as e:
        log.error(f"Polly synthesis error: {e}")
        return None

def polly_available() -> bool:
    """Health check for TTS initialization."""
    return _init_client()
