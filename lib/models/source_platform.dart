import 'package:flutter/material.dart';
import '../theme/doomnotes_theme.dart';

enum SourcePlatform {
  tiktok,
  youtube,
  instagram,
  x,
  facebook,
  linkedin,
  web,
  unknown,
}

extension SourcePlatformX on SourcePlatform {
  String get label {
    switch (this) {
      case SourcePlatform.tiktok:
        return 'TikTok';
      case SourcePlatform.youtube:
        return 'YouTube';
      case SourcePlatform.instagram:
        return 'Instagram';
      case SourcePlatform.x:
        return 'X';
      case SourcePlatform.facebook:
        return 'Facebook';
      case SourcePlatform.linkedin:
        return 'LinkedIn';
      case SourcePlatform.web:
        return 'Web link';
      case SourcePlatform.unknown:
        return 'Saved link';
    }
  }

  String get actionLabel {
    switch (this) {
      case SourcePlatform.tiktok:
      case SourcePlatform.youtube:
      case SourcePlatform.instagram:
      case SourcePlatform.facebook:
        return 'Watch video';
      case SourcePlatform.x:
      case SourcePlatform.linkedin:
        return 'Open post';
      default:
        return 'Open source';
    }
  }

  IconData get icon {
    switch (this) {
      case SourcePlatform.tiktok:
        return Icons.music_note_rounded;
      case SourcePlatform.youtube:
        return Icons.play_circle_fill_rounded;
      case SourcePlatform.instagram:
        return Icons.camera_alt_rounded;
      case SourcePlatform.x:
        return Icons.alternate_email_rounded;
      case SourcePlatform.facebook:
        return Icons.thumb_up_alt_rounded;
      case SourcePlatform.linkedin:
        return Icons.business_center_rounded;
      case SourcePlatform.web:
      case SourcePlatform.unknown:
        return Icons.link_rounded;
    }
  }

  Color get color {
    switch (this) {
      case SourcePlatform.tiktok:
        return const Color(0xFF14161F);
      case SourcePlatform.youtube:
        return const Color(0xFFE53935);
      case SourcePlatform.instagram:
        return const Color(0xFFC13584);
      case SourcePlatform.x:
        return const Color(0xFF14161F);
      case SourcePlatform.facebook:
        return const Color(0xFF1877F2);
      case SourcePlatform.linkedin:
        return const Color(0xFF0A66C2);
      case SourcePlatform.web:
      case SourcePlatform.unknown:
        return DoomNotesTheme.violet;
    }
  }

  static SourcePlatform fromUrl(String value) {
    final url = value.toLowerCase();

    if (url.contains('tiktok.com')) return SourcePlatform.tiktok;
    if (url.contains('youtube.com') || url.contains('youtu.be')) {
      return SourcePlatform.youtube;
    }
    if (url.contains('instagram.com')) return SourcePlatform.instagram;
    if (url.contains('twitter.com') || url.contains('x.com')) {
      return SourcePlatform.x;
    }
    if (url.contains('facebook.com') || url.contains('fb.watch')) {
      return SourcePlatform.facebook;
    }
    if (url.contains('linkedin.com')) return SourcePlatform.linkedin;
    if (url.startsWith('http')) return SourcePlatform.web;

    return SourcePlatform.unknown;
  }

  /// Same as [color], except TikTok/X's fixed near-black brand mark is
  /// flipped to near-white in dark mode so it's actually readable as an
  /// icon/text color against a dark surface. Use [color] instead when you
  /// need a fixed brand color for a solid-background button; use this for
  /// icon/text drawn directly on the app's surface (pills, tiles, etc).
  Color get displayColor {
    final isMonochromeBrand = this == SourcePlatform.tiktok || this == SourcePlatform.x;
    return isMonochromeBrand && DoomNotesTheme.isDark ? DoomNotesTheme.ink : color;
  }

  /// Public, unauthenticated YouTube thumbnail URL, or null if [url]
  /// isn't a recognizable YouTube link. TikTok and Instagram don't have an
  /// equivalent public thumbnail endpoint without their own API access, so
  /// there's intentionally no fallback for those — better to show nothing
  /// than a broken or fake image.
  static String? youtubeThumbnailUrl(String url) {
    final id = _youtubeVideoId(url);
    if (id == null) return null;
    return 'https://img.youtube.com/vi/$id/hqdefault.jpg';
  }

  static String? _youtubeVideoId(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;

    final host = uri.host.toLowerCase();
    if (host.contains('youtu.be')) {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
    }
    if (host.contains('youtube.com')) {
      if (uri.pathSegments.contains('shorts')) {
        final i = uri.pathSegments.indexOf('shorts');
        if (i + 1 < uri.pathSegments.length) return uri.pathSegments[i + 1];
      }
      return uri.queryParameters['v'];
    }
    return null;
  }
}