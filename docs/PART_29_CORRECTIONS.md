# Part 29 Corrections to Earlier Sync Draft

The earlier Firebase sync example must not be used unchanged.

## Fixed in Part 29

1. **Real identity**
   - Firebase Auth UID is now the user namespace.
   - Supports Google, Apple, and email/password.

2. **Stable cloud ID**
   - Firestore note IDs use `note_{localId}`.
   - Do not generate random numeric Isar IDs using a shortened UUID: collisions are possible.

3. **Correct authentication migration**
   - Guest/anonymous accounts can be linked to Google, Apple, or email instead of silently losing their data.

4. **One canonical sync service**
   - Use `lib/services/cloud_sync_service.dart`.
   - Delete or archive `firebase_sync_service.dart` and `note_sync_bridge_service.dart` from Part 28.

5. **Secure Firestore rules**
   - Notes can be read and written only by their authenticated Firebase owner.

6. **No end-to-end encryption claim**
   - Firestore sync is account-scoped and protected by Firebase rules.
   - It is not end-to-end encrypted unless client-side encryption is explicitly added later.