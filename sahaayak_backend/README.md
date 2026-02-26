# Sahaayak Backend

This is the FastAPI backend for the Sahaayak app, implementing the Technical Pipeline:
1. Speech-to-Text (STT) via Whisper.
2. Dialect Normalization.
3. Intelligence & Matching against Government Schemes.
4. Voice Output (TTS) via Coqui.

## Setup

1. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

2. Run the server:
   ```bash
   python -m app.main
   ```

## API Endpoints

- `POST /stt`: Converts voice to text.
- `POST /process`: Normalizes dialect and matches schemes.
- `POST /tts`: Converts text response to speech.

## Key Features
- **Dialect Normalization**: Reduces hallucinations by mapping local dialects to a standardized layer.
- **Scheme Matching**: Uses a CSV-based matching engine (expandable to PostgreSQL RDS).
