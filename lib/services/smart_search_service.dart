import 'package:isar/isar.dart';
import '../main.dart';
import '../models/note.dart';
import 'search_normalizer_service.dart';
import 'search_alias_database_service.dart';

class SmartSearchService {
  final SearchNormalizerService _normalizer = SearchNormalizerService();
  final SearchAliasDatabaseService _aliases = SearchAliasDatabaseService();

  Future<List<Note>> search(String rawQuery, {int limit = 50}) async {
    if (rawQuery.trim().isEmpty) return [];

    final normalized = _normalizer.normalize(rawQuery);
    final expanded = _aliases.expandQuery(normalized);
    final tokens = expanded.map((q) => _normalizer.tokenize(q)).expand((t) => t).toSet();

    if (tokens.isEmpty) return [];

    final allNotes = await isarDb.collection<Note>()
        .filter()
        .isArchivedEqualTo(false)
        .isDeletedEqualTo(false)
        .findAll();

    final scored = <_ScoredNote>[];

    for (final note in allNotes) {
      final score = _scoreNote(note, tokens);
      if (score > 0) {
        scored.add(_ScoredNote(note: note, score: score));
      }
    }

    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored.take(limit).map((s) => s.note).toList();
  }

  double _scoreNote(Note note, Set<String> tokens) {
    final searchable = _buildSearchableText(note);
    if (searchable.isEmpty) return 0;

    final normalized = _normalizer.normalize(searchable);
    final noteTokens = _normalizer.tokenize(normalized).toSet();

    if (noteTokens.isEmpty) return 0;

    final matches = tokens.where(noteTokens.contains).length;
    if (matches == 0) return 0;

    // Bonus for topic and keywords matches
    var score = matches.toDouble();

    final topicNormalized = _normalizer.normalize(note.topic);
    if (tokens.any(topicNormalized.contains)) {
      score += 3;
    }

    for (final kw in note.keywords) {
      final kwNorm = _normalizer.normalize(kw);
      if (tokens.any(kwNorm.contains)) {
        score += 1.5;
      }
    }

    return score;
  }

  String _buildSearchableText(Note note) {
    return [
      note.topic,
      note.summary ?? '',
      note.transcript ?? '',
      note.videoUrl,
      note.keywords.join(' '),
    ].where((s) => s.isNotEmpty).join(' ');
  }
}

class _ScoredNote {
  final Note note;
  final double score;

  _ScoredNote({required this.note, required this.score});
}