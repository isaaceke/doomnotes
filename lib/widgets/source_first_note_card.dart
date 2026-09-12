import 'package:flutter/material.dart';
import '../models/source_platform.dart';
import '../theme/doomnotes_theme.dart';
import 'platform_pill.dart';
import 'source_action_button.dart';

class SourceFirstNoteCard extends StatelessWidget {
  final String topic;
  final String title;
  final String preview;
  final String sourceUrl;
  final DateTime createdAt;
  final List<String> matchedTerms;
  final String? thumbnailUrl;
  final List<InlineSpan>? previewSpans;
  final VoidCallback? onOpenNote;

  const SourceFirstNoteCard({
    super.key,
    required this.topic,
    required this.title,
    required this.preview,
    required this.sourceUrl,
    required this.createdAt,
    this.matchedTerms = const [],
    this.thumbnailUrl,
    this.previewSpans,
    this.onOpenNote,
  });

  String get _relativeTime {
    final difference = DateTime.now().difference(createdAt);

    if (difference.inMinutes < 1) return 'Saved just now';
    if (difference.inHours < 1) return 'Saved ${difference.inMinutes}m ago';
    if (difference.inDays < 1) return 'Saved ${difference.inHours}h ago';
    if (difference.inDays == 1) return 'Saved yesterday';
    if (difference.inDays < 7) return 'Saved ${difference.inDays}d ago';

    return 'Saved ${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final platform = SourcePlatformX.fromUrl(sourceUrl);

    return Card(
      child: InkWell(
        onTap: onOpenNote,
        borderRadius: BorderRadius.circular(DoomNotesTheme.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      topic.toUpperCase(),
                      style: TextStyle(
                        color: DoomNotesTheme.violet,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  PlatformPill(platform: platform, compact: true),
                ],
              ),
              const SizedBox(height: 12),
              if (thumbnailUrl != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(DoomNotesTheme.radiusSmall),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      thumbnailUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      loadingBuilder: (context, child, progress) =>
                          progress == null ? child : const SizedBox.shrink(),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 18,
                      height: 1.2,
                    ),
              ),
              const SizedBox(height: 8),
              previewSpans != null
                  ? RichText(
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodySmall,
                        children: previewSpans,
                      ),
                    )
                  : Text(
                      preview,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
              if (matchedTerms.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: matchedTerms.take(4).map((term) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: DoomNotesTheme.violetSoft,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        term,
                        style: TextStyle(
                          color: DoomNotesTheme.violet,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 16),
              if (sourceUrl.isNotEmpty)
                SourceActionButton(
                  url: sourceUrl,
                  platform: platform,
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.bookmark_added_outlined,
                    size: 15,
                    color: DoomNotesTheme.muted,
                  ),
                  const SizedBox(width: 6),
                  Text(_relativeTime, style: Theme.of(context).textTheme.bodySmall),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: DoomNotesTheme.muted,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}