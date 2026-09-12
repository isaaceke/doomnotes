import '../models/search_alias.dart';

class SearchAliasDatabaseService {
  static final List<SearchAlias> _aliases = [
    const SearchAlias(
      canonical: 'gwara gwara',
      variants: ['gwara', 'qwara', 'quara', 'gwaragwara', 'gwara-gwara'],
    ),
    const SearchAlias(
      canonical: 'react server components',
      variants: ['rsc', 'server components', 'react server', 'next.js rsc'],
    ),
    const SearchAlias(
      canonical: 'machine learning',
      variants: ['ml', 'deep learning', 'neural network', 'ai model'],
    ),
    const SearchAlias(
      canonical: 'color grading',
      variants: ['color correction', 'grading', 'lut', 'davinci resolve'],
    ),
    const SearchAlias(
      canonical: 'scholarship',
      variants: ['scholarships', 'fully funded', 'grant', 'bursary'],
    ),
    const SearchAlias(
      canonical: 'remote job',
      variants: ['remote jobs', 'work from home', 'wfh job', 'remote role'],
    ),
    const SearchAlias(
      canonical: 'skincare',
      variants: ['skin care', 'skin routine', 'face routine'],
    ),
    const SearchAlias(
      canonical: 'attachment theory',
      variants: ['attachment style', 'anxious attachment', 'avoidant attachment'],
    ),
  ];

  List<String> expandQuery(String normalizedQuery) {
    final results = <String>{normalizedQuery};

    for (final alias in _aliases) {
      if (alias.canonical == normalizedQuery) {
        results.addAll(alias.variants);
        continue;
      }

      if (alias.variants.contains(normalizedQuery)) {
        results.add(alias.canonical);
        results.addAll(alias.variants);
        continue;
      }

      for (final variant in alias.variants) {
        if (normalizedQuery.contains(variant)) {
          results.add(alias.canonical);
        }
      }
    }

    return results.toList();
  }
}