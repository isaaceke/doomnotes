# DOOMNOTES Part 28: Cloud Sync Agent Checklist

## Firebase Setup

- [ ] Create Firebase project.
- [ ] Add Android/iOS apps.
- [ ] Download `google-services.json` and `GoogleService-Info.plist`.
- [ ] Run `flutterfire configure` and commit `firebase_options.dart`.
- [ ] Initialize Firebase in `main.dart` before using Firestore.

## Code Integration

- [ ] Add `cloud_note.dart`, `firebase_sync_service.dart`, `note_sync_bridge_service.dart`.
- [ ] In `main.dart`, call `syncService.initialize()` after Isar/prefs init.
- [ ] After every local note save, call `bridge.onNoteSavedLocally(note)`.

## Testing

- [ ] Single device, online: create note → appears in Firestore console.
- [ ] Single device, offline: create note → appears locally; later reconnects → appears in Firestore.
- [ ] Two devices, same user: create on A → appears on B; edit on B → appears on A.
- [ ] No AI chat, no cloud-only features; offline still works.

## Privacy / Security

- [ ] Firestore rules scoped to `userId`:
  ```javascript
  match /users/{userId}/notes/{noteId} {
    allow read, write: if request.auth != null && request.auth.uid == userId;
  }
  ```
- [ ] Document that notes are synced to the cloud for the user’s own devices.

## Do Not Add

- No AI chat.
- No scraping social platforms.
- No promises of “end-to-end encrypted” unless you actually implement it.