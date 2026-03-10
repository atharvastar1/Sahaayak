---
title: Sahaayak API
emoji: ✨
colorFrom: blue
colorTo: green
sdk: docker
pinned: false
---

# Sahaayak - The Citizen AI 🇮🇳

Sahaayak is a voice-first AI civic assistant designed to improve access to government schemes and public services for citizens in rural and underserved communities. The platform combines multi-dialect voice intelligence, AI-based scheme matching, and scalable backend infrastructure to help users navigate government services using natural voice interaction.

## 🌟 Key Features

### 🎙️ Liquid Mic Technology
- **Voice-First Interaction:** Citizens can speak in their native dialect.
- **Real-time Visualization:** A glowing, tactile "Silicon Orb" provides instant feedback.
- **Dialect Normalization:** High-precision AI translates local dialects into actionable queries.

### 🍱 Enterprise Web Dashboard
- **Glassmorphic Design:** A premium, modern interface with floating glow orbs and soft surfaces.
- **Bento Grid Layout:** Organized, high-contrast cards for a professional and accessible experience.
- **Staggered Animations:** Smooth, cinematic entrance for all UI elements.

### 💬 Omni-Channel Chat (WhatsApp)
- **Official Identity:** Verified "Sahaayak BharatBot" branding for trust.
- **Seamless Transition:** Move from voice interaction to a full-screen interactive chat hub.
- **Interactive Experience:** Familiar chat interface optimized for government service delivery.

### 🎨 Premium Branding & Animation
- **Animated SVG Logo:** A breathing, floating logo integrated across Mobile and Web.
- **Elite Design Tokens:** High-end blur effects, custom shadows, and refined typography (Outfit).

## 📸 Real UI Screenshots

### Mobile Main Interface
![Mobile Home Interface](/Users/atharvainteractives/.gemini/antigravity/scratch/sahaayak/flutter_sahaayak/assets/screenshots/microscreen_screenshot.png)

### Citizen Insights Dashboard
![Citizen Dashboard](/Users/atharvainteractives/.gemini/antigravity/scratch/sahaayak/flutter_sahaayak/assets/screenshots/dashboard_screenshot.png)

### Premium Branding (Splash)
![Premium Splash](/Users/atharvainteractives/.gemini/antigravity/scratch/sahaayak/flutter_sahaayak/assets/screenshots/screenshot_emulator.png)

## 🛠️ Technology Stack
- **Frontend:** Flutter (Mobile), Vanilla JS/HTML5/CSS3 (Web)
- **Animations:** Flutter Animate, CSS Keyframes
- **Branding:** SVG with real-time vector animation
- **Typography:** Outfit (Google Fonts)

---
*Built with ❤️ for Bharat.*

# Sahaayak Backend — Production

Voice-first AI civic assistant for rural India.  
Team Percepta | AWS AI for Bharat Hackathon

---

# Project Overview

Many citizens in rural India face barriers when accessing government schemes due to language differences, low digital literacy, and limited internet connectivity. Sahaayak addresses these challenges through a voice-driven AI interface capable of understanding regional dialects and providing step-by-step assistance.

The system allows users to speak in their native dialect, receive scheme recommendations based on eligibility, and get guidance through the application process.

---

# Key Features

## Voice-First Interaction
Citizens interact with the platform using voice input instead of typing.

## Dialect Normalization
AI models detect and normalize regional dialects into standard language.

## AI-Based Scheme Matching
The system analyzes user queries and recommends relevant government schemes.

## Guided Application Assistant
Users receive step-by-step instructions to complete applications.

## Community-Driven Feedback
User feedback improves the AI model through reinforcement learning.

## Low-Bandwidth Optimization
The system is designed to function in areas with limited internet connectivity.

## Life-Event Assistance
Schemes are suggested based on life situations such as farming, education, or employment.

## Secure and Privacy-Focused Design
User data is handled with minimal storage and secure communication.

---

# System Components

### Mobile Application
Flutter-based voice interface enabling speech interaction.

### Web Dashboard
Web interface for monitoring usage analytics and insights.

### Backend API
FastAPI backend responsible for AI processing, scheme retrieval, and response generation.

---

# Technology Stack

## Frontend
- Flutter (Mobile)
- HTML
- CSS
- JavaScript

## Backend
- Python
- FastAPI

## Artificial Intelligence
- Whisper Speech-to-Text
- Groq LLM
- BGE Embeddings
- FAISS Vector Search
- BM25 Retrieval
- CrossEncoder Reranking

## Text-to-Speech
- gTTS

## Cloud Infrastructure
- AWS EC2
- AWS S3
- AWS RDS

---

# Backend Architecture

The backend uses a Retrieval Augmented Generation (RAG) pipeline.

Workflow:

User Voice Input  
→ Speech-to-Text  
→ Dialect Normalization  
→ Query Embedding  
→ Vector Search (FAISS)  
→ BM25 Retrieval  
→ CrossEncoder Reranking  
→ LLM Response Generation  
→ Text-to-Speech Output

This ensures responses are grounded in verified government scheme data.

---

# API

## POST /chat

Processes user queries and returns both text and voice responses.

Example request:

```bash
curl -X POST http://localhost:8000/chat \
  -H "Content-Type: application/json" \
  -H "X-API-Key: your_api_key" \
  -d '{"message": "kisan ko loan chahiye", "session_id": "user-123"}'
```

Example response:

```json
{
  "request_id": "a1b2c3d4",
  "session_id": "user-123",
  "text": "Aapke liye PM-KISAN aur Kisan Credit Card...",
  "audio_base64": "<base64 MP3>",
  "schemes": [],
  "language_detected": "hi",
  "cached": false
}
```

---

## GET /health

Returns service health information.

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

# Production Features

| Feature | Description |
|------|------|
| API Authentication | X-API-Key header authentication |
| Rate Limiting | 30 requests per minute per IP |
| CORS Control | Allowed origins configured via environment variables |
| Structured Logging | JSON logs compatible with AWS CloudWatch |
| Request Tracking | Unique request ID generated for each request |
| Response Caching | LRU cache with TTL |
| Session Memory | Stores last 10 interactions per session |
| Timeout Handling | LLM and TTS timeout protection |
| Model Warmup | AI models initialized during startup |
| Graceful Shutdown | Cache cleared and logs flushed |

---

# Local Development

Install dependencies and run the backend server.

```bash
pip install -r requirements.txt
cp .env .env.local
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

---

# Production Deployment (AWS EC2)

Copy files to EC2.

```bash
scp -r ./sahaayak-backend-prod ubuntu@YOUR_EC2_IP:/opt/sahaayak
```

On EC2 run:

```bash
chmod +x /opt/sahaayak/deploy.sh
bash /opt/sahaayak/deploy.sh
```

---

# File Structure

```
sahaayak-backend-prod/
├── main.py
├── retriever.py
├── llm.py
├── tts.py
├── schemas.py
├── cache.py
├── logger.py
├── deploy.sh
├── requirements.txt
└── .env
    data/
    ├── faiss_bge_cosine.bin
    └── schemes_processed.parquet
```

---

# Generate API Key

```bash
python -c "import secrets; print(secrets.token_hex(32))"
```

Add the key in `.env`

```
SAHAAYAK_API_KEY=your_generated_key
```

---

Team Percepta | License: MIT
