# DOOMNOTES Part 15: Image OCR Specification

## New Capabilities

1. Users can take a photo or pick an image from gallery.
2. DoomNotes extracts all visible text using on-device ML Kit.
3. Extracted text is shown for review before saving.
4. Users can:
   - Accept auto-suggested topic
   - Choose a different topic
   - Create a new topic
5. Saved as a normal note with `source: image_ocr`.
6. Works with:
   - Screenshots of tweets, threads, articles
   - Infographics and diagrams
   - Memes with text
   - Slides and lecture photos
   - Whiteboard photos

## Data Model Changes

`CaptureItem` gains:
- `imageOcrText` — the raw OCR result.
- `type: CaptureContentType.image`

Batch Capture treats image items as:
- If `imageOcrText` is present, use it as the transcript.
- Classify using keywords from OCR text.
- Save like any other note.

## Privacy & Performance

- OCR runs fully on-device via Google ML Kit.
- No images are uploaded unless the user explicitly enables cloud OCR later.
- Large images are scaled down before recognition to save memory.
- Users can delete the note (and underlying image reference) at any time.

## Next Steps

- Add desktop OCR using Tesseract for Windows/Mac/Linux.
- Add multi-image batch OCR (select multiple images → one note per image).
- Add optional cloud OCR for higher accuracy languages.
- Add “OCR from clipboard” on desktop (paste screenshot → auto OCR).