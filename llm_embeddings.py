"""
llm_embeddings.py — Amazon Bedrock Titan Embeddings Integration
AWS Service: Bedrock (Titan G1 - Text Embeddings v2)
"""

import boto3
import json
import os
import numpy as np
from typing import List, Optional
from botocore.config import Config

from logger import get_logger

log = get_logger("embeddings")

# ── Config ─────────────────────────────────────────────────────────────────────
region   = os.getenv("AWS_REGION", "ap-south-1")
model_id = os.getenv("BEDROCK_EMBEDDING_MODEL_ID", "amazon.titan-embed-text-v1")

# Configure Bedrock client with custom retry logic and timeouts
bedrock_config = Config(
    region_name=region,
    retries={'max_attempts': 3, 'mode': 'standard'},
    connect_timeout=5,
    read_timeout=15
)

_client = None

def _init_client():
    global _client
    if _client: return True
    
    # Check for credentials
    access_key = os.getenv("AWS_ACCESS_KEY_ID")
    secret_key = os.getenv("AWS_SECRET_ACCESS_KEY")
    
    if not (access_key and secret_key):
        log.warning("AWS credentials missing — Bedrock Embeddings disabled")
        return False
        
    try:
        _client = boto3.client(
            service_name='bedrock-runtime',
            aws_access_key_id=access_key,
            aws_secret_access_key=secret_key,
            config=bedrock_config
        )
        return True
    except Exception as e:
        log.error(f"Failed to initialize Bedrock Embeddings client: {e}")
        return False

def get_embeddings(texts: List[str]) -> Optional[np.ndarray]:
    """
    Synchronous call to generate embeddings for a list of texts using Bedrock Titan.
    Returns a numpy array of shape (len(texts), dim) or None on failure.
    Dim for Titan Embed v1 is 1536.
    """
    if not _init_client():
        return None
        
    embeddings = []
    
    # Bedrock Titan processes one text at a time (batching is recommended)
    for text in texts:
        try:
            body = json.dumps({"inputText": text})
            response = _client.invoke_model(
                body=body,
                modelId=model_id,
                accept='application/json',
                contentType='application/json'
            )
            
            response_body = json.loads(response.get('body').read())
            embedding = response_body.get('embedding')
            embeddings.append(embedding)
            
        except Exception as e:
            log.error(f"Bedrock Embedding error for '{text[:30]}...': {e}")
            return None
            
    return np.array(embeddings).astype("float32")

def get_embedding(text: str) -> Optional[np.ndarray]:
    """Convenience for single text."""
    res = get_embeddings([text])
    return res[0] if res is not None else None

def bedrock_embeddings_available() -> bool:
    """Health check for RAG initialization."""
    return _init_client()
