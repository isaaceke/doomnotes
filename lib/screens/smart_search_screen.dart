import 'package:flutter/material.dart';
import '../models/note.dart';
import '../models/source_platform.dart';
import '../services/smart_search_service.dart';
import '../theme/doomnotes_theme.dart';
import '../widgets/source_first_note_card.dart';
import 'note_detail_screen.dart';

enum _SortOrder { relevance, newest, oldest, alphabetical, longest }

class SmartSearchScreen extends StatefulWidget {
  const SmartSearchScreen({super.key});

  @override
  State<SmartSearchScreen> createState() => _SmartSearchScreenState();
}

class _SmartSearchScreenState extends State<SmartSearchScreen> {
  final _controller = TextEditingController();
  final _searchService = SmartSearchService();
  List<Note> _results = [];
  String _lastQuery = '';
  _SortOrder _sort = _SortOrder.relevance;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _search() {
    final q = _controller.text.trim();
    setState(() => _lastQuery = q);

    if (q.isEmpty) {
      setState(() => _results = []);
      return;
    }

    _searchService.search(q).then((notes) {
      if (!mounted) return;
      setState(() => _results = _sorted(notes));
    });
  }

  List<Note> _sorted(List<Note> notes) {
    final list = [...notes];
    switch (_sort) {
      case _SortOrder.relevance:
        break; // already relevance-ordered by the search service
      case _SortOrder.newest:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case _SortOrder.oldest:
        list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case _SortOrder.alphabetical:
        list.sort((a, b) => (a.summary ?? a.transcript)
            .toLowerCase()
            .compareTo((b.summary ?? b.transcript).toLowerCase()));
        break;
      case _SortOrder.longest:
        list.sort((a, b) => b.transcript.length.compareTo(a.transcript.length));
        break;
    }
    return list;
  }

  List<String> _computeMatchChips(Note note) {
    if (_lastQuery.isEmpty) return [];

    final q = _lastQuery.toLowerCase();
    final chips = <String>[];

    if (note.topic.toLowerCase().contains(q)) {
      chips.add('Topic: ${note.topic}');
    }
    if ((note.summary ?? '').toLowerCase().contains(q)) {
      chips.add('Summary');
    }
    if (note.transcript.toLowerCase().contains(q)) {
      chips.add('Transcript');
    }

    return chips.take(3).toList();
  }

  /// Builds the preview text as spans with the matched query substring
  /// bolded/colored, so results actually show *why* they matched instead
  /// of just labeling which field matched.
  List<InlineSpan> _highlightedPreview(String text) {
    if (_lastQuery.isEmpty) return [TextSpan(text: text)];

    final lowerText = text.toLowerCase();
    final lowerQuery = _lastQuery.toLowerCase();
    final spans = <InlineSpan>[];
    int start = 0;

    while (true) {
      final index = lowerText.indexOf(lowerQuery, start);
      if (index == -1) {
        spans.add(TextSpan(text: text.substring(start)));
        break;
      }
      if (index > start) spans.add(TextSpan(text: text.substring(start, index)));
      spans.add(TextSpan(
        text: text.substring(index, index + lowerQuery.length),
        style: TextStyle(
          color: DoomNotesTheme.violet,
          fontWeight: FontWeight.w800,
          backgroundColor: DoomNotesTheme.violetSoft,
        ),
      ));
      start = index + lowerQuery.length;
    }

    return spans;
  }

  void _openNote(Note note) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => NoteDetailScreen(note: note)),
    );
    // Archiving/deleting a note from the detail screen won't remove it from
    // this list on its own, since search results are a one-off snapshot,
    // not a live Isar stream like Home/Topic/Favorites. Re-run the search
    // so the list reflects what's actually still there.
    if (changed == true) _search();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        actions: [
          if (_results.isNotEmpty)
            PopupMenuButton<_SortOrder>(
              icon: const Icon(Icons.sort_rounded),
              tooltip: 'Sort results',
              initialValue: _sort,
              onSelected: (order) => setState(() {
                _sort = order;
                _results = _sorted(_results);
              }),
              itemBuilder: (context) => const [
                PopupMenuItem(value: _SortOrder.relevance, child: Text('Best match')),
                PopupMenuItem(value: _SortOrder.newest, child: Text('Newest first')),
                PopupMenuItem(value: _SortOrder.oldest, child: Text('Oldest first')),
                PopupMenuItem(value: _SortOrder.alphabetical, child: Text('A to Z')),
                PopupMenuItem(value: _SortOrder.longest, child: Text('Longest first')),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _controller,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search notes (typos are okay)...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _search(),
            ),
          ),
          if (_lastQuery.isEmpty)
            const Expanded(
              child: Center(child: Text('Type to search your saved notes.')),
            )
          else if (_results.isEmpty)
            const Expanded(
              child: Center(child: Text('No notes found for this search.')),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _results.length,
                itemBuilder: (_, index) {
                  final note = _results[index];
                  final chips = _computeMatchChips(note);
                  final previewText = (note.transcript.isNotEmpty
                          ? note.transcript
                          : (note.summary ?? ''))
                      .replaceAll(RegExp(r'\s+'), ' ')
                      .trim();

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SourceFirstNoteCard(
                      topic: note.topic,
                      title: note.summary?.isNotEmpty == true
                          ? note.summary!
                          : (note.transcript.isNotEmpty ? note.transcript : 'Untitled note'),
                      preview: previewText,
                      previewSpans: _highlightedPreview(previewText),
                      sourceUrl: note.videoUrl,
                      createdAt: note.createdAt,
                      matchedTerms: chips,
                      thumbnailUrl: SourcePlatformX.youtubeThumbnailUrl(note.videoUrl),
                      onOpenNote: () => _openNote(note),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
