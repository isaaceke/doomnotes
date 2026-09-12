# Enabling Cloud Sync (Firebase)

As of this round, the code side is actually wired in — not just written and
sitting unused. `main.dart` already:
- checks `appPrefs.cloudSyncEnabled` (off by default) before touching Firebase at all
- wraps `Firebase.initializeApp()` in a try-catch, so an unconfigured project
  fails safely into local-only mode instead of crashing
- sets a `firebaseReady` flag that Settings uses to show either the real
  "Account & Sync" tile or a clear "not configured yet" message

So the only thing left is the external Firebase setup — nothing more to
edit in `main.dart` or `settings_screen.dart`.

## Steps

1. **Firebase Console:** create a project, add your Android app (package
   `com.doomnotes.app`, or whatever you passed to `flutter create --org`),
   download `google-services.json` → `android/app/`.
2. Authentication → Sign-in method: enable **Email/Password** and
   **Google**. (Apple sign-in exists in the code too, but you're focused
   on Android for now — skip it unless you revisit iOS.)
3. Run `flutterfire configure` from the project root. This **overwrites**
   `lib/firebase_options.dart` — which currently holds placeholder values
   on purpose (see the comment at the top of that file) — with your real
   project's values.
4. For Google Sign-In: add your debug and release SHA-1/SHA-256
   fingerprints in Firebase Console → Project settings → your Android app.
   Without this, Google sign-in fails with an unhelpful error.
5. Deploy Firestore rules — never ship with the default open rules:
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /users/{userId} {
         allow read, update, create: if request.auth != null && request.auth.uid == userId;
         match /notes/{noteId} {
           allow read, create, update, delete: if request.auth != null && request.auth.uid == userId;
         }
       }
     }
   }
   ```
6. In the app: Settings → Account & Sync → **Enable cloud sync** → restart
   the app (Firebase only initializes at startup, so a running instance
   won't pick up the change live). Once restarted, the tile becomes a
   real sign-in prompt.

## Don't claim end-to-end encryption

Firestore sync here is account-scoped and protected by the rules above —
it is **not** end-to-end encrypted. Don't say otherwise in your store
listing.
