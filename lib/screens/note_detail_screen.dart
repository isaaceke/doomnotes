import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:isar/isar.dart';
import '../main.dart';
import '../models/note.dart';
import '../models/source_platform.dart';
import '../models/summarization_result.dart';
import '../services/ai_summary_service.dart';
import '../services/note_repository.dart';
import '../theme/doomnotes_theme.dart';
import '../widgets/ai_summary_card.dart';
import '../widgets/platform_pill.dart';
import '../widgets/send_to_ai_sheet.dart';
import '../widgets/source_action_button.dart';

class NoteDetailScreen extends StatefulWidget {
  final Note note;

  const NoteDetailScreen({super.key, required this.note});

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  final _aiSummaryService = AiSummaryService();
  SummarizationResult? _cleanedResult;
  bool _isCleaning = false;
  bool _editing = false;

  late TextEditingController _titleController;
  late TextEditingController _bodyController;
  late String _selectedTopic;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.summary ?? '');
    _bodyController = TextEditingController(text: widget.note.transcript);
    _selectedTopic = widget.note.topic.isEmpty ? 'Unsorted' : widget.note.topic;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _save(Note note) async {
    await saveNote(note);
  }

  Future<void> _toggleFavorite() async {
    setState(() => widget.note.isFavorite = !widget.note.isFavorite);
    await _save(widget.note);
  }

  Future<void> _toggleArchive() async {
    widget.note.isArchived = !widget.note.isArchived;
    await _save(widget.note);
    if (mounted) Navigator.pop(context, true);
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Move to Trash?'),
        content: const Text('You can restore it from Trash later. The original post is untouched either way.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Move to Trash')),
        ],
      ),
    );

    if (confirmed != true) return;

    widget.note
      ..isDeleted = true
      ..deletedAt = DateTime.now();
    await _save(widget.note);

    if (mounted) Navigator.pop(context, true);
  }

  Future<void> _cleanNote() async {
    if (widget.note.transcript.trim().isEmpty) return;

    setState(() => _isCleaning = true);
    final result = await _aiSummaryService.summarize(widget.note.transcript);
    if (!mounted) return;
    setState(() {
      _cleanedResult = result;
      _isCleaning = false;
    });
  }

  void _shareNote() {
    final buffer = StringBuffer()
      ..writeln(widget.note.summary?.isNotEmpty == true ? widget.note.summary : widget.note.topic)
      ..writeln();
    if (widget.note.videoUrl.isNotEmpty) buffer.writeln(widget.note.videoUrl);
    Share.share(buffer.toString().trim());
  }

  Future<void> _copyToClipboard() async {
    final buffer = StringBuffer()
      ..writeln(widget.note.summary?.isNotEmpty == true ? widget.note.summary : widget.note.topic);
    if (widget.note.transcript.isNotEmpty) buffer.writeln(widget.note.transcript);
    if (widget.note.videoUrl.isNotEmpty) buffer.writeln(widget.note.videoUrl);
    await Clipboard.setData(ClipboardData(text: buffer.toString().trim()));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Copied to clipboard')),
      );
    }
  }

  void _startEditing() {
    setState(() {
      _titleController.text = widget.note.summary ?? '';
      _bodyController.text = widget.note.transcript;
      _selectedTopic = widget.note.topic.isEmpty ? 'Unsorted' : widget.note.topic;
      _editing = true;
    });
  }

  Future<void> _saveEdits() async {
    widget.note
      ..summary = _titleController.text.trim()
      ..transcript = _bodyController.text.trim()
      ..topic = _selectedTopic;
    await _save(widget.note);
    if (mounted) setState(() => _editing = false);
  }

  Future<void> _pickTopic() async {
    final existingTopics = {
      ...topicService.allTopics.map((t) => t.label),
      'Unsorted',
    }.toList()
      ..sort();

    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        final customController = TextEditingController();
        return Padding(
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
              Text('Move to topic', style: Theme.of(sheetContext).textTheme.titleLarge),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 280),
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: existingTopics.map((t) {
                      return ChoiceChip(
                        label: Text(t),
                        selected: t == _selectedTopic,
                        onSelected: (_) => Navigator.pop(sheetContext, t),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: customController,
                      decoration: const InputDecoration(
                        hintText: 'Or type a new topic name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () {
                      final custom = customController.text.trim();
                      if (custom.isNotEmpty) Navigator.pop(sheetContext, custom);
                    },
                    child: const Text('Use'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      setState(() => _selectedTopic = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final note = widget.note;
    final platform = SourcePlatformX.fromUrl(note.videoUrl);
    final thumbnailUrl = SourcePlatformX.youtubeThumbnailUrl(note.videoUrl);
    final title = note.summary?.isNotEmpty == true
        ? note.summary!
        : (note.transcript.isNotEmpty ? note.transcript : 'Untitled note');

    return Scaffold(
      appBar: AppBar(
        title: Text(_editing ? 'Edit note' : note.topic),
        actions: _editing
            ? [
                TextButton(
                  onPressed: () => setState(() => _editing = false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: _saveEdits,
                  child: const Text('Save'),
                ),
              ]
            : [
                IconButton(
                  icon: Icon(note.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded),
                  color: note.isFavorite ? DoomNotesTheme.rose : null,
                  tooltip: note.isFavorite ? 'Unfavorite' : 'Favorite',
                  onPressed: _toggleFavorite,
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit',
                  onPressed: _startEditing,
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'archive':
                        _toggleArchive();
                        break;
                      case 'delete':
                        _delete();
                        break;
                      case 'share':
                        _shareNote();
                        break;
                      case 'copy':
                        _copyToClipboard();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'archive',
                      child: Text(note.isArchived ? 'Unarchive' : 'Archive'),
                    ),
                    const PopupMenuItem(value: 'copy', child: Text('Copy text')),
                    const PopupMenuItem(value: 'share', child: Text('Share')),
                    const PopupMenuItem(value: 'delete', child: Text('Move to Trash')),
                  ],
                ),
              ],
      ),
      body: _editing ? _buildEditBody(context) : _buildViewBody(context, note, platform, thumbnailUrl, title),
    );
  }

  Widget _buildEditBody(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Topic', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _pickTopic,
          icon: const Icon(Icons.folder_outlined),
          label: Text(_selectedTopic),
        ),
        const SizedBox(height: 20),
        Text('Title', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        TextField(
          controller: _titleController,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        const SizedBox(height: 20),
        Text('Saved text', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        TextField(
          controller: _bodyController,
          maxLines: 10,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
      ],
    );
  }

  Widget _buildViewBody(
    BuildContext context,
    Note note,
    SourcePlatform platform,
    String? thumbnailUrl,
    String title,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        PlatformPill(platform: platform),
        const SizedBox(height: 14),
        if (thumbnailUrl != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(DoomNotesTheme.radiusMedium),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                thumbnailUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ),
          const SizedBox(height: 14),
        ],
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        if (note.videoUrl.isNotEmpty) ...[
          SourceActionButton(url: note.videoUrl, platform: platform),
          const SizedBox(height: 20),
        ],
        Row(
          children: [
            if (_cleanedResult == null)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isCleaning ? null : _cleanNote,
                  icon: _isCleaning
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.cleaning_services_outlined),
                  label: Text(_isCleaning ? 'Cleaning…' : 'Clean note'),
                ),
              ),
            if (_cleanedResult == null) const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => SendToAiSheet.show(context, note),
                icon: const Icon(Icons.smart_toy_outlined),
                label: const Text('Send to AI'),
              ),
            ),
          ],
        ),
        if (_cleanedResult != null) ...[
          const SizedBox(height: 12),
          AiSummaryCard(
            result: _cleanedResult!,
            onDismiss: () => setState(() => _cleanedResult = null),
          ),
        ],
        const SizedBox(height: 20),
        Row(
          children: [
            Text('Saved text', style: Theme.of(context).textTheme.titleMedium),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.copy_rounded, size: 20),
              tooltip: 'Copy',
              onPressed: _copyToClipboard,
            ),
          ],
        ),
        const SizedBox(height: 4),
        SelectableText(
          note.transcript.isNotEmpty ? note.transcript : 'No text was captured with this save.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
