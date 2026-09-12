# DoomNotes — Status Report

You were right not to trust this codebase. Here's exactly what was wrong,
what I fixed, what I deliberately left alone, and what's still on you
(mostly because it needs Xcode, an Apple/Google developer account, or a
hosted website — none of which I have access to).

**Second round of work (feature build-out, Android-focused):** see
`FEATURE_CHECKLIST.md` for a full cross-check against the 100-item
feature list from the original planning chat, plus two more bugs
(including one I introduced myself and caught) documented at the bottom
of that file. This file covers the first round — getting the app to
actually compile and run at all.

## The honest headline: "publish tonight" isn't happening, for reasons that have nothing to do with code quality

Even with a perfect codebase, going live tonight isn't possible, because:
- **iOS** needs Xcode running on a Mac, an Apple Developer account
  ($99/year), and Apple's review (hours to a few days, sometimes faster
  with expedited review, never instant).
- **Android** needs a Google Play Console account ($25 one-time) and goes
  through at least some review too.
- Both stores require a **real, hosted privacy policy URL** — the one in
  this codebase was pointing at `https://YOUR_WEBSITE.com` (literally).
  I've rewritten the policy text, but I can't host it for you.

None of that is something more code fixes. What I *could* do — make the
actual app work — was the priority, covered below.

## The big one: the app did not compile at all

`main.dart` → `home_screen.dart` → imported **six files that were never
created anywhere in the 40k lines you were given**: `widgets/note_card.dart`,
`widgets/topic_folder.dart`, `widgets/search_bar.dart`,
`providers/app_provider.dart`, `providers/sync_provider.dart` — plus the
`provider` package, which wasn't even in `pubspec.yaml`. `note_detail_screen.dart`
(the other screen `main.dart` depends on) imported two more nonexistent
widgets and a service that wasn't in `pubspec.yaml` either.

In plain terms: the single most important screen in the app — the one
that shows your saved notes — was never actually built in any of the 29
parts. Everything downstream of it (`main.dart`, `onboarding_screen.dart`,
`smart_search_screen.dart`) failed to compile as a result. This wasn't a
typo — it's a whole screen that was scaffolded once in part 1's directory
listing and then never written.

**What I did:** rewrote `home_screen.dart` and `note_detail_screen.dart`
from scratch, using only widgets and services that actually exist elsewhere
in your codebase (`SourceFirstNoteCard`, `TopicFolderCard`,
`EmptyNotesState`, the Isar `Note` model, `TopicKeywordDatabaseService`,
etc.). Also added `topic_notes_screen.dart` (new — shows the notes inside
one topic folder), since nothing like it existed. The app now has a real,
working navigation graph: Onboarding → Home → (Topic → Note detail) /
Search / Settings → (Export/Import, How to share).

## Other real bugs, fixed

- **`Note.capturedAt` vs `Note.createdAt`:** the database model used
  `capturedAt`, but every one of the "final" services written in later
  parts (`share_capture_service.dart`, `cloud_sync_service.dart`,
  `export_import_service.dart`, `smart_search_screen.dart`) assumed a
  field called `createdAt`. This alone would have failed to compile.
  Renamed the model field to `createdAt` to match the newer code (the
  older orphaned files that used `capturedAt` are archived — see below).
- **Broken settings screen:** `settings_screen.dart` tried to read
  `AppPrefsService._sharedInstance!` — a private static field that didn't
  exist — via a nonsensical extension defined lower in the same file that
  declared a field and a getter with the same name (`_sharedInstance`
  twice). This could not have ever compiled. Rewired it to use the
  existing global `appPrefs` instance from `main.dart`.
- **Fake "coming soon" Export/Import:** a complete, working
  `ExportImportService` + `ExportImportScreen` existed (built in a later
  part) but `settings_screen.dart` still showed a placeholder dialog
  saying the feature was "coming soon" instead of opening it. Wired it up
  for real.
- **Wrong import path:** `ai_summary_service.dart` imported
  `summarization_result.dart` as if it were in the same folder; the file
  actually lives in `lib/models/`. Fixed.
- **Unregistered topic pack:** `assets/topic_packs/money_investing.json`
  was fully written (a later part) but never added to the hardcoded list
  in `topic_keyword_database_service.dart` that decides which packs to
  load — so it silently classified nothing, ever. Added it to the list.
