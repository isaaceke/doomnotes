import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/topic_definition.dart';
import '../models/topic_match.dart';

class TopicKeywordDatabaseService {
  static const _assetPaths = [
    'assets/topic_packs/tech_people.json',
    'assets/topic_packs/creatives.json',
    'assets/topic_packs/technical_creatives.json',
    'assets/topic_packs/philosophy_psychology.json',
    'assets/topic_packs/lifestyle_beauty_personal_care.json',
    'assets/topic_packs/students_opportunities.json',
    'assets/topic_packs/jobs_remote_work_9to5.json',
    'assets/topic_packs/politics_news_civic.json',
    'assets/topic_packs/music.json',
    'assets/topic_packs/money_investing.json',
  ];

  final List<TopicDefinition> _topics = [];
  bool _loaded = false;

  Future<void> load() async {
    if (_loaded) return;

    for (final path in _assetPaths) {
      final raw = await rootBundle.loadString(path);
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final packId = json['packId'] as String;
      final topics = List<Map<String, dynamic>>.from(json['topics'] as List);

      _topics.addAll(
        topics.map((topic) => TopicDefinition.fromJson(packId, topic)),
      );
    }

    _loaded = true;
  }

  List<TopicDefinition> get allTopics => List.unmodifiable(_topics);

  Future<List<TopicMatch>> classify(
    String input, {
    int limit = 5,
    Iterable<String>? enabledPackIds,
  }) async {
    await load();

    final normalizedInput = _normalize(input);
    if (normalizedInput.isEmpty) return [];

    final activePacks = enabledPackIds?.toSet();
    final candidates = activePacks == null
        ? _topics
        : _topics.where((topic) => activePacks.contains(topic.packId));

    final results = <TopicMatch>[];

    for (final topic in candidates) {
      final matched = <String>[];
      var score = 0.0;

      for (final keyword in topic.keywords) {
        if (_containsPhrase(normalizedInput, keyword)) {
          matched.add(keyword);
          score += _keywordWeight(keyword);
        }
      }

      for (final keyword in topic.strongKeywords) {
        if (_containsPhrase(normalizedInput, keyword)) {
          if (!matched.contains(keyword)) matched.add(keyword);
          score += 12;
        }
      }

      for (final negative in topic.negativeKeywords) {
        if (_containsPhrase(normalizedInput, negative)) {
          score -= 7;
        }
      }

      if (score > 0) {
        final cappedScore = score > 100 ? 100.0 : score;
        results.add(
          TopicMatch(
            topic: topic,
            score: cappedScore,
            matchedKeywords: matched.take(8).toList(),
          ),
        );
      }
    }

    results.sort((a, b) => b.score.compareTo(a.score));
    return results.take(limit).toList();
  }

  double _keywordWeight(String keyword) {
    final words = keyword.trim().split(RegExp(r'\s+')).length;
    if (words >= 4) return 9;
    if (words == 3) return 7;
    if (words == 2) return 5;
    return 2.5;
  }

  bool _containsPhrase(String normalizedText, String rawPhrase) {
    final phrase = _normalize(rawPhrase);
    if (phrase.isEmpty) return false;

    final escaped = RegExp.escape(phrase).replaceAll(r'\ ', r'\s+');
    return RegExp('(?:^|\\s)$escaped(?:\$|\\s)', caseSensitive: false)
        .hasMatch(normalizedText);
  }

  String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'https?:\/\/\S+'), ' ')
        .replaceAll(RegExp(r'[^a-z0-9+#.\s-]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}