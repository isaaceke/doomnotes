# DOOMNOTES Part 18: Voice Notes Specification

## New Capabilities

1. Users can record voice notes directly in DoomNotes.
2. Live transcription shows text as they speak (on-device speech-to-text).
3. After stopping, they can:
   - Review the transcript
   - Optionally assign a topic (or accept auto-suggestion)
   - Save as a normal note
4. Voice notes are stored like any other note:
   - `source: "voice_note"`
   - Full transcript text
   - Optional AI summary (using on-device summarization from Part 17)

## Integration Points

- Uses the same **Batch Capture** service for classification and saving.
- Respects the user’s **manual vs automatic topic mode** setting.
- Can be extended later to:
  - Attach the original audio file to the note (for playback).
  - Allow re-transcription with a different model.
  - Summarize long voice notes using the on-device AI summary service.

## Privacy & Performance

- Speech recognition runs on-device via platform APIs:
  - iOS: Speech framework / SFSpeechRecognizer
  - Android: SpeechRecognizer / Android Speech API
- No audio is uploaded unless the user explicitly enables cloud transcription later.
- Transcripts are stored locally in Isar like all other notes.

## Next Steps

- Add optional audio attachment and playback in note detail.
- Add multi-language speech recognition.
- Add speaker diarization (multiple speakers) if needed later.