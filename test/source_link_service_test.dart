import 'package:flutter_test/flutter_test.dart';
import 'package:doomnotes/services/source_link_service.dart';

void main() {
  group('SourceLinkService.normalizeForComparison', () {
    test('youtu.be, shorts, and watch?v= forms of the same video match', () {
      final a = SourceLinkService.normalizeForComparison('https://youtu.be/abc123');
      final b = SourceLinkService.normalizeForComparison('https://www.youtube.com/watch?v=abc123');
      final c = SourceLinkService.normalizeForComparison('https://youtube.com/shorts/abc123');

      expect(a, equals(b));
      expect(b, equals(c));
    });

    test('different video IDs do not match', () {
      final a = SourceLinkService.normalizeForComparison('https://youtu.be/abc123');
      final b = SourceLinkService.normalizeForComparison('https://youtu.be/xyz789');

      expect(a, isNot(equals(b)));
    });

    test('tracking params are stripped before comparing', () {
      final a = SourceLinkService.normalizeForComparison(
        'https://example.com/post/42?utm_source=twitter&utm_campaign=share',
      );
      final b = SourceLinkService.normalizeForComparison('https://example.com/post/42');

      expect(a, equals(b));
    });

    test('non-tracking query params are NOT stripped (still distinguish content)', () {
      final a = SourceLinkService.normalizeForComparison('https://example.com/post?id=1');
      final b = SourceLinkService.normalizeForComparison('https://example.com/post?id=2');

      expect(a, isNot(equals(b)));
    });

    test('trailing slash does not create a false mismatch', () {
      final a = SourceLinkService.normalizeForComparison('https://example.com/post/42/');
      final b = SourceLinkService.normalizeForComparison('https://example.com/post/42');

      expect(a, equals(b));
    });

    test('empty string is handled without throwing', () {
      expect(SourceLinkService.normalizeForComparison(''), equals(''));
    });

    test('a malformed URL does not throw, and still normalizes case', () {
      final result = SourceLinkService.normalizeForComparison('Not A Real URL');
      expect(result, equals('not a real url'));
    });
  });
}
