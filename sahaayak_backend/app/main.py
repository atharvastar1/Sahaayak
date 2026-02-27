from fastapi import FastAPI, UploadFile, File, Form
from pydantic import BaseModel
from typing import List, Optional
import os
from app.processor import SahaayakProcessor

from fastapi.staticfiles import StaticFiles

app = FastAPI(title="Sahaayak Backend API")

# Ensure static directory exists and mount it
os.makedirs("static/audio", exist_ok=True)
app.mount("/static", StaticFiles(directory="static"), name="static")

# Initialize processor
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
CSV_PATH = os.path.join(BASE_DIR, "../data/schemes.csv")
processor = SahaayakProcessor(CSV_PATH)

class SchemeMatchRequest(BaseModel):
    text: str
    language: Optional[str] = "en"

class AIResponse(BaseModel):
    request_id: str
    detected_dialect: str
    normalized_text: str
    ai_message: str
    suggested_schemes: List[dict]

@app.get("/")
def read_root():
    return {"message": "Welcome to Sahaayak API"}

import whisper
import shutil

# Load whisper model globally
whisper_model = whisper.load_model("tiny")

@app.post("/stt")
async def speech_to_text(audio: UploadFile = File(...)):
    """
    STT Route: OpenAI Whisper converts dialect into text and detects language.
    """
    temp_dir = "temp_audio"
    os.makedirs(temp_dir, exist_ok=True)
    file_path = os.path.join(temp_dir, audio.filename)
    
    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(audio.file, buffer)
    
    try:
        # Run Whisper inference
        result = whisper_model.transcribe(file_path)
        transcript = result.get("text", "").strip()
        detected_lang = result.get("language", "en")
        
        print(f"STT PROCESSED: [{detected_lang}] {transcript}")
        
        return {
            "text": transcript,
            "language": detected_lang,
            "status": "success"
        }
    except Exception as e:
        print(f"STT ERROR: {e}")
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        # Secure cleanup
        if os.path.exists(file_path):
            os.remove(file_path)

@app.post("/process", response_model=AIResponse)
async def process_request(request: SchemeMatchRequest):
    """
    Main Pipeline: Dialect Normalization -> Intelligence & Matching.
    """
    # 1. Dialect Normalization
    norm_data = processor.normalize_dialect(request.text)
    
    # 2. Matching
    schemes = processor.match_schemes(request.text)
    
    # 3. AI Message Generation
    ai_msg = processor.generate_ai_response(schemes, norm_data['dialect'])
    
    return AIResponse(
        request_id=f"REQ-{os.urandom(4).hex()}",
        detected_dialect=norm_data['dialect'],
        normalized_text=norm_data['normalized_text'],
        ai_message=ai_msg,
        suggested_schemes=schemes
    )

from TTS.api import TTS
import time

# Load TTS model once
# Using a multi-speaker model for regional support
try:
    tts_engine = TTS(model_name="tts_models/multilingual/multi-dataset/xtts_v2", gpu=False)
except Exception as e:
    print(f"TTS Load Warning: {e}. Falling back to default.")
    tts_engine = None

@app.post("/tts")
async def text_to_speech(text: str = Form(...), lang: str = Form("en")):
    """
    TTS Route: Coqui TTS converts result back to speech with regional nuances.
    """
    if not tts_engine:
        return {"audio_url": "https://example.com/mock_audio.mp3", "status": "mocked"}

    try:
        output_dir = "static/audio"
        os.makedirs(output_dir, exist_ok=True)
        filename = f"speech_{int(time.time())}.wav"
        save_path = os.path.join(output_dir, filename)

        # Map internal lang codes to XTTS expected codes
        xtts_lang = "en"
        if lang == "hi": xtts_lang = "hi"
        elif lang == "mr": xtts_lang = "hi" # Fallback to Hindi for Marathi if specific model lacks it
        
        tts_engine.tts_to_file(
            text=text,
            file_path=save_path,
            speaker_wav="app/speaker_sample.wav", # Needs a reference voice file
            language=xtts_lang
        )
        
        # In a real setup, this would be a public URL served by FastAPI static mount
        return {"audio_url": f"http://10.0.2.2:8000/static/audio/{filename}", "status": "success"}
    except Exception as e:
        return {"error": str(e), "status": "failed"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
