import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import '../main.dart';
import '../services/note_repository.dart';
import '../models/note.dart';
import '../theme/doomnotes_theme.dart';

class ManageTopicsScreen extends StatefulWidget {
  const ManageTopicsScreen({super.key});

  @override
  State<ManageTopicsScreen> createState() => _ManageTopicsScreenState();
}

class _ManageTopicsScreenState extends State<ManageTopicsScreen> {
  Future<Map<String, int>> _loadTopicCounts() async {
    final notes = await isarDb.collection<Note>()
        .filter()
        .isDeletedEqualTo(false)
        .findAll();

    final counts = <String, int>{};
    for (final note in notes) {
      final key = note.topic.isEmpty ? 'Unsorted' : note.topic;
      counts[key] = (counts[key] ?? 0) + 1;
    }
    return counts;
  }

  Future<void> _renameTopic(String oldName, int noteCount) async {
    final controller = TextEditingController(text: oldName);

    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Rename topic'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Renaming will move all $noteCount ${noteCount == 1 ? 'note' : 'notes'} in "$oldName".'),
            const SizedBox(height: 4),
            const Text(
              'If you rename it to a topic that already exists, they\'ll be merged together.',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('Rename'),
          ),
        ],
      ),
    );

    if (newName == null) return;
    final trimmedName = newName.trim();
    if (trimmedName.isEmpty || trimmedName == oldName) return;

    final affected = await isarDb.collection<Note>().filter().topicEqualTo(oldName).findAll();
    for (final note in affected) {
      note.topic = trimmedName;
      await saveNote(note);
    }
    await appPrefs.setTopicAlias(oldName, trimmedName);

    if (mounted) setState(() {});
  }

  Future<void> _deleteTopic(String topicName, int noteCount) async {
    if (topicName == 'Unsorted') return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete topic?'),
        content: Text(
          '$noteCount ${noteCount == 1 ? 'note' : 'notes'} in "$topicName" will move to Unsorted. '
          'The notes themselves are not deleted.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Delete topic')),
        ],
      ),
    );

    if (confirmed != true) return;

    final affected = await isarDb.collection<Note>().filter().topicEqualTo(topicName).findAll();
    for (final note in affected) {
      note.topic = 'Unsorted';
      await saveNote(note);
    }
    await appPrefs.setTopicAlias(topicName, 'Unsorted');

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage topics')),
      body: FutureBuilder<Map<String, int>>(
        future: _loadTopicCounts(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final topics = snapshot.data!.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          if (topics.isEmpty) {
            return const Center(child: Text('No topics yet — save something first.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: topics.length,
            separatorBuilder: (_, __) => const SizedBox(height: 4),
            itemBuilder: (context, index) {
              final entry = topics[index];
              return ListTile(
                title: Text(entry.key),
                subtitle: Text('${entry.value} ${entry.value == 1 ? 'note' : 'notes'}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit_outlined, color: DoomNotesTheme.muted),
                      tooltip: 'Rename',
                      onPressed: () => _renameTopic(entry.key, entry.value),
                    ),
                    if (entry.key != 'Unsorted')
                      IconButton(
                        icon: Icon(Icons.delete_outline_rounded, color: DoomNotesTheme.muted),
                        tooltip: 'Delete topic',
                        onPressed: () => _deleteTopic(entry.key, entry.value),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
