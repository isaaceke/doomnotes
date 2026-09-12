# DOOMNOTES Part 27: Main Wiring + Export/Import

## What This Part Does

- Initializes Isar, preferences, topic packs, and share handling in `main.dart`.
- Adds a `ShareCaptureService` that:
  - Listens for shares when the app is already open.
  - Handles shares that launch the app.
  - Saves notes with `videoUrl` and topic classification.
- Adds `ExportImportService` + `ExportImportScreen`:
  - Export all notes to JSON.
  - Import notes from JSON.
  - Share the backup file.

## Dependencies

In `pubspec.yaml`, ensure you have:

```yaml
dependencies:
  isar: ^3.1.0+1
  isar_flutter_libs: ^3.1.0+1
  path_provider: ^2.1.0
  receive_sharing_intent: ^1.5.0
  share_plus: ^9.0.0
  url_launcher: ^6.3.2
  shared_preferences: ^2.5.5
  package_info_plus: ^9.0.0
  file_picker: ^8.0.0
  uuid: ^4.0.0
```

Then run:

```bash
flutter pub get
flutter pub run build_runner build
```

## iOS Share Extension

`receive_sharing_intent` requires a Share Extension target in Xcode:

1. Open `ios/Runner.xcworkspace` in Xcode.
2. File → New → Target → Share Extension.
3. Name it `ShareExtension`.
4. Ensure deployment target matches Runner.
5. In `ShareViewController.swift`, forward the shared text/URL to the app using the plugin's instructions.
6. Test by sharing from TikTok/YouTube/Instagram → DoomNotes.

For Android, the plugin adds intent filters automatically.

## Wire Export/Import in Settings

In `SettingsScreen`, add:

```dart
SettingsTile(
  icon: Icons.backup_rounded,
  title: 'Export / Import',
  subtitle: 'Back up or restore your library',
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const ExportImportScreen()),
  ),
),
```

## Test Checklist

Run these tests on a real device:

1. **First run**
   - Fresh install → onboarding appears.
   - Complete onboarding → Home appears.
   - Reopen app → onboarding skipped.

2. **Share capture**
   - From TikTok: share a dance tutorial → DoomNotes.
   - Verify:
     - Note saved with topic "Dance" (or suggested).
     - `videoUrl` populated.
     - Capture success would show (you can add a dialog later).
   - Repeat for YouTube and Instagram.

3. **Search**
   - Search "gwara", "qwara", "quara", "gwaragwara".
   - Verify same dance note appears with "Watch video" card.
   - Tap card → TikTok/YouTube/Instagram opens.

4. **Topic mode**
   - Settings → toggle automatic topic mode.
   - Share a new item → verify behavior changes accordingly.

5. **Export**
   - Settings → Export/Import → Export all notes.
   - Share the JSON file to yourself (email, Drive, etc.).

6. **Import**
   - On same or another device: Import the JSON.
   - Verify notes appear with correct topics and source links.

7. **Edge cases**
   - Share text only (no URL) → saved with empty `videoUrl`.
   - Share image only → handled as text path or ignored depending on your policy.
   - Very long transcripts → app remains responsive.

## Do Not Add

- AI chat
- Cloud sync
- Scraping social platforms
- Fake video title fetching

Keep DoomNotes local-first, source-first, and honest.