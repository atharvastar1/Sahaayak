<<<<<<< HEAD
# Sahaayak - The Citizen AI 🇮🇳

Sahaayak is a next-generation AI assistant designed to bridge the digital divide for rural India. By combining multi-dialect voice intelligence with a premium, accessible UI, Sahaayak empowers every citizen to navigate government schemes and services with ease.

## Key Features

### 🎙️ Liquid Mic Technology
- **Voice-First Interaction:** Citizens can speak in their native dialect.
- **Real-time Visualization:** A glowing, tactile "Silicon Orb" provides instant feedback.
- **Dialect Normalization:** High-precision AI translates local dialects into actionable queries.

### Enterprise Web Dashboard
- **Glassmorphic Design:** A premium, modern interface with floating glow orbs and soft surfaces.
- **Bento Grid Layout:** Organized, high-contrast cards for a professional and accessible experience.
- **Staggered Animations:** Smooth, cinematic entrance for all UI elements.

### Omni-Channel Chat (WhatsApp)
- **Official Identity:** Verified "Sahaayak BharatBot" branding for trust.
- **Seamless Transition:** Move from voice interaction to a full-screen interactive chat hub.
- **Interactive Experience:** Familiar chat interface optimized for government service delivery.

### Premium Branding & Animation
- **Animated SVG Logo:** A breathing, floating logo integrated across Mobile and Web.
- **Elite Design Tokens:** High-end blur effects, custom shadows, and refined typography (Outfit).

## Real UI Screenshots

### Mobile Main Interface
![Mobile Home Interface](/Users/atharvainteractives/.gemini/antigravity/scratch/sahaayak/flutter_sahaayak/assets/screenshots/microscreen_screenshot.png)

### Citizen Insights Dashboard
![Citizen Dashboard](/Users/atharvainteractives/.gemini/antigravity/scratch/sahaayak/flutter_sahaayak/assets/screenshots/dashboard_screenshot.png)

### Premium Branding (Splash)
![Premium Splash](/Users/atharvainteractives/.gemini/antigravity/scratch/sahaayak/flutter_sahaayak/assets/screenshots/screenshot_emulator.png)

##  Technology Stack
- **Frontend:** Flutter (Mobile), Vanilla JS/HTML5/CSS3 (Web)
- **Animations:** Flutter Animate, CSS Keyframes
- **Branding:** SVG with real-time vector animation
- **Typography:** Outfit (Google Fonts)

---
*Built with Love for Bharat.*
=======
# Sahaayak Backend — Production

Voice-first AI civic assistant for rural India.  
Team Percepta | AWS AI for Bharat Hackathon

---

## Quick Start (Local)

```bash
pip install -r requirements.txt
cp .env .env.local   # fill in your keys
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

## Production (AWS EC2)

```bash
# On your local machine — copy files to EC2
scp -r ./sahaayak-backend-prod ubuntu@YOUR_EC2_IP:/opt/sahaayak

# On EC2
chmod +x /opt/sahaayak/deploy.sh
bash /opt/sahaayak/deploy.sh
```

---

## API

### POST /chat
```bash
curl -X POST http://localhost:8000/chat \
  -H "Content-Type: application/json" \
  -H "X-API-Key: your_api_key" \
  -d '{"message": "kisan ko loan chahiye", "session_id": "user-123"}'
```

Response:
```json
{
  "request_id": "a1b2c3d4",
  "session_id": "user-123",
  "text": "Aapke liye PM-KISAN aur Kisan Credit Card...",
  "audio_base64": "<base64 MP3>",
  "schemes": [...],
  "language_detected": "hi",
  "cached": false
}
```

### GET /health
```json
{
  "status": "ok",
  "environment": "production",
  "schemes_loaded": 3397,
  "models_ready": true,
  "cache_size": 42
}
```

---

## Production Features

| Feature | Implementation |
|---|---|
| API Auth | `X-API-Key` header (`SAHAAYAK_API_KEY` in .env) |
| Rate Limiting | 30 req/min per IP (slowapi) |
| CORS | Locked to `ALLOWED_ORIGINS` in .env |
| Request Logging | Structured JSON → CloudWatch-ready |
| Request IDs | Every request gets `X-Request-ID` header |
| Response Cache | LRU + TTL (200 entries, 1hr default) |
| Session Memory | Last 10 turns per session_id |
| LLM Timeout | 15s hard timeout on Groq calls |
| TTS Timeout | 10s hard timeout on gTTS |
| Model Warmup | Runs dummy query on startup |
| Graceful Shutdown | Cache cleared, logs flushed |

---

## File Structure

```
sahaayak-backend-prod/
├── main.py          # FastAPI app — all middleware and routes
├── retriever.py     # BGE + FAISS + BM25 + CrossEncoder RAG
├── llm.py           # Async Groq LLM with session memory
├── tts.py           # Async gTTS with timeout
├── schemas.py       # Pydantic request/response models
├── cache.py         # LRU response cache + session memory
├── logger.py        # Structured JSON logger
├── deploy.sh        # EC2 one-shot deployment script
├── requirements.txt
└── .env             # All secrets (never commit)
    data/
    ├── faiss_bge_cosine.bin
    └── schemes_processed.parquet
```

---

## Generate your API key

```bash
python -c "import secrets; print(secrets.token_hex(32))"
```
Set this as `SAHAAYAK_API_KEY` in `.env` and as `X-API-Key` in your frontend.

---

Team Percepta | License: MIT
>>>>>>> 363041d (feat: production ready backend with caching, auth, and rate limiting)
