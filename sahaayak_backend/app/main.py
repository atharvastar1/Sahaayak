from fastapi import FastAPI, UploadFile, File, Form
from pydantic import BaseModel
from typing import List, Optional
import os
from app.processor import SahaayakProcessor

app = FastAPI(title="Sahaayak Backend API")

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

@app.post("/stt")
async def speech_to_text(audio: UploadFile = File(...)):
    """
    STT Route: OpenAI Whisper converts dialect into text.
    (Mocked for now since Whisper needs GPU/Heavy installation)
    """
    return {"text": "किसान के लिए क्या है?", "status": "success"}

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

@app.post("/tts")
async def text_to_speech(text: str = Form(...)):
    """
    TTS Route: Coqui TTS converts result back to speech.
    (Mocked for now returns a dummy URL)
    """
    return {"audio_url": "https://example.com/audio.mp3", "status": "success"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
