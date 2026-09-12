# DOOMNOTES Part 21: Beautiful Source Links & Search

## Core Idea

Every note that came from a video or post must keep its **source URL** and display it as a **beautiful, tappable card**:

- Title: “Gwara Gwara Dance Tutorial”
- Subtitle: “Saved in: Dance”
- Button: “Watch video ▶️” → opens TikTok/YouTube/Instagram in the external browser/app.

Search for “gwara”, “quara”, “gwaragwara” → user sees that card and can instantly go back to the source.

## Files Added

1. `lib/models/source_link.dart`
2. `lib/services/source_link_service.dart`
3. `lib/widgets/source_link_card.dart`
4. `lib/screens/search_notes_screen.dart`
5. `lib/screens/note_detail_screen_update_snippet.txt`

## pubspec.yaml

Add:

```yaml
dependencies:
  url_launcher: ^6.3.0
```

Then run:

```bash
flutter pub get
```

## Behavior

- On share capture, if a URL is present, save it in `Note.videoUrl`.
- In Note Detail, show a **Source** section with `SourceLinkCard`.
- In Search, show a compact “Watch video” badge and the full `SourceLinkCard` under each result that has a URL.
- Tapping anywhere on the card opens the original link in the external app/browser.

## Example

Saved note:

- Topic: `Dance`
- Summary: “Gwara Gwara dance tutorial in 5 easy steps.”
- videoUrl: `https://www.tiktok.com/@user/video/12345`

Search “gwara” → card shows:

- “Gwara Gwara Dance Tutorial”
- “Saved in: Dance”
- “Watch video ▶️”

User taps → TikTok app opens directly to that tutorial.

## No AI Chat

This feature does not use AI chat or summaries beyond what already exists. It only makes the **existing source URL** beautiful and instantly accessible.