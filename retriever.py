"""
retriever.py — Production RAG pipeline
Three-stage retrieval: BGE dense → Weighted RRF hybrid → Cross-encoder rerank
Models load once at import time. MODELS_READY flag gates all requests.

KEY FIX: Non-English queries are first translated to English before FAISS
embedding, because BAAI/bge-small-en-v1.5 is an English-only model. This
dramatically improves retrieval accuracy for Hindi, Marathi, Punjabi, Bengali,
Telugu, Tamil, and all other Indian languages.
"""

import os
import asyncio
import numpy as np
import pandas as pd
import faiss
from sentence_transformers import SentenceTransformer, CrossEncoder
from rank_bm25 import BM25Okapi
from typing import List, Dict, Optional
from groq import AsyncGroq
from dotenv import load_dotenv

from logger import get_logger, Timer
from llm_embeddings import get_embedding, bedrock_embeddings_available
from llm_bedrock import bedrock_available, generate_explanation_bedrock

load_dotenv()
log = get_logger("retriever")

# ── Config ─────────────────────────────────────────────────────────────────────
CFG = {
    "BIENCODER_MODEL":    "BAAI/bge-small-en-v1.5",
    "CROSSENCODER_MODEL": "cross-encoder/ms-marco-MiniLM-L-6-v2",
    "BIENCODER_TOP_K":    50,
    "RERANK_TOP_K":       5,
    "QUERY_PREFIX":       "Represent this sentence for searching relevant passages: ",
    "MIN_DENSE_SCORE":    0.35,   # Lowered from 0.45 to catch more candidates
    "DENSE_WEIGHT":       0.70,
    "BM25_WEIGHT":        0.30,
    "RERANK_FIELDS":      ["scheme_name", "benefits", "eligibility"],
    "RERANK_MAX_CHARS":   400,
}

INDEX_PATH_BGE   = "data/faiss_bge_cosine.bin"
INDEX_PATH_TITAN = "data/faiss_titan_cosine.bin"
DATA_PATH        = "data/schemes_processed.parquet"

# Determine which index to use (Bedrock Titan preferred for AWS Compliance)
if os.path.exists(INDEX_PATH_TITAN) and bedrock_embeddings_available():
    INDEX_PATH = INDEX_PATH_TITAN
    EMBEDDING_MODE = "titan"
    log.info("RAG Engine: Using AWS Bedrock Titan Embeddings")
else:
    INDEX_PATH = INDEX_PATH_BGE
    EMBEDDING_MODE = "bge"
    log.info("RAG Engine: Using Local BGE Embeddings (Fallback)")

# ── Groq client for query translation ─────────────────────────────────────────
_groq = AsyncGroq(api_key=os.getenv("GROQ_API_KEY"))

# Simple in-memory translation cache {original_query: english_translation}
_translation_cache: Dict[str, str] = {}

# ── Load on startup ────────────────────────────────────────────────────────────
# Bi-encoder only needed for local BGE mode
bi_encoder = None
if EMBEDDING_MODE == "bge":
    log.info("Loading bi-encoder...")
    bi_encoder = SentenceTransformer(CFG["BIENCODER_MODEL"])

log.info("Loading cross-encoder...")
cross_encoder = CrossEncoder(CFG["CROSSENCODER_MODEL"])

log.info("Loading FAISS index and scheme data...")
try:
    index = faiss.read_index(INDEX_PATH)
    df    = pd.read_parquet(DATA_PATH)

    tokenized_corpus = [text.split() for text in df["combined_text"].tolist()]
    bm25 = BM25Okapi(tokenized_corpus)

    SCHEMES_LOADED = len(df)
    MODELS_READY   = True
    log.info("Retriever ready", extra={"ctx_schemes": SCHEMES_LOADED})

except FileNotFoundError as e:
    log.error(f"Data files missing: {e}")
    index = None; df = pd.DataFrame(); bm25 = None
    SCHEMES_LOADED = 0; MODELS_READY = False


# ── Query translation: Non-English → English (for BGE embedding accuracy) ─────
async def translate_to_english(query: str, language: str) -> str:
    """
    Translates a non-English query to English using Groq LLM.
    Returns the original query unchanged if language is English or translation fails.
    Uses in-memory cache to avoid redundant API calls.
    """
    if language == "en" or not query.strip():
        return query

    cache_key = f"{language}:{query}"
    if cache_key in _translation_cache:
        return _translation_cache[cache_key]

    try:
        # Prioritize Bedrock for translation if available (AWS Native)
        if bedrock_available():
            prompt = (
                f"You are a precise translator. Translate the following Indian language query to English. "
                f"Output ONLY the English translation — no explanation, no prefix, no quotes. "
                f"Query: {query}"
            )
            translated = await generate_explanation_bedrock(prompt, [], "en")
            if translated and not translated.startswith("Error"):
                _translation_cache[cache_key] = translated.strip()
                log.info(f"Translated (Bedrock) [{language}] '{query[:60]}' → '{translated[:60]}'")
                return translated.strip()

        # Fallback to Groq if Bedrock fails or is unavailable
        response = await asyncio.wait_for(
            _groq.chat.completions.create(
                model="llama-3.1-8b-instant",
                messages=[{
                    "role": "system",
                    "content": (
                        "You are a precise translator. Translate the following Indian language query "
                        "to English. Output ONLY the English translation — no explanation, no prefix, "
                        "no quotes. Keep government scheme names (like PM-KISAN, PMAY) unchanged."
                    )
                }, {
                    "role": "user",
                    "content": query
                }],
                temperature=0.1,
                max_tokens=150,
            ),
            timeout=8,
        )
        translated = response.choices[0].message.content.strip()
        _translation_cache[cache_key] = translated
        log.info(f"Translated (Groq) [{language}] '{query[:60]}' → '{translated[:60]}'")
        return translated
    except Exception as e:
        log.warning(f"Translation failed, using original query: {e}")
        return query


