# DOOMNOTES Part 13: Batch Capture, Import, Export, and Topic Control

## New User Features

1. Paste multiple links into DoomNotes; one URL per line is the simplest workflow.
2. Import a JSON backup created by DoomNotes.
3. Process a queue sequentially so the device and transcription backend are not overloaded.
4. Save text-only content as a note without transcription.
5. Save video links from Instagram, TikTok, YouTube, and other supported sites.
6. Save X/Twitter links as reference notes, preserving the original link.
7. Export all notes to JSON for a portable full backup.
8. Export one topic to Markdown for use in Obsidian, Notion, Git, or plain files.
9. Remove items from a batch queue before processing.
10. See success and failure status for every queued item.

## Manual Topic Picker

The picker has two modes:

- **Automatic (default):** Keyword classification picks the folder. The notification must say exactly where the note went, for example: `Saved to Color Grading — Your note was added to the Color Grading folder from Instagram.`
- **Always ask:** The app opens the topic picker after capture and before saving. The user can accept the suggested folder, choose another one, or create one.
- **Batch one-topic mode:** The user can assign all imports in one batch to a single selected topic.

Manual selection is never forced. It is a user setting.

## Important Integration Work

The coding agent must:
1. Add `shared_preferences` to `pubspec.yaml`.
2. Add `csv` later only if CSV import/export is implemented.
3. Replace the older `share_handler_service.dart` with one coherent final implementation; do not keep duplicate `*_updated.dart` production services.
4. Wire `CaptureNotificationService.showSaved()` into the successful capture path.
5. Call it only when capture notifications are enabled.
6. Add a Settings switch labelled `Ask me to choose a topic after sharing`.
7. Add a Home Screen action/button that opens `BatchImportScreen`.
8. Add a Settings action for `Export Full Backup`.
9. Test source labels: Instagram, TikTok, YouTube, X, web, text.
10. Never claim that X post text or image contents were fetched if the shared payload only contains a URL. Store the link and any user-provided shared text honestly.

## App Store / Play Store Notes

- Use the platform share sheet and its normal text/file sharing behavior; do not use screen overlays or accessibility services.
- Ask for permissions only when the feature requiring them is invoked.
- Tell users exactly what is stored and uploaded in the privacy policy.
- Do not imply affiliation with Instagram, TikTok, YouTube, or X.