# DoomNotes

Save links from TikTok, YouTube, Instagram, or anywhere else — automatically
filed by topic, with one tap back to the original source.

**What this version actually does** (an earlier draft of this README
described video transcription, a Python/Whisper.cpp backend, and Supabase
sync — none of that is in the shipped app; see `STATUS_REPORT.md` for the
full history):

- Share a link into the app (or paste one manually) → it's saved with
  whatever caption text came with it
- Auto-filed into a topic folder by keyword matching (10 topic packs
  included — see `assets/topic_packs/`)
- Fuzzy/typo-tolerant search across your saved notes
- One tap opens the original post/video
- Export/import your library as a JSON file
- Everything works fully offline; nothing leaves your device unless you
  export it or (optionally, later) enable cloud sync

## Setup

**Read `STATUS_REPORT.md` first** — it explains what's been fixed, what
still needs manual setup (Xcode, a hosted privacy policy), and why.

```bash
flutter create . --org com.doomnotes --project-name doomnotes
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run
```

For sharing from other apps to actually work:
- **Android:** already configured in `AndroidManifest.xml`.
- **iOS:** needs a one-time Xcode setup — see
  `docs/IOS_SHARE_EXTENSION_SETUP.md`.

## Optional: Cloud Sync

Not required to ship. See `docs/ENABLE_CLOUD_SYNC.md` if/when you want
accounts and multi-device sync (Firebase).

## Tech Stack

- Flutter (Dart)
- Isar — local, on-device database
- `receive_sharing_intent` — share-sheet integration
- Firebase (accounts + sync — wired in behind an off-by-default Settings toggle; see `docs/ENABLE_CLOUD_SYNC.md`)

## Before you submit to the App Store / Play Store

1. Host `docs/PRIVACY_POLICY.md` and `docs/TERMS_OF_SERVICE.md` somewhere
   real (GitHub Pages works fine) and update the links in
   `lib/screens/settings_screen.dart`.
2. Fill in the placeholders in those two docs (contact email, jurisdiction).
3. Run through `docs/ios_submission_checklist.md` /
   `docs/android_submission_checklist.md` — note these were also written
   for the old Whisper/Supabase design, so skip anything that references
   transcription, backend servers, or Supabase.

## License

MIT — see `LICENSE`.
