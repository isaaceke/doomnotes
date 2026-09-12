# DOOMNOTES Part 27: Agent Implementation Checklist

## Before Running

- [ ] Add all dependencies to `pubspec.yaml`.
- [ ] Run `flutter pub get`.
- [ ] Run `flutter pub run build_runner build` to generate Isar code.
- [ ] Ensure `Note` model is annotated for Isar and includes `videoUrl`.

## iOS Setup

- [ ] Create Share Extension target in Xcode.
- [ ] Configure `receive_sharing_intent` according to its docs.
- [ ] Test share from TikTok, YouTube, Instagram to DoomNotes.

## Android Setup

- [ ] Verify intent filters are present in `AndroidManifest.xml`.
- [ ] Test share from TikTok, YouTube, Instagram to DoomNotes.

## Main Wiring

- [ ] `main.dart` initializes:
  - Isar
  - SharedPreferences
  - Topic packs
  - ShareCaptureService
- [ ] Onboarding routing works (first run vs returning).

## Capture Flow

- [ ] Shared text/URL → `ShareCaptureService` → `Note` saved.
- [ ] Topic classification uses `TopicKeywordDatabaseService`.
- [ ] `videoUrl` stored when present.

## Export/Import

- [ ] Export creates JSON in Documents directory.
- [ ] Import reads JSON and inserts notes.
- [ ] Settings links to `ExportImportScreen`.

## Search

- [ ] `SmartSearchScreen` used as main search.
- [ ] "gwara/qwara/quara" find the same note.
- [ ] Source link cards open external apps.

## Final Checks

- [ ] No AI chat features.
- [ ] No cloud sync promises.
- [ ] Privacy/terms URLs real (not YOUR_WEBSITE.com).
- [ ] No fake stats or testimonials.

Once all boxes are checked, you are ready for beta testing and store submission prep.