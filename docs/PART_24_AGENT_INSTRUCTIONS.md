# DOOMNOTES Part 24: Agent Instructions

## Wire Onboarding

1. Add `shared_preferences` to `pubspec.yaml`.
2. Create `AppPrefsService`.
3. In `main.dart`, check `hasSeenOnboarding` and route to:
   - `OnboardingScreen` (first run)
   - `HomeScreen` (returning user)

## Use Canonical Empty State

Use:

```text
lib/widgets/empty_notes_state.dart
```

For:

- Home screen when library is empty
- Topic folders with zero notes
- Search with no results (adjust subtitle)

Do not create multiple competing empty-state widgets.

## Keep Copy Short and Real

- Do not invent user counts, download numbers, or testimonials.
- Do not promise features that do not exist (AI chat, cloud sync, etc.).
- Focus on: share → save with source → search → open original.

## Test Flow

- Fresh install → onboarding shows → “Get Started” → Home
- Reopen app → onboarding skipped → Home directly
- Empty library → empty state with “Learn how sharing works”
- Share a TikTok/YouTube/Instagram item → appears in Home and topic
- Search with variations (“gwara”, “qwara”, “quara”) → finds same note
- Tap “Watch video” → opens original link

## Do Not Break

- Existing topic classification
- Smart search
- Source link cards
- Capture success sheet
- Clean Note (optional)
- No AI chat