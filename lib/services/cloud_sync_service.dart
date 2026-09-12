import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:isar/isar.dart';
import '../models/note.dart';

class CloudSyncService {
  CloudSyncService._();

  static final CloudSyncService instance = CloudSyncService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _notesSubscription;

  String? get _uid => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _notes {
    final uid = _uid;
    if (uid == null) throw StateError('Cannot sync without a signed-in user.');

    return _firestore.collection('users').doc(uid).collection('notes');
  }

  DocumentReference<Map<String, dynamic>> get _profile {
    final uid = _uid;
    if (uid == null) throw StateError('Cannot create profile without a user.');

    return _firestore.collection('users').doc(uid);
  }

  Future<void> initialize(Isar isar) async {
    if (_uid == null) return;

    await _ensureProfile();
    await pushAllLocalNotes(isar);
    await _startListeningForRemoteNotes(isar);
  }

  Future<void> _ensureProfile() async {
    final user = _auth.currentUser!;
    await _profile.set(
      {
        'email': user.email,
        'display_name': user.displayName,
        'photo_url': user.photoURL,
        'provider_ids': user.providerData.map((provider) => provider.providerId).toList(),
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  /// One-time bulk push, used on initial sign-in / app start with sync
  /// already enabled. For anything that happens while the app is running,
  /// use note_repository.dart's saveNote()/trashNote()/etc, which push
  /// incrementally instead of waiting for the next full push.
  Future<void> pushAllLocalNotes(Isar isar) async {
    if (_uid == null) return;

    final localNotes = await isar.collection<Note>().findAll();

    final batch = _firestore.batch();

    for (final note in localNotes) {
      final reference = _notes.doc(_noteCloudId(note));

      batch.set(
        reference,
        _toFirestore(note),
        SetOptions(merge: true),
      );
    }

    await batch.commit();
  }

  Future<void> pushNote(Isar isar, Note note) async {
    if (_uid == null) return;

    await _notes.doc(_noteCloudId(note)).set(
      _toFirestore(note),
      SetOptions(merge: true),
    );
  }

  Future<void> _startListeningForRemoteNotes(Isar isar) async {
    await _notesSubscription?.cancel();

    _notesSubscription = _notes.snapshots().listen((snapshot) async {
      for (final change in snapshot.docChanges) {
        final data = change.doc.data();
        if (data == null) continue;

        // Notes are never actually deleted as Firestore documents — a
        // trashed note is synced as a normal field update (is_deleted:
        // true), same as any other change. So a real `removed` doc-change
        // event isn't a normal part of this app's own sync flow; skipping
        // it here is a deliberate no-op, not a gap in delete handling.
        if (change.type == DocumentChangeType.removed) continue;

        await _mergeRemoteNote(isar, change.doc.id, data);
      }
    });
  }

  Future<void> _mergeRemoteNote(
    Isar isar,
    String cloudId,
    Map<String, dynamic> remote,
  ) async {
    final localId = _readLocalId(cloudId);
    if (localId == null) return;

    final remoteUpdatedAt = _timestampToDate(remote['updated_at']) ?? DateTime.now();
    final remoteCreatedAt = _timestampToDate(remote['created_at']) ?? DateTime.now();

    await isar.writeTxn(() async {
      final existing = await isar.collection<Note>().get(localId);

      // Last-write-wins on updatedAt (a real modification time, not
      // createdAt — see the Note model's comment on why that distinction
      // matters). If the local copy was touched more recently than this
      // remote update, the remote write is stale; don't apply it.
      if (existing != null && existing.updatedAt.isAfter(remoteUpdatedAt)) {
        return;
      }

      final note = existing ?? Note()
        ..id = localId
        ..createdAt = remoteCreatedAt;

      note.topic = remote['topic'] as String? ?? 'Unsorted';
      note.summary = remote['summary'] as String?;
      note.transcript = remote['transcript'] as String? ?? '';
      note.videoUrl = remote['video_url'] as String? ?? '';
      note.keywords = List<String>.from(remote['keywords'] as List<dynamic>? ?? []);
      note.isArchived = remote['is_archived'] as bool? ?? false;
      note.isFavorite = remote['is_favorite'] as bool? ?? false;
      note.isDeleted = remote['is_deleted'] as bool? ?? false;
      note.deletedAt = _timestampToDate(remote['deleted_at']);
      note.updatedAt = remoteUpdatedAt;

      await isar.collection<Note>().put(note);
    });
  }

  Map<String, dynamic> _toFirestore(Note note) {
    return {
      'local_note_id': note.id,
      'topic': note.topic,
      'summary': note.summary,
      'transcript': note.transcript,
      'video_url': note.videoUrl,
      'keywords': note.keywords,
      'is_archived': note.isArchived,
      'is_favorite': note.isFavorite,
      'is_deleted': note.isDeleted,
      'deleted_at': note.deletedAt == null ? null : Timestamp.fromDate(note.deletedAt!),
      'created_at': Timestamp.fromDate(note.createdAt),
      // Deliberately NOT FieldValue.serverTimestamp() here: conflict
      // resolution needs to compare this value against the local
      // updatedAt immediately (including in pushAllLocalNotes' batch
      // write), and a server timestamp is an unresolved placeholder
      // until the server round-trips it back — not something the merge
      // logic above could read the moment it's written. Using the
      // client's own clock is less precise across devices with clock
      // drift, but that's a much smaller problem than comparing against
      // a value that doesn't exist yet.
      'updated_at': Timestamp.fromDate(note.updatedAt),
    };
  }

  String _noteCloudId(Note note) => 'note_${note.id}';

  int? _readLocalId(String cloudId) {
    if (!cloudId.startsWith('note_')) return null;
    return int.tryParse(cloudId.substring('note_'.length));
  }

  DateTime? _timestampToDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    return null;
  }

  Future<void> stop() async {
    await _notesSubscription?.cancel();
    _notesSubscription = null;
  }
}
