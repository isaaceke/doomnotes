import 'package:flutter/material.dart';
import '../models/summarization_result.dart';
import '../theme/doomnotes_theme.dart';

class AiSummaryCard extends StatelessWidget {
  final SummarizationResult result;
  final VoidCallback? onDismiss;

  const AiSummaryCard({
    super.key,
    required this.result,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DoomNotesTheme.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(DoomNotesTheme.radiusSmall),
        border: Border.all(color: DoomNotesTheme.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.cleaning_services_rounded, size: 16, color: DoomNotesTheme.blue),
              const SizedBox(width: 8),
              Text(
                'Cleaned summary',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: DoomNotesTheme.blue,
                ),
              ),
              const Spacer(),
              if (onDismiss != null)
                IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  onPressed: onDismiss,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 8),
          ...result.bulletPoints.map((bullet) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  bullet,
                  style: TextStyle(fontSize: 14, height: 1.4, color: DoomNotesTheme.ink),
                ),
              )),
        ],
      ),
    );
  }
}
