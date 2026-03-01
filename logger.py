"""
logger.py — Structured JSON logging for production
Every log line is a JSON object — easy to ship to CloudWatch or Datadog.
"""

import logging
import json
import time
import os
from datetime import datetime, timezone


class JSONFormatter(logging.Formatter):
    """Formats log records as single-line JSON for CloudWatch ingestion."""

    def format(self, record: logging.LogRecord) -> str:
        log_obj = {
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "level":     record.levelname,
            "logger":    record.name,
            "message":   record.getMessage(),
            "env":       os.getenv("APP_ENV", "development"),
        }
        # Attach any extra fields passed via extra={}
        for key, val in record.__dict__.items():
            if key.startswith("ctx_"):
                log_obj[key[4:]] = val  # strip ctx_ prefix

        if record.exc_info:
            log_obj["exception"] = self.formatException(record.exc_info)

        return json.dumps(log_obj, ensure_ascii=False)


def get_logger(name: str = "sahaayak") -> logging.Logger:
    logger = logging.getLogger(name)

    if logger.handlers:
        return logger  # already configured

    level = os.getenv("LOG_LEVEL", "INFO").upper()
    logger.setLevel(getattr(logging, level, logging.INFO))

    handler = logging.StreamHandler()
    handler.setFormatter(JSONFormatter())
    logger.addHandler(handler)
    logger.propagate = False

    return logger


# ── Convenience timing context manager ────────────────────────────────────────

class Timer:
    """Usage: with Timer() as t: ...  then t.elapsed_ms"""

    def __enter__(self):
        self._start = time.perf_counter()
        return self

    def __exit__(self, *args):
        self.elapsed_ms = round((time.perf_counter() - self._start) * 1000, 1)
