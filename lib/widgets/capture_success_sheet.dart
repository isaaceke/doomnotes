import 'package:flutter/material.dart';
import '../models/source_platform.dart';
import '../theme/doomnotes_theme.dart';
import 'platform_pill.dart';
import 'source_action_button.dart';

class CaptureSuccessSheet extends StatelessWidget {
  final String topic;
  final String title;
  final String sourceUrl;

  const CaptureSuccessSheet({
    super.key,
    required this.topic,
    required this.title,
    required this.sourceUrl,
  });

  static Future<void> show(
    BuildContext context, {
    required String topic,
    required String title,
    required String sourceUrl,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CaptureSuccessSheet(
        topic: topic,
        title: title,
        sourceUrl: sourceUrl,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final platform = SourcePlatformX.fromUrl(sourceUrl);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
      decoration: BoxDecoration(
        color: DoomNotesTheme.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(DoomNotesTheme.radiusLarge),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: DoomNotesTheme.border,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: Color(0xFFE1F8F1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_rounded,
                color: DoomNotesTheme.mint,
                size: 34,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Saved to $topic',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            PlatformPill(platform: platform),
            if (sourceUrl.isNotEmpty) ...[
              const SizedBox(height: 20),
              SourceActionButton(
                url: sourceUrl,
                platform: platform,
              ),
            ],
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }
}