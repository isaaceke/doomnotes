import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/note.dart';
import '../main.dart';

class ExportImportService {
  Future<String> exportAllNotesToJson() async {
    // Trashed notes are excluded on purpose: they're on their way out, and
    // re-importing them elsewhere would resurrect notes the user already
    // asked to delete.
    final notes = await isarDb.collection<Note>().filter().isDeletedEqualTo(false).findAll();

    final jsonList = notes.map((note) {
      return {
        'id': note.id,
        'topic': note.topic,
        'summary': note.summary,
        'transcript': note.transcript,
        'videoUrl': note.videoUrl,
        'keywords': note.keywords,
        'isArchived': note.isArchived,
        'isFavorite': note.isFavorite,
        'createdAt': note.createdAt.toIso8601String(),
      };
    }).toList();

    final json = const JsonEncoder.withIndent('  ').convert(jsonList);

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/doomnotes_export_${DateTime.now().millisecondsSinceEpoch}.json');
    await file.writeAsString(json);

    return file.path;
  }

  Future<String> exportAllNotesToMarkdown() async {
    final notes = await isarDb.collection<Note>().filter().isDeletedEqualTo(false).findAll();
    final byTopic = <String, List<Note>>{};
    for (final n in notes) {
      byTopic.putIfAbsent(n.topic.isEmpty ? 'Unsorted' : n.topic, () => []).add(n);
    }

    final buffer = StringBuffer('# DoomNotes export\n\n');
    buffer.writeln('_${notes.length} notes, exported ${DateTime.now().toLocal()}_\n');

    for (final topic in byTopic.keys.toList()..sort()) {
      buffer.writeln('## $topic\n');
      for (final note in byTopic[topic]!) {
        final title = note.summary?.isNotEmpty == true ? note.summary! : 'Untitled note';
        buffer.writeln('### $title');
        if (note.videoUrl.isNotEmpty) buffer.writeln('${note.videoUrl}\n');
        if (note.transcript.isNotEmpty) buffer.writeln('${note.transcript}\n');
        buffer.writeln('_Saved ${note.createdAt.toLocal()}_\n');
      }
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/doomnotes_export_${DateTime.now().millisecondsSinceEpoch}.md');
    await file.writeAsString(buffer.toString());
    return file.path;
  }

  Future<String> exportAllNotesToText() async {
    final notes = await isarDb.collection<Note>().filter().isDeletedEqualTo(false).findAll();
    final byTopic = <String, List<Note>>{};
    for (final n in notes) {
      byTopic.putIfAbsent(n.topic.isEmpty ? 'Unsorted' : n.topic, () => []).add(n);
    }

    final buffer = StringBuffer('DOOMNOTES EXPORT\n${'=' * 40}\n\n');
    for (final topic in byTopic.keys.toList()..sort()) {
      buffer.writeln(topic.toUpperCase());
      buffer.writeln('-' * topic.length);
      for (final note in byTopic[topic]!) {
        final title = note.summary?.isNotEmpty == true ? note.summary! : 'Untitled note';
        buffer.writeln('\n$title');
        if (note.videoUrl.isNotEmpty) buffer.writeln(note.videoUrl);
        if (note.transcript.isNotEmpty) buffer.writeln(note.transcript);
      }
      buffer.writeln();
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/doomnotes_export_${DateTime.now().millisecondsSinceEpoch}.txt');
    await file.writeAsString(buffer.toString());
    return file.path;
  }

  Future<int> importNotesFromJsonFile(String filePath) async {
    final file = File(filePath);
    final json = await file.readAsString();
    final List<dynamic> decoded = jsonDecode(json);

    int importedCount = 0;

    await isarDb.writeTxn(() async {
      for (final item in decoded) {
        try {
          final note = Note()
            // Deliberately NOT setting `id` here: letting Isar autoincrement
            // avoids colliding with an ID that already exists locally when
            // importing a backup taken from a different install.
            ..topic = item['topic'] as String
            ..summary = item['summary'] as String?
            ..transcript = item['transcript'] as String
            ..videoUrl = item['videoUrl'] as String? ?? ''
            ..keywords = List<String>.from(item['keywords'] as List<dynamic>? ?? [])
            ..isArchived = item['isArchived'] as bool? ?? false
            ..isFavorite = item['isFavorite'] as bool? ?? false
            ..createdAt = DateTime.parse(item['createdAt'] as String);

          await isarDb.collection<Note>().put(note);
          importedCount++;
        } catch (_) {
          // Skip invalid notes
        }
      }
    });

    return importedCount;
  }

  Future<int> pickAndImport() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result == null || result.files.single.path == null) return 0;

    return importNotesFromJsonFile(result.files.single.path!);
  }
}
