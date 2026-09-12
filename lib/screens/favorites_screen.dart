import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import '../main.dart';
import '../services/note_repository.dart';
import '../models/note.dart';
import '../theme/doomnotes_theme.dart';
import '../widgets/note_list.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: NoteList(
        emptyMessage: 'No favorites yet.\nTap the heart on any note to pin it here.',
        emptyIcon: Icons.favorite_border_rounded,
        stream: isarDb.collection<Note>()
            .filter()
            .isFavoriteEqualTo(true)
            .isDeletedEqualTo(false)
            .sortByCreatedAtDesc()
            .watch(fireImmediately: true),
        swipeActions: [
          NoteSwipeAction(
            direction: DismissDirection.startToEnd,
            icon: Icons.favorite_border_rounded,
            label: 'Unfavorite',
            color: DoomNotesTheme.rose,
            onTriggered: (note) async {
              note.isFavorite = false;
              await saveNote(note);
              return true;
            },
          ),
        ],
      ),
    );
  }
}
