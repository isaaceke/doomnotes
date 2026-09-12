import 'package:isar/isar.dart';
import '../main.dart';
import '../models/note.dart';
import 'auth_service.dart';
import 'cloud_sync_service.dart';

/// Whether cloud sync is actually active right now (Firebase configured
/// AND a real user signed in) — not just "the setting is on".
bool get _cloudSyncActive {
  if (!firebaseReady) return false;
  final user = AuthService.instance.currentUser;
  return user != null && !user.isAnonymous;
}

/// Saves [note] locally and — if cloud sync is active — pushes it too.
/// Always bumps [Note.updatedAt] first, since that's what cloud-sync
/// conflict resolution keys off. Use this instead of calling
/// `isarDb.writeTxn(() => isarDb.collection<Note>().put(note))` directly
/// for any change that should be considered "the user touched this note".
Future<void> saveNote(Note note) async {
  note.updatedAt = DateTime.now();

  await isarDb.writeTxn(() async {
    await isarDb.collection<Note>().put(note);
  });

  if (_cloudSyncActive) {
    // Best-effort: don't let a flaky network turn a local save into an
    // error the user sees. Sync will catch up next time this note (or
    // any note) is saved again, or on the next app start's bulk push.
    unawaited(CloudSyncService.instance.pushNote(isarDb, note));
  }
}

/// Soft-deletes [note] (moves it to Trash) locally and syncs the tombstone
/// so other signed-in devices also see it as deleted, without ever
/// actually deleting the Firestore document (simpler and safer than
/// reasoning about real delete propagation).
Future<void> trashNote(Note note) async {
  note
    ..isDeleted = true
    ..deletedAt = DateTime.now();
  await saveNote(note);
}

Future<void> restoreNote(Note note) async {
  note
    ..isDeleted = false
    ..deletedAt = null;
  await saveNote(note);
}

/// Permanently removes [note] locally. Pushes one last tombstone update
/// first (best-effort) so other devices that already pulled this note
/// know it's gone, since there's no local copy left afterward to retry
/// pushing from.
Future<void> permanentlyDeleteNote(Note note) async {
  if (_cloudSyncActive) {
    note
      ..isDeleted = true
      ..deletedAt = DateTime.now()
      ..updatedAt = DateTime.now();
    await CloudSyncService.instance.pushNote(isarDb, note);
  }

  await isarDb.writeTxn(() async {
    await isarDb.collection<Note>().delete(note.id);
  });
}

void unawaited(Future<void> future) {
  // Explicit no-op wrapper so "fire and forget" calls above are an
  // intentional, readable choice rather than a missed `await`.
}
