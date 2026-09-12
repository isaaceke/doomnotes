import 'package:flutter/material.dart';
import '../theme/doomnotes_theme.dart';

class HowToShareScreen extends StatelessWidget {
  const HowToShareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('How to share'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _stepCard(
            context,
            step: 1,
            title: 'Open a video or post',
            subtitle: 'TikTok, YouTube, Instagram, X, or any link you want to save.',
            icon: Icons.play_circle_outline_rounded,
            accent: DoomNotesTheme.violet,
          ),
          _stepCard(
            context,
            step: 2,
            title: 'Tap Share',
            subtitle: 'Use the native share button on the video or post.',
            icon: Icons.share_rounded,
            accent: DoomNotesTheme.mint,
          ),
          _stepCard(
            context,
            step: 3,
            title: 'Choose DoomNotes',
            subtitle: 'Select DoomNotes from the share sheet. We will capture the text and link.',
            icon: Icons.bookmark_add_outlined,
            accent: DoomNotesTheme.amber,
          ),
          _stepCard(
            context,
            step: 4,
            title: 'Confirm topic or create a new one',
            subtitle: 'We suggest a topic based on what you shared. You can change it anytime.',
            icon: Icons.folder_rounded,
            accent: DoomNotesTheme.rose,
          ),
          _stepCard(
            context,
            step: 5,
            title: 'Find it later and open the source',
            subtitle: 'Search your library and tap “Watch video” or “Open post” to return to the original.',
            icon: Icons.open_in_new_rounded,
            accent: DoomNotesTheme.blue,
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tip',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'You can share multiple items in a row. DoomNotes will queue them and let you organize each one by topic.',
                    style: TextStyle(height: 1.45),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepCard(
    BuildContext context, {
    required int step,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accent,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Step $step',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: DoomNotesTheme.muted,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}