import '../models/source_link.dart';

class SourceLinkService {
  SourceLink? extractFromSharedText(String sharedText) {
    final urlRegex = RegExp(
      r'https?://[^\s<>"{}|\\^`\[\]]+',
      caseSensitive: false,
    );

    final matches = urlRegex.allMatches(sharedText);
    if (matches.isEmpty) return null;

    final url = matches.first.group(0)!;
    return SourceLink.fromRawUrl(url);
  }

  String? extractVideoTitle(String sharedText) {
    final lines = sharedText
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .toList();

    if (lines.isEmpty) return null;

    final firstLine = lines.first.trim();
    if (firstLine.length < 120 && !firstLine.startsWith('http')) {
      return firstLine;
    }

    return null;
  }

  /// Canonical form of a URL used only for duplicate-detection comparisons
  /// (see share_capture_service.dart) — never used for display or for
  /// actually opening the link, so it's fine to be aggressive here.
  ///
  /// Handles the two things that would otherwise make the same video
  /// register as two different notes:
  /// - different URL shapes for the same video (youtu.be/<id>,
  ///   youtube.com/shorts/<id>, youtube.com/watch?v=<id> all become the
  ///   same key)
  /// - tracking junk appended to an otherwise-identical link (utm_*, si,
  ///   igshid, feature, share_app_id, and similar)
  static String normalizeForComparison(String url) {
    if (url.isEmpty) return '';

    final uri = Uri.tryParse(url.trim());
    if (uri == null) return url.trim().toLowerCase();

    final host = uri.host.toLowerCase().replaceFirst('www.', '');

    // Canonicalize YouTube's several URL shapes down to just the video ID.
    if (host.contains('youtube.com') || host.contains('youtu.be')) {
      String? videoId;
      if (host.contains('youtu.be')) {
        videoId = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
      } else if (uri.pathSegments.contains('shorts')) {
        final i = uri.pathSegments.indexOf('shorts');
        if (i + 1 < uri.pathSegments.length) videoId = uri.pathSegments[i + 1];
      } else {
        videoId = uri.queryParameters['v'];
      }
      if (videoId != null) return 'youtube:$videoId';
    }

    // For everything else: same host + path, with common tracking query
    // params stripped, is treated as the same content.
    const trackingKeys = {
      'utm_source', 'utm_medium', 'utm_campaign', 'utm_term', 'utm_content',
      'si', 'feature', 'igshid', 'igsh', 'share_app_id', 'sender_device',
      'is_from_webapp', 'source', '_r', 'referrer',
    };
    final keptParams = Map.fromEntries(
      uri.queryParameters.entries.where((e) => !trackingKeys.contains(e.key.toLowerCase())),
    );
    final path = uri.path.endsWith('/') && uri.path.length > 1
        ? uri.path.substring(0, uri.path.length - 1)
        : uri.path;

    final sortedParams = Map.fromEntries(
      keptParams.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );

    return '$host$path${sortedParams.isEmpty ? '' : '?${Uri(queryParameters: sortedParams).query}'}';
  }
}