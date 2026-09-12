# DOOMNOTES Part 17: On-Device AI Summaries (Free, No API Bill)

## Core Idea

Make AI summaries a **free feature** by running summarization **on-device** instead of paying for cloud LLM APIs.

## Why This Works in 2026

- **Apple**: iOS 26+ ships a ~3B on-device LLM via **Foundation Models / Core AI** that can do summarization, rewriting, and classification with **no per-call cost**. [222][224][231]
- **Android**: Google AI Core / ML Kit GenAI and on-device Gemma models enable local summarization without sending text to the cloud. [233]
- **Cross-platform Flutter**: Packages like `flutter_gemma` allow running small LLMs (2–3B) locally on mobile and desktop with GPU acceleration. [232]

This means:

- You can offer **free AI summaries** to all users.
- You avoid a recurring API bill that scales with usage.
- You keep everything private and offline by default.

## Architecture

### iOS

- Use **Foundation Models** (or Core AI on newer SDKs) to call the on-device 3B model.
- Prompt: “Summarize this transcript in 3–5 concise bullet points…”
- Output: 3–5 bullets shown in the note detail view.
- Cost: **\$0** per summary.

### Android

- Use **Google AI Core / ML Kit GenAI** or on-device Gemma.
- Same prompt pattern as iOS.
- Cost: **\$0** per summary.

### Desktop (Windows/Mac/Linux)

- Use a small local LLM (Gemma 2B/3B via `flutter_gemma` or llama.cpp).
- Optionally allow a cloud fallback for very old devices if the user explicitly enables it in settings.

## Implementation Notes

- The `AiSummaryService`:
  - Detects platform (iOS, Android, desktop).
  - Calls the appropriate on-device model.
  - Returns a `SummarizationResult` with bullets and metadata.
- The note detail screen:
  - Shows an “Generate AI Summary” button.
  - Calls `AiSummaryService.summarize(transcript)`.
  - Displays result in `AiSummaryCard`.
- No premium gate is required for summaries if you choose to make them free.

## Business Impact

- **Pros:**
  - Free summaries become a strong marketing point: “AI summaries, free forever, 100% on-device.”
  - No variable cost as usage grows.
  - Strong privacy story for marketing and App Store / Play Store.
- **Cons:**
  - Slightly lower quality than the biggest cloud LLMs (but improving fast in 2026).
  - Requires more work to integrate platform-specific on-device APIs.

## Recommendation

- Make **AI summaries free** using on-device models.
- Reserve **premium** for:
  - Cloud sync
  - Unlimited custom topics
  - Advanced search & filters
  - Integrations (Notion, Obsidian, etc.)
- Optionally offer a **cloud LLM upgrade** (higher-quality summaries) as a premium perk, but keep basic summaries free and local.

This aligns with 2026 trends where on-device AI is good enough for summarization and is a major differentiator for privacy-focused productivity apps. [222][224][232][233]