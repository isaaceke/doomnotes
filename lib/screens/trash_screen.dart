import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import '../main.dart';
import '../models/note.dart';
import '../services/note_repository.dart';
import '../theme/doomnotes_theme.dart';
import '../widgets/note_list.dart';

class TrashScreen extends StatelessWidget {
  const TrashScreen({super.key});

  Future<bool> _confirmPermanentDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete forever?'),
        content: const Text('This can\'t be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete forever')),
        ],
      ),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trash'),
        actions: [
          TextButton(
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Empty Trash?'),
                  content: const Text('All notes in Trash will be permanently deleted.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                    FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Empty Trash')),
                  ],
                ),
              );
              if (confirmed != true) return;
              final trashed = await isarDb.collection<Note>().filter().isDeletedEqualTo(true).findAll();
              for (final n in trashed) {
                await permanentlyDeleteNote(n);
              }
            },
            child: const Text('Empty'),
          ),
        ],
      ),
      body: NoteList(
        emptyMessage: 'Trash is empty.\nDeleted notes stay here until you empty the trash.',
        emptyIcon: Icons.delete_outline_rounded,
        stream: isarDb.collection<Note>()
            .filter()
            .isDeletedEqualTo(true)
            .sortByDeletedAtDesc()
            .watch(fireImmediately: true),
        swipeActions: [
          NoteSwipeAction(
            direction: DismissDirection.startToEnd,
            icon: Icons.restore_rounded,
            label: 'Restore',
            color: DoomNotesTheme.mint,
            onTriggered: (note) async {
              await restoreNote(note);
              return true;
            },
          ),
          NoteSwipeAction(
            direction: DismissDirection.endToStart,
            icon: Icons.delete_forever_rounded,
            label: 'Delete forever',
            color: DoomNotesTheme.rose,
            onTriggered: (note) async {
              final confirmed = await _confirmPermanentDelete(context);
              if (!confirmed) return false;
              await permanentlyDeleteNote(note);
              return true;
            },
          ),
        ],
      ),
    );
  }
}
