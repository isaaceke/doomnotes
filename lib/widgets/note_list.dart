import 'package:flutter/material.dart';
import '../models/note.dart';
import '../screens/note_detail_screen.dart';
import '../theme/doomnotes_theme.dart';
import 'source_first_note_card.dart';

/// One swipe action shown behind a note card (e.g. "Archive", "Restore").
class NoteSwipeAction {
  final DismissDirection direction;
  final IconData icon;
  final String label;
  final Color color;
  final Future<bool> Function(Note note) onTriggered;

  const NoteSwipeAction({
    required this.direction,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTriggered,
  });
}

/// Renders a live-updating list of notes as [SourceFirstNoteCard]s, with
/// optional swipe gestures (archive / restore / delete-forever, depending
/// on which screen is using it) and a shared empty state.
class NoteList extends StatelessWidget {
  final Stream<List<Note>> stream;
  final String emptyMessage;
  final IconData emptyIcon;
  final List<NoteSwipeAction> swipeActions;

  const NoteList({
    super.key,
    required this.stream,
    required this.emptyMessage,
    this.emptyIcon = Icons.inbox_rounded,
    this.swipeActions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Note>>(
      stream: stream,
      builder: (context, snapshot) {
        final notes = snapshot.data ?? const <Note>[];

        if (notes.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(emptyIcon, size: 40, color: DoomNotesTheme.muted),
                  const SizedBox(height: 12),
                  Text(
                    emptyMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: DoomNotesTheme.muted),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: notes.length,
          itemBuilder: (context, index) {
            final note = notes[index];
            final card = Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SourceFirstNoteCard(
                topic: note.topic,
                title: note.summary?.isNotEmpty == true
                    ? note.summary!
                    : (note.transcript.isNotEmpty ? note.transcript : 'Untitled note'),
                preview: note.transcript,
                sourceUrl: note.videoUrl,
                createdAt: note.createdAt,
                onOpenNote: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => NoteDetailScreen(note: note)),
                ),
              ),
            );

            if (swipeActions.isEmpty) return card;

            return Dismissible(
              key: ValueKey(note.id),
              direction: swipeActions.length > 1
                  ? DismissDirection.horizontal
                  : swipeActions.first.direction,
              background: _swipeBackground(context, swipeActions, forStart: true),
              secondaryBackground: swipeActions.length > 1
                  ? _swipeBackground(context, swipeActions, forStart: false)
                  : null,
              confirmDismiss: (direction) async {
                final action = swipeActions.firstWhere(
                  (a) => a.direction == direction || a.direction == DismissDirection.horizontal,
                  orElse: () => swipeActions.first,
                );
                return action.onTriggered(note);
              },
              child: card,
            );
          },
        );
      },
    );
  }

  Widget _swipeBackground(BuildContext context, List<NoteSwipeAction> actions, {required bool forStart}) {
    final action = forStart ? actions.first : actions.last;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: action.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(DoomNotesTheme.radiusMedium),
      ),
      alignment: forStart ? Alignment.centerLeft : Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(action.icon, color: action.color),
          Text(action.label, style: TextStyle(color: action.color, fontSize: 11, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
