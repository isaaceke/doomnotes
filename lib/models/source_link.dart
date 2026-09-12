class SourceLink {
  final String url;
  final String? platform;
  final String? title;
  final String? thumbnailUrl;

  const SourceLink({
    required this.url,
    this.platform,
    this.title,
    this.thumbnailUrl,
  });

  factory SourceLink.fromRawUrl(String rawUrl) {
    String? platform;
    if (rawUrl.contains('tiktok.com')) {
      platform = 'TikTok';
    } else if (rawUrl.contains('instagram.com')) {
      platform = 'Instagram';
    } else if (rawUrl.contains('youtube.com') || rawUrl.contains('youtu.be')) {
      platform = 'YouTube';
    } else if (rawUrl.contains('x.com') || rawUrl.contains('twitter.com')) {
      platform = 'X';
    }

    return SourceLink(
      url: rawUrl,
      platform: platform,
      title: null,
      thumbnailUrl: null,
    );
  }

  bool get isVideo =>
      platform == 'TikTok' ||
      platform == 'YouTube' ||
      platform == 'Instagram';

  String get displayTitle =>
      title ?? (isVideo ? 'Watch $platform Video' : 'Open Link');
}