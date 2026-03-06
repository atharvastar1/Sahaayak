# Sahaayak Backend - AI-Powered Government Scheme Discovery

Sahaayak is a specialized backend service designed to bridge the gap between citizens and government welfare programs. By leveraging advanced Natural Language Processing (NLP) and semantic search, it helps users discover relevant schemes regardless of regional dialect or linguistic nuances.

## Overview

The Sahaayak backend provides a robust AI pipeline that processes voice and text inputs, normalizes regional dialects, and matches them against a curated database of government schemes. It is built to be resilient, scalable, and empathetic to the needs of diverse user groups.

## Features

- Speech-to-Text (STT) Processing: High-accuracy transcription using OpenAI Whisper.
- Dialect Normalization: Specialized mapping layer to resolve regional linguistic variations into standardized context.
- Semantic Matching Engine: Intelligent retrieval system that identifies relevant schemes based on user needs.
- Text-to-Speech (TTS) Synthesis: Multi-speaker voice output using Coqui TTS for a natural, regional-friendly experience.
- Efficient Data Handling: Utilizes optimized Parquet and FAISS indexing for fast retrieval.

## Technical Pipeline

1. Input: User provides voice or text input in a regional dialect.
2. STT: Whisper converts audio to text and detects the source language.
3. Normalization: The processor identifies dialect-specific keywords and maps them to a standard semantic layer.
4. Intelligence: The match engine queries the scheme database using the normalized context.
5. Output: A personalized AI response is generated and optionally converted back to speech.

## Tech Stack

- Framework: FastAPI (Python)
- Machine Learning Models: OpenAI Whisper (STT), Coqui TTS (TTS)
- Data Processing: Pandas, Apache Parquet
- Search Infrastructure: FAISS (Vector Search ready)
- Database: CSV/Parquet (Expandable to PostgreSQL RDS)

## Installation

Clone the repository:
```bash
git clone https://github.com/atharvastar1/Sahaayak.git
cd sahaayak_backend
```

Install the required dependencies:
```bash
pip install -r requirements.txt
```

## Running the Server

Start the FastAPI application using Uvicorn:
```bash
python -m app.main
```
The API will be available at `http://localhost:8000`.

## API Documentation

### STT Endpoint
- URL: `/stt`
- Method: `POST`
- Input: `audio` (UploadFile)
- Description: Converts audio file to transcribed text.

### Process Endpoint
- URL: `/process`
- Method: `POST`
- Input: `SchemeMatchRequest` (JSON)
- Description: Performs dialect normalization and returns matched schemes with an AI-generated message.

### TTS Endpoint
- URL: `/tts`
- Method: `POST`
- Input: `text` (Form), `lang` (Form)
- Description: Synthesizes text into a WAV audio file.

## Project Structure

```text
sahaayak_backend/
├── app/                # Core application logic
│   ├── main.py         # FastAPI routes and server config
│   └── processor.py    # Dialect normalization and matching logic
├── data/               # Scheme datasets and vector indices
├── static/             # Generated assets (audio files)
├── requirements.txt    # Python dependencies
└── README.md           # Documentation
```

## Authors

- Prem Mali - AI/ML Developer

## License

This project is licensed under the MIT License.
