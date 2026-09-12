# DOOMNOTES Part 14: Desktop + Browser Extension for Exporting Saved Posts

## New Capabilities

1. Chrome extension that exports:
   - X/Twitter bookmarks
   - Instagram saved posts
   - YouTube Watch Later videos
2. Exports are JSON files compatible with DoomNotes Batch Capture (Part 13).
3. Optional Python backend for power users who want a desktop helper instead of an extension.
4. Users can back up their entire saved library and import it into DoomNotes in one batch.

## How Users Export Saved Posts

### X Bookmarks

1. Install Chrome extension.
2. Log in to X in Chrome.
3. Open `https://x.com/i/bookmarks`.
4. Click extension icon → “Export X Bookmarks”.
5. Save `x-bookmarks.json`.
6. In DoomNotes, open Batch Capture → Import JSON → select file.
7. Choose one topic for all or let auto classification route by content.

### Instagram Saved

1. Log in to Instagram in Chrome.
2. Open Saved page or a collection.
3. Click extension → “Export Instagram Saved”.
4. Save `instagram-saved.json`.
5. Import via Batch Capture in DoomNotes.

### YouTube Watch Later

1. Open `https://www.youtube.com/feed/watch_later`.
2. Click extension → “Export YouTube Watch Later”.
3. Save `youtube-watch-later.json`.
4. Import via Batch Capture.

## Data Format

All exports use the same structure expected by Batch Capture:

```json
[
  {
    "source": "x",
    "type": "postUrl",
    "url": "[https://x.com/i/status/1234567890](https://x.com/i/status/1234567890)",
    "title": "Optional short text",
    "capturedAt": "2026-09-08T12:00:00Z"
  }
]
```

Batch Capture treats:
- `videoUrl` → attempt transcription if supported.
- `postUrl` → save as a reference note with URL and title.
- `plainText` → save as text note.

## Privacy & Compliance

- The extension runs in the user’s browser and uses their logged-in session.
- No data is sent to third-party servers unless the user explicitly configures a backend.
- The extension must not claim affiliation with X, Instagram, or YouTube.
- Users must understand they are exporting their own saved content for personal use.

## Next Steps

- Implement real scraping/API calls in `background.js` and `backend/exporter/main.py`.
- Add tests with real accounts.
- Document rate limits and 800-bookmark API cap for X.
- Add a “Connect to DoomNotes” button that sends the exported JSON directly to a local DoomNotes desktop app via HTTP or file drop.