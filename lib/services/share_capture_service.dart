import 'dart:async';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:isar/isar.dart';
import '../models/note.dart';
import 'topic_keyword_database_service.dart';
import 'source_link_service.dart';
import 'app_prefs_service.dart';
import 'note_repository.dart';
import '../main.dart';

/// Result of a single capture, broadcast on [ShareCaptureService.events]
/// so the UI can show a confirmation (see CaptureSuccessSheet).
class CaptureResult {
  final Note note;
  final bool wasUpdate;

  const CaptureResult({required this.note, required this.wasUpdate});
}

class ShareCaptureService {
  final _topicService = TopicKeywordDatabaseService();
  final _sourceService = SourceLinkService();
  StreamSubscription? _shareSubscription;

  final _eventsController = StreamController<CaptureResult>.broadcast();

  /// Fires once per successful capture, whether it came from the OS share
  /// sheet, a cold-start share, or the manual "Add link" flow.
  Stream<CaptureResult> get events => _eventsController.stream;

  Future<void> init() async {
    _shareSubscription = ReceiveSharingIntent.instance.getMediaStream().listen(
      (List<SharedMediaFile> value) async {
        for (final file in value) {
          // Prefer text/message if present, otherwise path (works for plain text shares and links)
          final content = (file.message != null && file.message!.trim().isNotEmpty)
              ? file.message!
              : file.path;
          if (content.trim().isNotEmpty) {
            await _processSharedItem(content);
          }
        }
      },
      onError: (err) {
        // optionally log
      },
    );
  }

  Future<void> handleInitialShare() async {
    await init();

    final initial = await ReceiveSharingIntent.instance.getInitialMedia();
    if (initial.isNotEmpty) {
      for (final file in initial) {
        final content = (file.message != null && file.message!.trim().isNotEmpty)
            ? file.message!
            : file.path;
        if (content.trim().isNotEmpty) {
          await _processSharedItem(content);
        }
      }
      // Important: tell the plugin we consumed the initial share
      await ReceiveSharingIntent.instance.reset();
    }
  }

  /// Public entry point for content the user pastes in manually (via the
  /// "Add link" button on Home), as opposed to content that arrives through
  /// the OS share sheet. Runs through the same classify-and-save pipeline.
  Future<void> captureText(String sharedText) => _processSharedItem(sharedText);

  Future<void> _processSharedItem(String sharedText) async {
    final source = _sourceService.extractFromSharedText(sharedText);
    final videoUrl = source?.url ?? '';

    final titleCandidate = _sourceService.extractVideoTitle(sharedText) ??
        (sharedText.length > 120 ? '${sharedText.substring(0, 120)}...' : sharedText);

    final matches = await _topicService.classify(sharedText, limit: 3);

    String topic = 'Unsorted';
    if (matches.isNotEmpty) {
      final top = matches.first;
      if (top.confidence >= 45 && appPrefs.useAutomaticTopicMode) {
        topic = top.topic.label;
      }
    }

    // Apply any user renames from Manage Topics: without this, renaming
    // "Fitness" to "Health" only relabels notes that already exist — the
    // next fitness-related share would otherwise recreate "Fitness" from
    // scratch, since the keyword pack itself is never modified.
    topic = appPrefs.topicAliases[topic] ?? topic;

    // If this looks like something already saved, treat the new share as
    // an update rather than a duplicate — e.g. re-sharing a video you
    // saved weeks ago with a newer caption. Matching is normalized (see
    // SourceLinkService.normalizeForComparison) so youtu.be/<id>,
    // youtube.com/shorts/<id>, and youtube.com/watch?v=<id> all match each
    // other, and tracking junk appended to a link doesn't defeat matching.
    // For plain-text shares with no link, fall back to an exact match on
    // the saved text itself.
    Note? existing;
    if (videoUrl.isNotEmpty) {
      final normalizedNew = SourceLinkService.normalizeForComparison(videoUrl);
      final candidates = await isarDb.collection<Note>()
          .filter()
          .isDeletedEqualTo(false)
          .videoUrlIsNotEmpty()
          .findAll();
      for (final candidate in candidates) {
        if (SourceLinkService.normalizeForComparison(candidate.videoUrl) == normalizedNew) {
          existing = candidate;
          break;
        }
      }
    } else {
      final normalizedText = sharedText.trim();
      existing = await isarDb.collection<Note>()
          .filter()
          .isDeletedEqualTo(false)
          .videoUrlIsEmpty()
          .transcriptEqualTo(normalizedText)
          .findFirst();
    }

    final bool wasUpdate = existing != null;

    final note = existing ?? Note();
    note
      ..topic = topic
      ..summary = titleCandidate
      ..transcript = sharedText
      ..videoUrl = videoUrl
      ..isArchived = false
      ..isDeleted = false
      ..createdAt = DateTime.now();

    if (wasUpdate) {
      note
        ..isReplacement = true
        ..version = note.version + 1;
    }

    await saveNote(note);

    _eventsController.add(CaptureResult(note: note, wasUpdate: wasUpdate));
  }

  void dispose() {
    _shareSubscription?.cancel();
    _eventsController.close();
  }
}
