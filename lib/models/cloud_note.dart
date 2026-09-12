import 'package:cloud_firestore/cloud_firestore.dart';

class CloudNote {
  final String id;
  final String userId;
  final String topic;
  final String? summary;
  final String transcript;
  final String videoUrl;
  final List<String> keywords;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;

  CloudNote({
    required this.id,
    required this.userId,
    required this.topic,
    this.summary,
    required this.transcript,
    required this.videoUrl,
    required this.keywords,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
  });

  factory CloudNote.fromFirestore(String id, Map<String, dynamic> data) {
    return CloudNote(
      id: id,
      userId: data['user_id'] as String,
      topic: data['topic'] as String,
      summary: data['summary'] as String?,
      transcript: data['transcript'] as String,
      videoUrl: data['video_url'] as String? ?? '',
      keywords: List<String>.from(data['keywords'] as List<dynamic>? ?? []),
      isArchived: data['is_archived'] as bool? ?? false,
      createdAt: (data['created_at'] as Timestamp).toDate(),
      updatedAt: (data['updated_at'] as Timestamp).toDate(),
      version: data['version'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId,
      'topic': topic,
      'summary': summary,
      'transcript': transcript,
      'video_url': videoUrl,
      'keywords': keywords,
      'is_archived': isArchived,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
      'version': version,
    };
  }

  CloudNote copyWith({
    String? topic,
    String? summary,
    String? transcript,
    String? videoUrl,
    List<String>? keywords,
    bool? isArchived,
    DateTime? updatedAt,
    int? version,
  }) {
    return CloudNote(
      id: id,
      userId: userId,
      topic: topic ?? this.topic,
      summary: summary ?? this.summary,
      transcript: transcript ?? this.transcript,
      videoUrl: videoUrl ?? this.videoUrl,
      keywords: keywords ?? this.keywords,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
    );
  }
}