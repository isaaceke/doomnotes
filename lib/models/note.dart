// DOOMNOTES - Note Model
// Purpose: Defines database schema for individual notes (transcripts)
// App Store Compliance: All user data stored locally first, synced to cloud with consent
// Privacy: No PII stored, only video URLs and transcripts

import 'package:isar/isar.dart';

part 'note.g.dart';

// Note collection - stored in Isar database
// Each note represents one transcribed Instagram video
@collection
class Note {
  // Auto-incrementing unique ID
  Id id = Isar.autoIncrement;
  
  // Topic folder this note belongs to (e.g., 'investing', 'color grading')
  @Index() String topic = '';
  
  // Full transcript text from video
  String transcript = '';
  
  // Original Instagram/TikTok/YouTube video URL
  String videoUrl = '';
  
  // Optional video thumbnail URL for preview
  String? thumbnailUrl;
  
  // Keywords detected in transcript for search
  @Index() List<String> keywords = [];
  
  // Timestamps for key moments in video (in seconds)
  List<int> timestamps = [];
  
  // When user captured this note
  @Index() DateTime createdAt = DateTime.now();

  // When this note was last modified (capture, edit, favorite/archive
  // toggle, etc). Separate from createdAt on purpose — conflict resolution
  // for cloud sync needs "when did this last change", not "when was it
  // first saved". An earlier version of cloud sync used createdAt for
  // this and got it wrong: an old note edited today would lose to a
  // remote copy from weeks ago that had a later createdAt.
  @Index() DateTime updatedAt = DateTime.now();
  
  // Whether note is archived (hidden from main view)
  bool isArchived = false;
  
  // Whether note is favorited by user
  bool isFavorite = false;
  
  // Version number for conflict resolution during sync
  int version = 1;
  
  // Whether transcript has been AI-summarized
  bool isSummarized = false;
  
  // AI-generated summary (if isSummarized is true)
  String? summary;
  
  // User-added custom tags
  List<String> customTags = [];
  
  // Playback position last time user watched video (in seconds)
  int lastPlaybackPosition = 0;
  
  // Number of times user has opened this note
  int viewCount = 0;
  
  // Whether this note replaced an older duplicate
  bool isReplacement = false;
  
  // ID of note this replaced (if isReplacement is true)
  int? replacedNoteId;

  // Soft delete: moved to Trash, not yet permanently removed.
  @Index() bool isDeleted = false;

  // When the note was moved to Trash (null if not deleted).
  DateTime? deletedAt;
}