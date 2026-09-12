import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../services/export_import_service.dart';
import '../widgets/settings_section.dart';

class ExportImportScreen extends StatefulWidget {
  const ExportImportScreen({super.key});

  @override
  State<ExportImportScreen> createState() => _ExportImportScreenState();
}

class _ExportImportScreenState extends State<ExportImportScreen> {
  final _service = ExportImportService();
  bool _busy = false;

  Future<void> _export(Future<String> Function() exportFn, String label) async {
    setState(() => _busy = true);
    try {
      final path = await exportFn();
      if (!mounted) return;
      await Share.shareXFiles([XFile(path)], text: 'DoomNotes backup ($label)');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _doImport() async {
    setState(() => _busy = true);
    final count = await _service.pickAndImport();
    if (!mounted) return;
    setState(() => _busy = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(count > 0 ? '$count ${count == 1 ? 'note' : 'notes'} imported.' : 'No notes were imported.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Export / Import')),
      body: AbsorbPointer(
        absorbing: _busy,
        child: Opacity(
          opacity: _busy ? 0.5 : 1,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SettingsSection(
                title: 'Backup',
                children: [
                  SettingsTile(
                    icon: Icons.data_object_rounded,
                    title: 'Export as JSON',
                    subtitle: 'Full backup — re-importable into DoomNotes',
                    onTap: () => _export(_service.exportAllNotesToJson, 'JSON'),
                  ),
                  SettingsTile(
                    icon: Icons.description_outlined,
                    title: 'Export as Markdown',
                    subtitle: 'Readable file, grouped by topic',
                    onTap: () => _export(_service.exportAllNotesToMarkdown, 'Markdown'),
                  ),
                  SettingsTile(
                    icon: Icons.article_outlined,
                    title: 'Export as plain text',
                    subtitle: 'Simple .txt file, grouped by topic',
                    onTap: () => _export(_service.exportAllNotesToText, 'Text'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SettingsSection(
                title: 'Restore',
                children: [
                  SettingsTile(
                    icon: Icons.file_upload_rounded,
                    title: 'Import notes',
                    subtitle: 'Restore from a JSON backup file',
                    onTap: _doImport,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'How it works',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'JSON is the only format you can import back in — use it for '
                        'backups. Markdown and text exports are for reading or sharing '
                        'elsewhere; importing only reads JSON files. Notes in Trash are '
                        'never included in any export.',
                        style: TextStyle(height: 1.45),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
