# DOOMNOTES Part 23: Agent Instructions

## Replace Old Search

Deprecate `SearchNotesScreen` in favor of:

```text
lib/screens/smart_search_screen.dart
```

Wire this screen into your main navigation (e.g. AppBar search icon).

## Use Canonical Widgets

Use:

- `SourceFirstNoteCard` for every result
- `SearchMatchChip` for match reasons
- `SmartSearchService` for all queries

Do not create alternate search services such as:
- `ai_search_service.dart`
- `vector_search_service.dart`
- `rag_search_service.dart`

## Expand Aliases Over Time

Add new aliases in `search_alias_database_service.dart` as you see real user queries:

```dart
const SearchAlias(
  canonical: 'gwara gwara',
  variants: ['gwara', 'qwara', 'quara', 'gwaragwara', 'gwara-gwara'],
),
```

Keep the list small and high-value.

## Performance

- The service runs entirely on-device.
- For very large libraries (>5,000 notes), consider:
  - Caching normalized text on each note
  - Running search in an isolate
  - Limiting results to 50–100 items

## Do Not Break

- Existing topic classification
- Source link cards
- Capture success sheet
- Clean Note (optional)
- No AI chat