- **Android sharing was wired to a dead end:** `AndroidManifest.xml`
  routed shared links to a custom `ShareReceiverActivity` with its own
  hand-rolled method channel — but the actual Dart code
  (`share_capture_service.dart`) uses the `receive_sharing_intent` plugin,
  which listens on `MainActivity`, not a separate activity. Nothing was
  connected to anything. Moved the intent filters onto `MainActivity`
  (matching the plugin's requirements) and archived the dead activity.
- **iOS share extension was a dead end too, differently:** the custom
  `ShareViewController.swift` manually wrote shared URLs to an App Group
  file and posted a Darwin notification that no Dart code ever listened
  for. Replaced it with a subclass of the plugin's own
  `RSIShareViewController`, which is what `receive_sharing_intent`
  actually expects. Also fixed `Info.plist`, which pointed
  `NSExtensionMainStoryboard` at a `MainInterface` storyboard file that
  was never created anywhere in the project (this alone would have failed
  to build in Xcode) — switched to `NSExtensionPrincipalClass` instead,
  which fits a storyboard-less extension.
- **Corrupted placeholder text throughout the codebase:** the generator
  used PowerShell "expandable" strings (`@" ... "@`) for content that
  needed literal `$` characters — Android Gradle placeholders
  (`${applicationName}`, `${applicationId}`) and Xcode's
  `$(PRODUCT_NAME)` — and tried to escape the `$` with a backslash, which
  isn't valid PowerShell escaping and just leaves a stray backslash in the
  output file. Fixed the two places this mattered functionally
  (`AndroidManifest.xml`, iOS `Info.plist`); it also shows up cosmetically
  as `\$99/year` in a bunch of the marketing docs under `docs/`, which I
  left alone since they don't affect the app.
- **Missing dependencies:** `uuid` (used by `share_capture_service.dart`)
  was never added to `pubspec.yaml`, even though the project's own
  `docs/PART_27_MAIN_WIRING.md` says it's required. Added it.
- **Unjustified Android permissions:** the manifest requested
  `RECEIVE_BOOT_COMPLETED`, `FOREGROUND_SERVICE`, `POST_NOTIFICATIONS`, and
  `VIBRATE` for a background transcription/notification system that
  doesn't exist in the shipped app. Removed them — unused sensitive
  permissions (especially boot-completed) invite extra Play Store
  scrutiny for no benefit.
- **Privacy Policy and Terms of Service described a different app:** they
  talked about downloading and transcribing videos, a Supabase backend,
  encrypted local storage, analytics collection, and notifications — none
  of which the shipped app does. Publishing these as-is would have been
  actively misleading (and a real compliance problem, not just an
  inaccuracy). Rewrote both to match what the app actually does. **You
  still need to fill in a real contact email and jurisdiction, and host
  them somewhere** (see "Still required" below).
- **README described an entirely different, abandoned architecture**
  (Whisper.cpp, a Python backend, yt-dlp, Supabase) that has nothing to do
  with the shipped Flutter+Isar app. Rewrote it.
- **Missing `LICENSE` file** that the README already linked to. Added a
  standard MIT license text — put in a real copyright holder name.

## An entire feature nobody ever finished: search for it before you plan around it

`docs/PART_29_CORRECTIONS.md` and `docs/PART_29_AUTH_AND_SYNC.md` are
detailed, correct instructions — written by the same AI — for wiring up
Firebase auth and cloud sync into `main.dart` and `settings_screen.dart`.
They were never actually applied to the code originally. **Update:** a
later pass in this project did wire it in — `main.dart` now attempts
`Firebase.initializeApp()` behind a Settings toggle (off by default,
wrapped in try/catch so an unconfigured project can't crash the app) —
see `FEATURE_CHECKLIST.md`'s "Cloud sync" section and
`docs/ENABLE_CLOUD_SYNC.md` for what's still on you (a real Firebase
project — nothing about that can be done from here).

## Things I skipped — a plan for you to pick up

1. **`assets/topic_packs/fitness_sport.json` was never finished.** The
   generator script cut off mid-file — the JSON degenerates into
   repeated, nonsensical keyword salad (literal snake-related keywords
   with no connection to fitness) and the file was never actually saved
   to disk in the first place (no `Set-Content` call for it ever ran).
   There is no "Fitness & Sport" topic pack in the shipped app.
2. **Two topic packs the README advertises don't exist at all:**
   "Gaming & Entertainment" and "Faith & Religion." Only 10 of the
   13 categories the README lists were ever actually written. I didn't
   author ~600 new keyword entries for 3 categories from scratch — that's
   a real content-writing task, not a bug fix, and doing it badly would
   be worse than not doing it.
3. **A whole unintegrated feature branch:** batch import from a file,
   OCR capture from a photo, and voice-note recording
   (`batch_import_screen.dart`, `ocr_capture_screen.dart`,
   `voice_note_recorder_screen.dart` and their services) all depend on
   the abandoned Whisper transcription service and the superseded topic
   classifier, and none of them were ever linked to from any button
   anywhere in the app. I archived this whole branch rather than repair
   it, since reviving it means redesigning it around what the final app
   actually does (no video/audio transcription) — that's a scoping
   decision for you, not a quick fix.
4. **The Python transcription backend (`backend/transcription/`,
   Whisper.cpp) and the Chrome extension (`extensions/chrome/`)** are
   untouched. They belong to the abandoned "self-hosted transcription
   server" architecture from part 1 and aren't used by the shipped app at
   all. Left in place in case you want to revive that direction later,
   but nothing wires into them.
5. **Monetization / premium paywall:** `premium_paywall_screen.dart`
   exists, is self-contained, and isn't broken — but it's also not linked
   from anywhere, and the README doesn't describe a v1 monetization plan.
   Left as-is, unlinked.
6. **"Clean note" is not real AI.** `ai_summary_service.dart` has
   separate iOS/Android/desktop code paths with comments about Apple
   Foundation Models and on-device Gemma, but every path actually calls
   the same placeholder: it just takes the first few sentences of the
   text. I wired this in as-is (it's harmless and matches the one AI
   feature your README says is allowed), but **don't market it as
   AI-powered** unless you replace it with something that actually is —
   right now it's a sentence extractor with misleading comments.
7. **I have not run this project.** I don't have Flutter, Dart, or Xcode
   available in this environment, and no network access to pub.dev or
   Flutter's SDK servers, so I can't run `flutter pub get`, `flutter
   analyze`, `flutter build`, or the Isar code generator here. Everything
   above was verified by reading the actual source and writing a script
   to check every import and every Isar model field access against what
   actually exists — but the first real compiler run is still ahead of
   you (see "Still required," steps 1-3).
8. **Marketing docs under `docs/`** (monetization strategy, social media
   calendar, press release, email templates, launch checklist, app store
   screenshot guide) were written for the abandoned Whisper/Supabase
   version of the app and mention prices, features, and a backend that no
   longer exist. Left untouched — these are planning documents, not code,
   and rewriting a dozen marketing docs wasn't a good use of the time
   that went into making the app itself work.

## Everything moved to `_legacy_drafts/` (nothing deleted)

Superseded or duplicate files, archived outside `lib/` so they don't
affect the build, kept so nothing is silently lost:

- Three competing "home screen" drafts → one rewritten `home_screen.dart`
- Two competing share-capture services → the one real
  `share_capture_service.dart`
- Two competing sync services (Supabase, then an intermediate Firebase
  draft) → the one real `cloud_sync_service.dart` (this matches what
  `docs/PART_29_CORRECTIONS.md` itself explicitly says to do)
- Two competing topic classifiers → the one real
  `topic_keyword_database_service.dart`
- Two competing search screens → the one real `smart_search_screen.dart`
- The abandoned Whisper `transcription_service.dart`
- The whole unintegrated batch-import/OCR/voice-note branch (see above)
- The old flat `assets/topic_keywords.json` (superseded by
  `assets/topic_packs/*.json`)
- `manual_topic_picker_screen.dart` and `settings_service.dart` (both
  orphaned — nothing imported them)
- The two standalone `pubspec_*_snippet.yaml` files (merged into the one
  real `pubspec.yaml`)
- The dead native share files (`ShareReceiverActivity.kt`, the old
  `ShareViewController.swift`)
- `lib/models/topic.dart` (an Isar `Topic` collection that was never
  actually registered in `main.dart`'s `Isar.open([...])` call, and
  nothing in the final app reads or writes it — the real "topic" data is
  just a string field on `Note`)
- `lib/models/app_settings.dart` (a nicer settings model that was
  designed but never wired in; the shipped app uses the simpler
  `AppPrefsService`)

## Still required before you can submit anywhere

1. **Run `flutter create . --org com.doomnotes --project-name doomnotes`
   in the project root.** This is foundational, not optional: nothing in
   the 29 parts ever generated the actual Flutter project shell — there's
   no `ios/Runner.xcodeproj`, no `android/build.gradle`, no
   `MainActivity.kt`. Only `AndroidManifest.xml` and the Share Extension
   files existed. `flutter create .` generates all of that safely next to
   your existing `lib/` and `pubspec.yaml`. **Check what it does to
   `AndroidManifest.xml`** — if it resets it, re-apply the intent-filter
   block from the version in this project (the share-related parts, not
   the boilerplate).
2. `flutter pub get`, then
   `flutter pub run build_runner build --delete-conflicting-outputs`
   (generates the Isar `*.g.dart` files the database models need).
3. `flutter analyze` — I've checked the import graph and model field
   usage by hand as thoroughly as I could without a compiler, but a real
   analyzer run is the only way to be sure.
4. Finish the iOS Share Extension in Xcode —
   `docs/IOS_SHARE_EXTENSION_SETUP.md`.
5. Host `docs/PRIVACY_POLICY.md` and `docs/TERMS_OF_SERVICE.md`
   somewhere real, fill in the bracketed placeholders, and update the two
   URLs in `lib/screens/settings_screen.dart`.
6. Test the actual share flow from TikTok/YouTube/Instagram on a real
   device for both platforms — this has never been run, only read.
