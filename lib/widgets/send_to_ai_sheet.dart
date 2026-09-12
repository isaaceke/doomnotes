import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/note.dart';
import '../theme/doomnotes_theme.dart';

/// Starter prompts. These just prefix the shared text — nothing app-specific.
const _promptTemplates = <String, String>{
  'Summarize': 'Summarize this for me:',
  'Explain simply': 'Explain this like I\'m new to the topic:',
  'Key takeaways': 'What are the key takeaways from this?',
  'Just the content': '',
};

/// Bottom sheet for sending a note's content to whichever AI chat app the
/// person picks from the OS share sheet (ChatGPT, Gemini, Claude, Grok,
/// Perplexity, or anything else that accepts shared text).
///
/// Deliberately does NOT try to deep-link a specific named app by hardcoding
/// its package name — that can't be verified without a real device and
/// would be exactly the kind of unverified native-integration guess this
/// project already had too much of. The standard share sheet already
/// solves this: any installed app that registers as a text share target
/// (ChatGPT, Gemini, Claude, and Perplexity are all confirmed to) shows up
/// automatically.
class SendToAiSheet extends StatefulWidget {
  final Note note;

  const SendToAiSheet({super.key, required this.note});

  static Future<void> show(BuildContext context, Note note) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => SendToAiSheet(note: note),
    );
  }

  @override
  State<SendToAiSheet> createState() => _SendToAiSheetState();
}

class _SendToAiSheetState extends State<SendToAiSheet> {
  String _selectedTemplate = 'Summarize';
  late final TextEditingController _promptController;

  @override
  void initState() {
    super.initState();
    _promptController = TextEditingController(text: _promptTemplates[_selectedTemplate]);
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  String _buildMessage() {
    final note = widget.note;
    final buffer = StringBuffer();

    final prompt = _promptController.text.trim();
    if (prompt.isNotEmpty) buffer.writeln('$prompt\n');

    if (note.summary?.isNotEmpty == true) buffer.writeln(note.summary);
    if (note.transcript.isNotEmpty) buffer.writeln(note.transcript);
    if (note.videoUrl.isNotEmpty) buffer.writeln('\nSource: ${note.videoUrl}');

    return buffer.toString().trim();
  }

  Future<void> _send() async {
    Navigator.pop(context);
    await Share.share(_buildMessage());
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.smart_toy_outlined, color: DoomNotesTheme.violet),
              const SizedBox(width: 8),
              Text('Send to AI chat', style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Opens your share menu — pick ChatGPT, Gemini, Claude, Grok, Perplexity, '
            'or anything else installed that accepts shared text.',
            style: TextStyle(color: DoomNotesTheme.muted, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _promptTemplates.keys.map((label) {
              return ChoiceChip(
                label: Text(label),
                selected: _selectedTemplate == label,
                onSelected: (_) => setState(() {
                  _selectedTemplate = label;
                  _promptController.text = _promptTemplates[label]!;
                }),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _promptController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Prompt (optional — edit or clear it)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _send,
              icon: const Icon(Icons.send_rounded),
              label: const Text('Send'),
            ),
          ),
        ],
      ),
    );
  }
}
