class TopicDefinition {
  final String id;
  final String label;
  final String packId;
  final String icon;
  final List<String> keywords;
  final List<String> strongKeywords;
  final List<String> negativeKeywords;

  const TopicDefinition({
    required this.id,
    required this.label,
    required this.packId,
    required this.icon,
    required this.keywords,
    this.strongKeywords = const [],
    this.negativeKeywords = const [],
  });

  factory TopicDefinition.fromJson(
    String packId,
    Map<String, dynamic> json,
  ) {
    return TopicDefinition(
      id: json['id'] as String,
      label: json['label'] as String,
      packId: packId,
      icon: (json['icon'] as String?) ?? 'folder',
      keywords: List<String>.from(json['keywords'] as List<dynamic>? ?? []),
      strongKeywords: List<String>.from(
        json['strongKeywords'] as List<dynamic>? ?? [],
      ),
      negativeKeywords: List<String>.from(
        json['negativeKeywords'] as List<dynamic>? ?? [],
      ),
    );
  }
}