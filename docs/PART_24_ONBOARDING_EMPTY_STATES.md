# DOOMNOTES Part 24: Onboarding + Empty States

## Goal

Teach the product in under 30 seconds:

1. Share from TikTok/YouTube/Instagram
2. Saved with source link
3. Search finds it even with typos
4. One tap opens the original

No AI chat. Fully offline.

## Files Added

1. `lib/services/app_prefs_service.dart`
2. `lib/widgets/onboarding_slide.dart`
3. `lib/screens/onboarding_screen.dart`
4. `lib/widgets/empty_notes_state.dart`
5. `lib/screens/home_screen_empty_example.dart`

## pubspec.yaml

Add:

```yaml
dependencies:
  shared_preferences: ^2.5.5
```

Then:

```bash
flutter pub get
```

## Routing Logic

In `main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final appPrefs = AppPrefsService(prefs);

  runApp(
    DoomNotesApp(
      hasSeenOnboarding: appPrefs.hasSeenOnboarding,
    ),
  );
}

class DoomNotesApp extends StatelessWidget {
  final bool hasSeenOnboarding;
  const DoomNotesApp({super.key, required this.hasSeenOnboarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: DoomNotesTheme.lightTheme(),
      home: hasSeenOnboarding
          ? const HomeScreen()
          : const OnboardingScreen(),
    );
  }
}
```

## Empty States

Use `EmptyNotesState` when:

- The library is empty
- A topic folder has no notes yet
- Search returns no results (with a different subtitle)

Example subtitle for search:

```text
No notes found for “gwara”.
Try a broader term or share more content to build your library.
```

## Do Not Add

- AI chat or AI summaries in onboarding
- Network calls or remote content
- Fake examples or placeholder stats
- Complex multi-step tutorials

Keep it short, visual, and focused on the core loop.