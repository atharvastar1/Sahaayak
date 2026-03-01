"""
retriever.py — Production RAG pipeline
Three-stage retrieval: BGE dense → Weighted RRF hybrid → Cross-encoder rerank
Models load once at import time. MODELS_READY flag gates all requests.
"""

import os
import numpy as np
import pandas as pd
import faiss
from sentence_transformers import SentenceTransformer, CrossEncoder
from rank_bm25 import BM25Okapi
from typing import List, Dict

from logger import get_logger, Timer

log = get_logger("retriever")

# ── Config ─────────────────────────────────────────────────────────────────────
CFG = {
    "BIENCODER_MODEL":    "BAAI/bge-small-en-v1.5",
    "CROSSENCODER_MODEL": "cross-encoder/ms-marco-MiniLM-L-6-v2",
    "BIENCODER_TOP_K":    50,
    "RERANK_TOP_K":       5,
    "QUERY_PREFIX":       "Represent this sentence for searching relevant passages: ",
    "MIN_DENSE_SCORE":    0.45,
    "DENSE_WEIGHT":       0.70,
    "BM25_WEIGHT":        0.30,
    "RERANK_FIELDS":      ["scheme_name", "benefits", "eligibility"],
    "RERANK_MAX_CHARS":   400,
}

INDEX_PATH = "data/faiss_bge_cosine.bin"
DATA_PATH  = "data/schemes_processed.parquet"

# ── Load on startup ────────────────────────────────────────────────────────────
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
def retrieve(query: str, top_k: int = CFG["RERANK_TOP_K"]) -> List[Dict]:
    if not MODELS_READY:
        return []

    biencoder_top_k = CFG["BIENCODER_TOP_K"]

    # Stage 1: Dense retrieval
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

    # Stage 2: Weighted RRF
    bm25_scores_arr      = bm25.get_scores(query.lower().split())
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
        results.append({
            "rank":        rank,
            "scheme_name": str(row.get("scheme_name", "")),
            "category":    str(row.get("schemeCategory", "")),
            "benefits":    str(row.get("benefits", ""))[:300],
            "eligibility": str(row.get("eligibility", ""))[:300],
            "scheme_id":   str(row.get("scheme_id", "")),
        })
    return results
