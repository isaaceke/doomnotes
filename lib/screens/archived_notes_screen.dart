import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import '../main.dart';
import '../services/note_repository.dart';
import '../models/note.dart';
import '../theme/doomnotes_theme.dart';
import '../widgets/note_list.dart';

class ArchivedNotesScreen extends StatelessWidget {
  const ArchivedNotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Archived')),
      body: NoteList(
        emptyMessage: 'No archived notes.\nArchive a note from its detail screen to hide it from Home without deleting it.',
        emptyIcon: Icons.archive_outlined,
        stream: isarDb.collection<Note>()
            .filter()
            .isArchivedEqualTo(true)
            .isDeletedEqualTo(false)
            .sortByCreatedAtDesc()
            .watch(fireImmediately: true),
        swipeActions: [
          NoteSwipeAction(
            direction: DismissDirection.startToEnd,
            icon: Icons.unarchive_rounded,
            label: 'Unarchive',
            color: DoomNotesTheme.mint,
            onTriggered: (note) async {
              note.isArchived = false;
              await saveNote(note);
              return true;
            },
          ),
        ],
      ),
    );
  }
}
