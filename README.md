# Sahaayak AI

Sahaayak is a voice-first AI assistant designed to help people access government schemes and public services more easily, especially in rural and underserved communities across India.

The platform allows users to interact naturally using their native language or dialect and receive intelligent guidance powered by AI, speech recognition, and retrieval-based search systems.

Built by Team Percepta for the AWS AI for Bharat Hackathon.

---

# Features

## Voice-First Interaction

Users can speak naturally instead of typing.

- Native language support
- Real-time speech processing
- Conversational assistance
- Easy to use for non-technical users

---

## Dialect Normalization

The system can understand regional dialects and normalize them into structured queries for accurate processing.

Capabilities include:
- Multi-dialect recognition
- Accent handling
- Intent extraction
- Language normalization

---

## AI-Based Scheme Recommendations

Sahaayak analyzes user requirements and recommends relevant government schemes.

Recommendations can be based on:
- Farming needs
- Employment
- Education
- Financial assistance
- Life events

---

## Guided Assistance

The assistant provides step-by-step help for understanding and applying to schemes.

Includes:
- Eligibility guidance
- Required document information
- Application instructions
- Conversational support

---

## Low Bandwidth Optimization

Designed to work efficiently in rural and low-connectivity environments.

- Lightweight responses
- Optimized voice processing
- Minimal data usage
- Caching support

---

# System Architecture

```text
User Voice Input
        ↓
Speech-to-Text (Whisper)
        ↓
Dialect Normalization
        ↓
Query Embedding
        ↓
FAISS + BM25 Retrieval
        ↓
CrossEncoder Reranking
        ↓
Groq LLM Response
        ↓
Text-to-Speech Output
