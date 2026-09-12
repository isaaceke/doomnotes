import 'topic_definition.dart';

class TopicMatch {
  final TopicDefinition topic;
  final double score;
  final List<String> matchedKeywords;

  const TopicMatch({
    required this.topic,
    required this.score,
    required this.matchedKeywords,
  });

  double get confidence => score.clamp(0, 100);

  bool get needsConfirmation => confidence < 45;
}