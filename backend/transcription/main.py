# DOOMNOTES - Whisper.cpp Transcription Backend API
# Purpose: Self-hosted server for video transcription (free, unlimited)
# Tech: FastAPI + Whisper.cpp + yt-dlp
# Cost: \$0 (runs on your own hardware or free cloud tier)

from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import subprocess
import os
import tempfile
import shutil
from pathlib import Path

# Initialize FastAPI app
app = FastAPI(
    title="DoomNotes Transcription API",
    description="Self-hosted Whisper.cpp transcription service",
    version="1.0.0"
)

# Enable CORS for Flutter app
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Restrict in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Configuration
WHISPER_CPP_PATH = "./whisper.cpp/main"  # Path to whisper.cpp binary
WHISPER_MODEL = "./models/ggml-large-v3-turbo.bin"  # Model file
TEMP_DIR = Path(tempfile.gettempdir()) / "doomnotes"

# Ensure temp directory exists
TEMP_DIR.mkdir(exist_ok=True)

class TranscribeURLRequest(BaseModel):
    url: str

@app.post("/transcribe")
async def transcribe_from_url(request: TranscribeURLRequest):
    """
    Download audio from video URL and transcribe it.
    Used by Flutter app when user shares Instagram video.
    """
    try:
        # Step 1: Download audio from URL using yt-dlp
        audio_file = await download_audio(request.url)
        
        # Step 2: Transcribe audio with Whisper.cpp
        transcript = await transcribe_audio(audio_file)
        
        # Step 3: Clean up
        os.remove(audio_file)
        
        return {"transcript": transcript, "status": "success"}
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/transcribe-file")
async def transcribe_from_file(file: UploadFile = File(...)):
    """
    Transcribe uploaded audio file.
    Alternative endpoint for direct file upload.
    """
    try:
        # Save uploaded file
        temp_file = TEMP_DIR / file.filename
        with open(temp_file, "wb") as f:
            f.write(await file.read())
        
        # Transcribe
        transcript = await transcribe_audio(str(temp_file))
        
        # Clean up
        os.remove(temp_file)
        
        return {"transcript": transcript, "status": "success"}
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/health")
async def health_check():
    """Health check endpoint for monitoring."""
    return {"status": "healthy", "model": WHISPER_MODEL}

async def download_audio(video_url: str) -> str:
    """
    Download audio track from video URL using yt-dlp.
    Returns path to downloaded WAV file.
    """
    output_path = TEMP_DIR / f"audio_{os.urandom(8).hex()}.wav"
    
    try:
        # Run yt-dlp to extract audio
        subprocess.run(
            [
                "yt-dlp",
                "-x",  # Extract audio
                "--audio-format", "wav",  # Convert to WAV
                "-o", str(output_path),  # Output path
                video_url,  # Video URL
            ],
            check=True,
            capture_output=True,
            timeout=120  # 2 minute timeout
        )
        
        if not output_path.exists():
            raise Exception("yt-dlp failed to download audio")
        
        return str(output_path)
    
    except subprocess.TimeoutExpired:
        raise Exception("Download timeout - video may be too long or unavailable")
    except Exception as e:
        raise Exception(f"Download failed: {str(e)}")

async def transcribe_audio(audio_path: str) -> str:
    """
    Transcribe audio file using Whisper.cpp.
    Returns plain text transcript.
    """
    try:
        # Run whisper.cpp
        result = subprocess.run(
            [
                WHISPER_CPP_PATH,
                "-m", WHISPER_MODEL,  # Model file
                "-f", audio_path,  # Audio file
                "-otxt",  # Output as text
                "--no-timestamps",  # No timestamps in output
            ],
            capture_output=True,
            text=True,
            timeout=300  # 5 minute timeout for long audio
        )
        
        if result.returncode != 0:
            raise Exception(f"Whisper.cpp error: {result.stderr}")
        
        # Read transcript from output file
        transcript_path = audio_path + ".txt"
        with open(transcript_path, "r", encoding="utf-8") as f:
            transcript = f.read().strip()
        
        # Clean up transcript file
        os.remove(transcript_path)
        
        return transcript
    
    except subprocess.TimeoutExpired:
        raise Exception("Transcription timeout - audio may be too long")
    except Exception as e:
        raise Exception(f"Transcription failed: {str(e)}")

if __name__ == "__main__":
    import uvicorn
    # Run on all interfaces, port 8000
    uvicorn.run(app, host="0.0.0.0", port=8000)