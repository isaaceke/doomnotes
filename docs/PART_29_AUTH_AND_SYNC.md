# DOOMNOTES Part 29: Google, Apple, Email/Password Authentication + Sync

## What Works

- Google sign-in
- Apple sign-in on supported Apple devices
- Email/password sign-up and sign-in
- Password reset email
- Firebase-authenticated Firestore sync
- Account-specific note path:

```text
users/{firebaseAuthUid}/notes/{noteId}
```

A user who signs in on a second device receives the same Firestore library after local sync starts.

## Essential Firebase Console Setup

### 1. Firebase Authentication

Firebase Console → Authentication → Sign-in method:

- Enable **Email/Password**
- Enable **Google**
- Enable **Apple**
- Set an authorized support email for the project

### 2. Google Sign-In

For Android:

1. Firebase Console → Project settings → Your Android app
2. Add SHA-1 and SHA-256 fingerprints for:
   - Debug signing key
   - Release signing key
   - Google Play App Signing key before release
3. Re-run `flutterfire configure` after setup if configuration changes.

For iOS:

1. Put `GoogleService-Info.plist` in `ios/Runner`.
2. Add the reversed client ID as an iOS URL scheme.
3. Ensure the iOS bundle ID exactly matches the Firebase app entry.

### 3. Sign in with Apple

1. Apple Developer → Certificates, Identifiers & Profiles.
2. Open the App ID that exactly matches DoomNotes’ bundle ID.
3. Enable **Sign in with Apple**.
4. Xcode → Runner → Signing & Capabilities → add **Sign in with Apple**.
5. Firebase Console → Authentication → Apple → enable it.
6. Configure Apple service identifiers and private key details in Firebase if you later support web/Android Apple sign-in.

Apple commonly supplies a user’s name/email only on the first approval, so the app saves them when available. [427][434]

## pubspec.yaml

Add the packages from `pubspec_part_29_auth_snippet.yaml`, then run:

```bash
flutter pub get
flutterfire configure
```

## main.dart Integration

Initialize Firebase before Isar, preferences, Firestore, or authentication:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

After opening Isar:

```dart
await CloudSyncService.instance.initialize(isarDb);
```

Use an authentication-state listener to restart sync when a user signs in:

```dart
AuthService.instance.authStateChanges.listen((user) async {
  await CloudSyncService.instance.stop();

  if (user != null) {
    await CloudSyncService.instance.initialize(isarDb);
  }
});
```

## Settings Integration

Inside the Settings screen, add:

```dart
import '../widgets/account_sync_tile.dart';

SettingsSection(
  title: 'Account & Sync',
  children: const [
    AccountSyncTile(),
  ],
),
```

## Firestore Rules

Deploy these rules before releasing:

```javascript
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, update: if request.auth != null &&
                            request.auth.uid == userId;

      allow create: if request.auth != null &&
                    request.auth.uid == userId;

      match /notes/{noteId} {
        allow read, create, update, delete: if request.auth != null &&
          request.auth.uid == userId;
      }
    }
  }
}
```

Never use public read/write rules in production.

## Migration Rule

Do not create a permanent anonymous cloud account as the main product identity.

Recommended flow:
1. Allow local-only usage without account.
2. When the user chooses Back up and sync, show `AuthScreen`.
3. Push the current local library to the newly authenticated account.
4. On another device, sign in first, then Firestore downloads the library.

For existing anonymous Firebase users, use `linkAnonymousUserWithGoogle`, `linkAnonymousUserWithEmail`, or `linkAnonymousUserWithApple` to preserve their identity rather than creating a second account.

## Required Tests

1. Create an email/password account → close/reopen → still signed in.
2. Sign in to same email account on device B → notes from device A appear.
3. Create note on device A → appears in Firestore and device B.
4. Create note offline → verify local save; reconnect → it syncs.
5. Google account picker works on Android and iOS.
6. Apple sign-in works on physical iPhone/iPad with the correct Apple entitlement.
7. Password reset sends a working email.
8. Sign out → cloud sync listener stops; local notes remain on device.