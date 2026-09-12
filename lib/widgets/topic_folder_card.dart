import 'package:flutter/material.dart';
import '../theme/doomnotes_theme.dart';

/// A quiet list row for a topic folder — name, count, a small consistent
/// icon badge, and a chevron. Deliberately does NOT give every topic its
/// own color: assigning arbitrary colors to topics (by hash or otherwise)
/// makes color carry no actual meaning, and a folder is just "N notes" —
/// it doesn't need a colorful card to say that. Typography (the topic
/// name) and the count do the work instead.
class TopicFolderCard extends StatelessWidget {
  final String title;
  final int itemCount;
  final IconData icon;
  final VoidCallback? onTap;

  const TopicFolderCard({
    super.key,
    required this.title,
    required this.itemCount,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: DoomNotesTheme.violetSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: DoomNotesTheme.violet, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                    ),
                    Text(
                      '$itemCount ${itemCount == 1 ? 'note' : 'notes'}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: DoomNotesTheme.muted, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
