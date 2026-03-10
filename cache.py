"""
cache.py — LRU response cache + session conversation memory

Response Cache:
  - Caches full /chat responses keyed by normalized query
  - LRU eviction when max size reached
  - TTL-based expiry (configurable via env)
  - Redis-compatible interface (swap Redis in later with no API changes)

Session Memory:
  - Stores last N messages per session_id
  - In-memory dict (survives hot-reload, not server restart)
  - For hackathon: perfectly fine. For v2: swap to Redis.
"""

import time
import os
from collections import OrderedDict
from typing import Optional, List, Dict, Any


# ── Config ─────────────────────────────────────────────────────────────────────
CACHE_MAX_SIZE   = int(os.getenv("CACHE_MAX_SIZE", 1000))
CACHE_TTL        = int(os.getenv("CACHE_TTL_SECONDS", 3600))   # 1 hour
SESSION_MAX_TURNS = 10   # max messages to remember per session


# ══════════════════════════════════════════════════════════════════════════════
# RESPONSE CACHE
# ══════════════════════════════════════════════════════════════════════════════

class LRUCache:
    """
    Thread-safe-ish LRU cache with TTL.
    Key: normalized query string
    Value: full ChatResponse-compatible dict
    """

    def __init__(self, max_size: int = CACHE_MAX_SIZE, ttl: int = CACHE_TTL):
        self._store: OrderedDict[str, Dict] = OrderedDict()
        self.max_size = max_size
        self.ttl      = ttl

    def _normalize_key(self, query: str) -> str:
        """Normalize query for cache key — lowercase, strip, collapse spaces."""
        return " ".join(query.lower().strip().split())

    def get(self, query: str) -> Optional[Dict]:
        key = self._normalize_key(query)
        if key not in self._store:
            return None

        entry = self._store[key]

        # Check TTL
        if time.time() - entry["_cached_at"] > self.ttl:
            del self._store[key]
            return None

        # Move to end (most recently used)
        self._store.move_to_end(key)
        return entry["data"]

    def set(self, query: str, data: Dict) -> None:
        key = self._normalize_key(query)

        if key in self._store:
            self._store.move_to_end(key)
        else:
            if len(self._store) >= self.max_size:
                self._store.popitem(last=False)  # evict LRU

        self._store[key] = {"data": data, "_cached_at": time.time()}

    def size(self) -> int:
        return len(self._store)

    def clear(self) -> None:
        self._store.clear()


# ══════════════════════════════════════════════════════════════════════════════
# SESSION MEMORY
# ══════════════════════════════════════════════════════════════════════════════

class SessionMemory:
    """
    Stores conversation history per session.
    Each turn = {"role": "user"|"assistant", "content": "..."}
    """

    def __init__(self):
        self._sessions: Dict[str, List[Dict]] = {}

    def add_turn(self, session_id: str, role: str, content: str) -> None:
        if session_id not in self._sessions:
            self._sessions[session_id] = []

        self._sessions[session_id].append({"role": role, "content": content})

        # Keep only last N turns (sliding window)
        if len(self._sessions[session_id]) > SESSION_MAX_TURNS * 2:
            self._sessions[session_id] = self._sessions[session_id][-(SESSION_MAX_TURNS * 2):]

    def get_history(self, session_id: str) -> List[Dict]:
        return self._sessions.get(session_id, [])

    def clear_session(self, session_id: str) -> None:
        self._sessions.pop(session_id, None)

    def active_sessions(self) -> int:
        return len(self._sessions)


# ── Singletons (imported by other modules) ────────────────────────────────────
response_cache  = LRUCache()
session_memory  = SessionMemory()
