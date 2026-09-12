import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:isar/isar.dart';
import '../main.dart';
import '../models/note.dart';
import '../models/source_platform.dart';
import '../services/share_capture_service.dart';
import '../theme/doomnotes_theme.dart';
import '../widgets/capture_success_sheet.dart';
import '../widgets/empty_notes_state.dart';
import '../widgets/topic_folder_card.dart';
import 'archived_notes_screen.dart';
import 'favorites_screen.dart';
import 'how_to_share_screen.dart';
import 'note_detail_screen.dart';
import 'settings_screen.dart';
import 'smart_search_screen.dart';
import 'topic_notes_screen.dart';
import 'trash_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _accentIcons = [
    Icons.folder_rounded,
    Icons.local_fire_department_rounded,
    Icons.bolt_rounded,
    Icons.star_rounded,
    Icons.bookmark_rounded,
  ];

  /// A topic's icon should be a stable identity, not incidental to where
  /// it lands in a list sorted by note count — otherwise "Fitness" could
  /// visibly change icon between app opens just because you saved one
  /// more "Cooking" note than before. Hash the name instead of using
  /// list position.
  static int _stableIndex(String topic, int rangeLength) =>
      topic.hashCode.abs() % rangeLength;

  StreamSubscription<CaptureResult>? _captureSub;

  @override
  void initState() {
    super.initState();
    _captureSub = shareCaptureService.events.listen((result) {
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      CaptureSuccessSheet.show(
        context,
        topic: result.note.topic,
        title: result.wasUpdate ? 'Updated existing note' : (result.note.summary ?? 'Saved'),
        sourceUrl: result.note.videoUrl,
      );
    });
  }

  @override
  void dispose() {
    _captureSub?.cancel();
    super.dispose();
  }

  Future<void> _addLinkManually(BuildContext context) async {
    final controller = TextEditingController();

    final text = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add a link', style: Theme.of(sheetContext).textTheme.titleLarge),
            const SizedBox(height: 4),
            const Text(
              'Paste a TikTok, YouTube, Instagram, or other link. '
              'This is a manual fallback — sharing directly from those apps '
              'works too, once the share extension is set up.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'https://... (optionally add a caption above it)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(sheetContext, controller.text.trim()),
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );

    if (text == null || text.isEmpty) return;
    await shareCaptureService.captureText(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DoomNotes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            tooltip: 'Search',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SmartSearchScreen()),
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (value) {
              final screen = switch (value) {
                'archived' => const ArchivedNotesScreen(),
                'trash' => const TrashScreen(),
                _ => null,
              };
              if (screen != null) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'archived', child: Text('Archived')),
              PopupMenuItem(value: 'trash', child: Text('Trash')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addLinkManually(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add link'),
      ),
      body: StreamBuilder<List<Note>>(
        stream: isarDb.collection<Note>()
            .filter()
            .isArchivedEqualTo(false)
            .isDeletedEqualTo(false)
            .watch(fireImmediately: true),
        builder: (context, snapshot) {
          final notes = snapshot.data ?? const <Note>[];

          if (notes.isEmpty) {
            return EmptyNotesState(
              title: 'Nothing saved yet',
              subtitle: 'Share a video or post here from TikTok, YouTube, '
                  'or Instagram, or tap "Add link" below to save your first item.',
              icon: Icons.inbox_rounded,
              actionLabel: 'How sharing works',
              onAction: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HowToShareScreen()),
              ),
            );
          }

          final favoriteCount = notes.where((n) => n.isFavorite).length;

          final recent = [...notes]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
          final recentItems = recent.take(6).toList();

          final byTopic = <String, List<Note>>{};
          for (final note in notes) {
            final key = note.topic.isEmpty ? 'Unsorted' : note.topic;
            byTopic.putIfAbsent(key, () => []).add(note);
          }
          final topics = byTopic.keys.toList()
            ..sort((a, b) {
              if (a == 'Unsorted') return 1;
              if (b == 'Unsorted') return -1;
              return byTopic[b]!.length.compareTo(byTopic[a]!.length);
            });

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
            children: [
              if (favoriteCount > 0) ...[
                _FavoritesShortcut(
                  count: favoriteCount,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FavoritesScreen()),
                  ),
                ),
                const SizedBox(height: 20),
              ],
              Text('Recently added', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              SizedBox(
                height: 96,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: recentItems.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final note = recentItems[index];
                    return _RecentNoteTile(
                      note: note,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => NoteDetailScreen(note: note)),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              Text('Topics', style: Theme.of(context).textTheme.titleMedium),
              Column(
                children: [
                  for (int index = 0; index < topics.length; index++) ...[
                    if (index > 0) Divider(height: 1, color: DoomNotesTheme.border),
                    TopicFolderCard(
                      title: topics[index],
                      itemCount: byTopic[topics[index]]!.length,
                      icon: _accentIcons[_stableIndex(topics[index], _accentIcons.length)],
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => TopicNotesScreen(topic: topics[index])),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FavoritesShortcut extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const _FavoritesShortcut({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: DoomNotesTheme.rose.withOpacity(DoomNotesTheme.isDark ? 0.2 : 0.1),
      borderRadius: BorderRadius.circular(DoomNotesTheme.radiusMedium),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DoomNotesTheme.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(Icons.favorite_rounded, color: DoomNotesTheme.rose),
              const SizedBox(width: 12),
              Text(
                'Favorites',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              Text('$count', style: TextStyle(color: DoomNotesTheme.rose, fontWeight: FontWeight.w800)),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded, color: DoomNotesTheme.muted),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentNoteTile extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;

  const _RecentNoteTile({required this.note, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final platform = SourcePlatformX.fromUrl(note.videoUrl);
    final title = note.summary?.isNotEmpty == true
        ? note.summary!
        : (note.transcript.isNotEmpty ? note.transcript : 'Untitled note');

    return Material(
      color: DoomNotesTheme.surface,
      borderRadius: BorderRadius.circular(DoomNotesTheme.radiusMedium),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DoomNotesTheme.radiusMedium),
        child: Container(
          width: 180,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(DoomNotesTheme.radiusMedium),
            border: Border.all(color: DoomNotesTheme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(platform.icon, size: 14, color: platform.displayColor),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      note.topic,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: DoomNotesTheme.muted),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Expanded(
                child: Text(
                  title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
