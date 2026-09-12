# DOOMNOTES Part 22: Original Source-First Design System

## Design Promise

DoomNotes is not a clone of a note-taking, bookmarking, social-media, or music app.

It uses familiar usability patterns but has its own product identity:

> Save what matters. Find it later. Return to the original source instantly.

## Influence vs Copying

It is acceptable to study:
- Readwise Reader: source-aware capture, highlights, tagging, inbox flow
- Instapaper: quick save and focused read-later flow
- Notion: structured organization and search
- Pinterest: saved collections and discovery
- Spotify: strong action hierarchy for playable content

It is not acceptable to copy:
- Source code
- Screen layouts pixel-for-pixel
- Logos, icons, illustrations, screenshots, animations, copywriting, or typography
- Brand colors and navigation structures
- Names such as “Reader”, “Pocket”, “Pins”, “Boards”, “Ghostreader”, or “Daily Review”

## DoomNotes Visual Language

- Canvas: soft off-white (#F7F7FA)
- Main ink: near-black (#14161F)
- Signature accent: violet (#6557E8)
- Successful save: mint (#17A78B)
- Corners: generous 12/18/24px radii
- Cards: white surface with subtle border, not heavy shadows
- Primary source action: black, full-width button
- Topic labels: violet uppercase micro-label
- Platform identity: small pill; no social platform logo assets are required

## Signature Saved Item

A saved item should always surface:

1. Topic folder
2. Human-readable title
3. Short clean preview
4. Original platform
5. One obvious action:
   - WATCH VIDEO
   - OPEN POST
   - OPEN SOURCE
6. Save time
7. Search-match chips when applicable

## Required Integration

1. Add `url_launcher` to `pubspec.yaml`.
2. Make `SourceFirstNoteCard` the default card in:
   - Search results
   - Topic folder list
   - Home recent items
3. Make `CaptureSuccessSheet` appear after a successful capture.
4. Keep `SourceActionButton` external-app based; do not scrape or re-host social video.
5. Preserve the raw source URL on every captured note.