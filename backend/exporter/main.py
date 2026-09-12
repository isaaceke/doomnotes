# DOOMNOTES - Saved Posts Exporter Backend (Optional Desktop Helper)
# Purpose: Help users export X bookmarks, Instagram saved, YouTube Watch Later when browser extension is not enough.
# Tech: FastAPI + Selenium (headless) + JSON export compatible with DoomNotes Batch Capture.

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import json
from pathlib import Path
import datetime

app = FastAPI(title="DoomNotes Saved Posts Exporter")

class ExportRequest(BaseModel):
    platform: str  # "x", "instagram", "youtube"
    auth_token: str | None = None
    max_items: int = 2000

@app.post("/export")
async def export_saved(req: ExportRequest):
    if req.platform == "x":
        data = export_x_bookmarks(req.auth_token, req.max_items)
    elif req.platform == "instagram":
        data = export_instagram_saved(req.auth_token, req.max_items)
    elif req.platform == "youtube":
        data = export_youtube_watch_later(req.max_items)
    else:
        raise HTTPException(status_code=400, detail="Unsupported platform")

    filename = f"{req.platform}-saved-{datetime.datetime.now().strftime('%Y%m%d-%H%M%S')}.json"
    output_path = Path("exports") / filename
    output_path.parent.mkdir(exist_ok=True)

    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

    return {"file": str(output_path), "count": len(data)}

def export_x_bookmarks(auth_token: str | None, max_items: int):
    # Placeholder: integrate with X API v2 /users/me/bookmarks or Selenium scraping.
    # Returns list of items compatible with DoomNotes Batch Capture.
    return []

def export_instagram_saved(auth_token: str | None, max_items: int):
    # Placeholder: integrate with Instagram private API or Selenium scraping of saved page.
    return []

def export_youtube_watch_later(max_items: int):
    # Placeholder: parse https://www.youtube.com/feed/watch_later via Selenium.
    return []

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8001)