# ── Warmup (call once at startup to JIT-compile models) ───────────────────────
def warmup() -> None:
    """Run a dummy query to force model compilation before first real request."""
    if not MODELS_READY:
        return
    log.info("Running model warmup query...")
    with Timer() as t:
        retrieve("government scheme for farmers", top_k=1)
    log.info(f"Warmup complete in {t.elapsed_ms}ms")


# ── Helper ─────────────────────────────────────────────────────────────────────
def _rerank_doc(row: pd.Series) -> str:
    parts = [str(row.get(f, "")).strip() for f in CFG["RERANK_FIELDS"]]
    return " | ".join(p for p in parts if p)[: CFG["RERANK_MAX_CHARS"]]


# ── Main retrieval ─────────────────────────────────────────────────────────────
def retrieve(query: str, original_query: str = "", top_k: int = CFG["RERANK_TOP_K"]) -> List[Dict]:
    """
    Synchronous retrieval. 
    Uses 'query' (English) for dense retrieval.
    Uses 'query' + 'original_query' for BM25 keyword matching.
    """
    if not MODELS_READY:
        return []

    biencoder_top_k = CFG["BIENCODER_TOP_K"]

    # Stage 1: Dense retrieval (English only)
    if EMBEDDING_MODE == "titan":
        # Bedrock Titan Embeddings
        q_emb_raw = get_embedding(query)
        if q_emb_raw is None: return []
        q_emb = np.array([q_emb_raw]).astype("float32")
    else:
        # Local BGE Embeddings
        prefixed_query = CFG["QUERY_PREFIX"] + query
        q_emb = bi_encoder.encode(
            [prefixed_query], normalize_embeddings=True, convert_to_numpy=True
        ).astype("float32")

    raw_scores, raw_indices = index.search(q_emb, biencoder_top_k)

    dense_scores: Dict[int, float] = {
        int(idx): float(sc)
        for idx, sc in zip(raw_indices[0], raw_scores[0])
        if idx >= 0 and float(sc) >= CFG["MIN_DENSE_SCORE"]
    }
    if not dense_scores:
        return []

    # Stage 2: Weighted RRF with Hybrid Keyword Search
    # Combine English keywords and Original Language keywords for BM25
    combined_keywords = query.lower().split()
    if original_query:
        combined_keywords.extend(original_query.lower().split())
    
    bm25_scores_arr = bm25.get_scores(combined_keywords)
    
    bm25_scores_filtered = {idx: bm25_scores_arr[idx] for idx in dense_scores}
    bm25_ranked  = {idx: r + 1 for r, idx in enumerate(sorted(bm25_scores_filtered, key=bm25_scores_filtered.get, reverse=True))}
    dense_ranked = {idx: r + 1 for r, idx in enumerate(sorted(dense_scores,         key=dense_scores.get,         reverse=True))}

    k = 60
    rrf_scores = {
        i: (CFG["DENSE_WEIGHT"] / (k + dense_ranked.get(i, biencoder_top_k + 1))
          + CFG["BM25_WEIGHT"]  / (k + bm25_ranked.get(i,  biencoder_top_k + 1)))
        for i in dense_scores
    }
    candidate_idx = sorted(rrf_scores, key=rrf_scores.get, reverse=True)[:biencoder_top_k]

    # Stage 3: Cross-encoder rerank
    pairs     = [(query, _rerank_doc(df.iloc[i])) for i in candidate_idx]
    ce_scores = cross_encoder.predict(pairs)
    reranked  = sorted(zip(candidate_idx, ce_scores), key=lambda x: x[1], reverse=True)
    final_idx = [idx for idx, _ in reranked[:top_k]]

    results = []
    for rank, idx in enumerate(final_idx, 1):
        row = df.iloc[idx]
        # Clean scheme name: truncate extremely long names
        raw_name = str(row.get("scheme_name", ""))
        scheme_name = raw_name if len(raw_name) <= 80 else raw_name[:77] + "..."
        results.append({
            "rank":        rank,
            "scheme_name": scheme_name,
            "category":    str(row.get("schemeCategory", "")),
            "benefits":    str(row.get("benefits", ""))[:300],
            "eligibility": str(row.get("eligibility", ""))[:300],
            "scheme_id":   str(row.get("scheme_id", "")),
        })
    return results


async def retrieve_async(query: str, language: str = "en", top_k: int = CFG["RERANK_TOP_K"]) -> List[Dict]:
    """
    Async retrieval with automatic query translation for non-English inputs.
    Uses 'query' for BM25 and 'english_query' for Dense search.
    """
    # 1. Translate to English for high-quality dense retrieval (FAISS)
    english_query = await translate_to_english(query, language)
    
    # 2. Perform hybrid retrieval
    # Pass original query too, so BM25 can match native language seeds/keywords
    return retrieve(query=english_query, original_query=query, top_k=top_k)
