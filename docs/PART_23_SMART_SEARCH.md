# DOOMNOTES Part 23: Smart Search (Aliases + Normalization + Fuzzy)

## Goal

Make search forgiving:

- “gwara”, “qwara”, “quara”, “gwaragwara” → same dance tutorial
- “rsc”, “react server components”, “next.js rsc” → same frontend notes
- “ml”, “machine learning”, “neural network” → same AI/ML notes

All offline. No AI chat. No network.

## How It Works

1. Normalize input:
   - Lowercase
   - Remove punctuation and extra spaces
   - Strip basic diacritics
   - Fold confusables (q → g, 0 → o, 1 → i, 3 → e, 4 → a, 5 → s, 7 → t)

2. Expand query using aliases:
   - `gwara gwara` ↔ `gwara`, `qwara`, `quara`, `gwaragwara`, `gwara-gwara`
   - `react server components` ↔ `rsc`, `server components`, `react server`, `next.js rsc`
   - etc.

3. Tokenize and score notes:
   - Build a searchable string from topic, summary, transcript, URL, keywords
   - Count overlapping tokens
   - Bonus points for topic/keyword matches

4. Display results with match chips:
   - “Topic: Dance”
   - “Transcript”
   - “Summary”

## Files Added

1. `lib/services/search_normalizer_service.dart`
2. `lib/models/search_alias.dart`
3. `lib/services/search_alias_database_service.dart`
4. `lib/services/smart_search_service.dart`
5. `lib/widgets/search_match_chip.dart`
6. `lib/screens/smart_search_screen.dart`

## pubspec.yaml

No new dependencies. Uses only Isar and Flutter core.

## Test Cases

- Search “gwara” → Gwara Gwara dance tutorial appears
- Search “qwara” → same result
- Search “quara” → same result
- Search “gwaragwara” → same result
- Search “react server” → React Server Components notes appear
- Search “rsc” → same notes
- Search “ml tutorial” → machine learning notes appear

## Do Not Add

- AI chat
- Cloud search
- Server-side indexing
- Scraping social platforms
- Fake video titles