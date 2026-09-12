# DOOMNOTES Part 22: Integration Instructions

## Add Dependency

In `pubspec.yaml`:

```yaml
dependencies:
  url_launcher: ^6.3.2
```

Then run:

```bash
flutter pub get
```

## Apply Theme

In `main.dart`:

```dart
import 'theme/doomnotes_theme.dart';

MaterialApp(
  theme: DoomNotesTheme.lightTheme(),
  home: const HomeScreen(),
);
```

## Replace Old Cards

Do not keep multiple competing note-card widgets.

Use this canonical card:

```text
lib/widgets/source_first_note_card.dart
```

Map each `Note` to:

```dart
SourceFirstNoteCard(
  topic: note.topic,
  title: note.displayTitle,
  preview: note.cleanedText ?? note.summary ?? note.transcript,
  sourceUrl: note.videoUrl,
  createdAt: note.createdAt,
  matchedTerms: matchedTerms,
  onOpenNote: () => openNote(note),
)
```

If `displayTitle` or `cleanedText` do not exist yet, use a small helper:
- Title: first meaningful line of cleaned text/transcript, maximum 72 characters
- Preview: next useful sentence or first 180 characters
- Never invent a title

## Capture Success

After a note is saved:

```dart
await CaptureSuccessSheet.show(
  context,
  topic: finalTopic,
  title: note.displayTitle,
  sourceUrl: note.videoUrl,
);
```

The system notification remains useful when the app is closed:

```text
Saved to Dance
Gwara Gwara Dance Tutorial
```

## Do Not Add

- AI chat
- “Ask your notes”
- RAG
- Source scraping
- Fake video title fetching
- A proprietary web-view player
- Direct clones of other apps