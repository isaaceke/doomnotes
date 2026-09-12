# DOOMNOTES Part 25: Settings & About

## Goal

Provide a minimal, honest settings area:

- Capture: automatic vs always-ask topic mode
- Data: export/import stubs (coming soon)
- Legal: privacy policy, terms of service
- About: version, build number, simple description, share app
- Help: “How to share” step-by-step screen

No AI chat. No network required except opening policy/terms URLs.

## Files Added

1. `lib/services/version_service.dart`
2. `lib/widgets/settings_section.dart`
3. `lib/screens/settings_screen.dart`
4. `lib/screens/how_to_share_screen.dart`

## pubspec.yaml

Add:

```yaml
dependencies:
  package_info_plus: ^9.0.0
  share_plus: ^9.0.0
  url_launcher: ^6.3.2
```

Then:

```bash
flutter pub get
```

## Initialization

In `main.dart`, after creating `AppPrefsService`:

```dart
final prefs = await SharedPreferences.getInstance();
final appPrefs = AppPrefsService(prefs);
AppPrefsServiceSingleton.init(appPrefs);
```

This allows `SettingsScreen` to access preferences without a global.

## Legal URLs

Replace placeholders:

```text
[https://YOUR_WEBSITE.com/privacy](https://YOUR_WEBSITE.com/privacy)
[https://YOUR_WEBSITE.com/terms](https://YOUR_WEBSITE.com/terms)
```

with real URLs before submitting to app stores.

## Do Not Add

- AI chat or AI summaries
- Cloud sync promises
- Fake export/import functionality
- Complex settings categories

Keep it short, honest, and focused on the core loop.