import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import '../main.dart';
import '../services/note_repository.dart';
import '../models/note.dart';
import '../theme/doomnotes_theme.dart';
import '../widgets/note_list.dart';

enum _TopicSort { newest, oldest, alphabetical }

/// Shows every saved note inside a single topic folder.
class TopicNotesScreen extends StatefulWidget {
  final String topic;

  const TopicNotesScreen({super.key, required this.topic});

  @override
  State<TopicNotesScreen> createState() => _TopicNotesScreenState();
}

class _TopicNotesScreenState extends State<TopicNotesScreen> {
  _TopicSort _sort = _TopicSort.newest;

  Stream<List<Note>> _buildStream() {
    final base = isarDb.collection<Note>()
        .filter()
        .topicEqualTo(widget.topic)
        .isArchivedEqualTo(false)
        .isDeletedEqualTo(false);

    switch (_sort) {
      case _TopicSort.newest:
        return base.sortByCreatedAtDesc().watch(fireImmediately: true);
      case _TopicSort.oldest:
        return base.sortByCreatedAt().watch(fireImmediately: true);
      case _TopicSort.alphabetical:
        return base.sortBySummary().watch(fireImmediately: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.topic),
        actions: [
          PopupMenuButton<_TopicSort>(
            icon: const Icon(Icons.sort_rounded),
            tooltip: 'Sort notes',
            initialValue: _sort,
            onSelected: (order) => setState(() => _sort = order),
            itemBuilder: (context) => const [
              PopupMenuItem(value: _TopicSort.newest, child: Text('Newest first')),
              PopupMenuItem(value: _TopicSort.oldest, child: Text('Oldest first')),
              PopupMenuItem(value: _TopicSort.alphabetical, child: Text('A to Z')),
            ],
          ),
        ],
      ),
      body: NoteList(
        stream: _buildStream(),
        emptyMessage: 'No saved items in this topic yet.',
        swipeActions: [
          NoteSwipeAction(
            direction: DismissDirection.endToStart,
            icon: Icons.archive_rounded,
            label: 'Archive',
            color: DoomNotesTheme.amber,
            onTriggered: (note) async {
              note.isArchived = true;
              await saveNote(note);
              return true;
            },
          ),
        ],
      ),
    );
  }
}
