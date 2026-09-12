import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart';
import '../screens/lock_screen.dart';
import '../services/version_service.dart';
import '../theme/doomnotes_theme.dart';
import '../widgets/settings_section.dart';
import '../widgets/account_sync_tile.dart';
import 'archived_notes_screen.dart';
import 'export_import_screen.dart';
import 'favorites_screen.dart';
import 'how_to_share_screen.dart';
import 'manage_topics_screen.dart';
import 'trash_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _versionService = VersionService();

  bool _useAutomaticTopicMode = true;
  String _version = '';
  String _buildNumber = '';

  @override
  void initState() {
    super.initState();
    _useAutomaticTopicMode = appPrefs.useAutomaticTopicMode;
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await _versionService.loadAppVersion();
    if (!mounted) return;
    setState(() {
      _version = info['version'] ?? '';
      _buildNumber = info['buildNumber'] ?? '';
    });
  }

  Future<void> _toggleTopicMode(bool value) async {
    await appPrefs.setUseAutomaticTopicMode(value);
    setState(() => _useAutomaticTopicMode = value);
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await canLaunchUrl(uri)) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _push(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  String _autoLockLabel(int minutes) {
    if (minutes < 0) return 'Never (only on full close)';
    if (minutes == 0) return 'Immediately';
    return 'After $minutes ${minutes == 1 ? 'minute' : 'minutes'}';
  }

  Future<String?> _promptForPin(String title, String subtitle) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subtitle),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              autofocus: true,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(counterText: ''),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  Future<void> _enablePinLock() async {
    final pin = await _promptForPin('Set a PIN', 'Choose a 4–6 digit PIN.');
    if (pin == null || pin.length < 4) return;

    final confirm = await _promptForPin('Confirm PIN', 'Enter it again.');
    if (confirm != pin) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PINs didn\'t match — try again.')),
        );
      }
      return;
    }

    final recovery = await _promptForRecovery();
    if (recovery == null) return;

    final pinSalt = generatePinSalt();
    final answerSalt = generateAnswerSalt();

    await appPrefs.setPin(
      hashPin(pin, pinSalt),
      pinSaltValue: pinSalt,
      questionIndex: recovery.questionIndex,
      customQuestion: recovery.customQuestion,
      answerHash: hashAnswer(recovery.answer, answerSalt),
      answerSalt: answerSalt,
    );
    setState(() {});
  }

  /// Null if the user backs out. A recovery question is required, not
  /// optional — without one, a forgotten PIN has no way back short of
  /// losing all local data.
  Future<_RecoverySetup?> _promptForRecovery() async {
    const customOption = -1;
    int selectedIndex = 0;
    final answerController = TextEditingController();
    final customQuestionController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          final isCustom = selectedIndex == customOption;
          final canSubmit = answerController.text.trim().isNotEmpty &&
              (!isCustom || customQuestionController.text.trim().isNotEmpty);

          return AlertDialog(
            title: const Text('Set a recovery question'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'If you forget your PIN, this is the only way back into your '
                  'notes without losing them.',
                  style: TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 12),
                DropdownButton<int>(
                  value: selectedIndex,
                  isExpanded: true,
                  items: [
                    for (var i = 0; i < securityQuestions.length; i++)
                      DropdownMenuItem(value: i, child: Text(securityQuestions[i])),
                    const DropdownMenuItem(value: customOption, child: Text('Write my own question...')),
                  ],
                  onChanged: (value) => setDialogState(() => selectedIndex = value ?? 0),
                ),
                if (isCustom) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: customQuestionController,
                    decoration: const InputDecoration(labelText: 'Your question', border: OutlineInputBorder()),
                    onChanged: (_) => setDialogState(() {}),
                  ),
                ],
                const SizedBox(height: 12),
                TextField(
                  controller: answerController,
                  decoration: const InputDecoration(labelText: 'Answer', border: OutlineInputBorder()),
                  onChanged: (_) => setDialogState(() {}),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
              FilledButton(
                onPressed: canSubmit ? () => Navigator.pop(dialogContext, true) : null,
                child: const Text('Set PIN'),
              ),
            ],
          );
        },
      ),
    );

    if (confirmed != true || answerController.text.trim().isEmpty) return null;

    final isCustom = selectedIndex == customOption;
    if (isCustom && customQuestionController.text.trim().isEmpty) return null;

    return _RecoverySetup(
      questionIndex: isCustom ? null : selectedIndex,
      customQuestion: isCustom ? customQuestionController.text.trim() : null,
      answer: answerController.text.trim(),
    );
  }

  Future<void> _disablePinLock() async {
    final pin = await _promptForPin('Enter your PIN', 'Confirm your current PIN to turn off the lock.');
    if (pin == null) return;

    final salt = appPrefs.pinSalt;
    if (salt == null || hashPin(pin, salt) != appPrefs.pinHash) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Incorrect PIN.')),
        );
      }
      return;
    }

    await appPrefs.clearPin();
    setState(() {});
  }

  void _showAbout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('About DoomNotes'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('DoomNotes helps you save content from TikTok, YouTube, and Instagram, organized by topic, with instant access to the original source.'),
            const SizedBox(height: 12),
            Text('Version $_version ($_buildNumber)'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  void _shareApp() {
    Share.share(
      'I use DoomNotes to save videos and posts from TikTok, YouTube, and Instagram with the original source link. Try it!',
      subject: 'DoomNotes — save and find your saved content fast',
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = appPrefs.themeMode;
    final pinEnabled = appPrefs.requireUnlockToOpen;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 40),
        children: [
          SettingsSection(
            title: 'Appearance',
            children: [
              SettingsTile(
                icon: Icons.brightness_6_outlined,
                title: 'Theme',
                subtitle: switch (themeMode) {
                  ThemeMode.light => 'Light',
                  ThemeMode.dark => 'Dark',
                  ThemeMode.system => 'Match system',
                },
                trailing: PopupMenuButton<ThemeMode>(
                  icon: Icon(Icons.chevron_right_rounded, color: DoomNotesTheme.muted),
                  initialValue: themeMode,
                  onSelected: (mode) {
                    context.setDoomNotesThemeMode(mode);
                    setState(() {});
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: ThemeMode.system, child: Text('Match system')),
                    PopupMenuItem(value: ThemeMode.light, child: Text('Light')),
                    PopupMenuItem(value: ThemeMode.dark, child: Text('Dark')),
                  ],
                ),
              ),
            ],
          ),
          SettingsSection(
            title: 'Capture',
            children: [
              SettingsTile(
                icon: Icons.auto_awesome_rounded,
                title: 'Automatic topic mode',
                subtitle: _useAutomaticTopicMode
                    ? 'Suggest topics automatically when you save'
                    : 'Always ask which topic to use',
                trailing: Switch(value: _useAutomaticTopicMode, onChanged: _toggleTopicMode),
              ),
              SettingsTile(
                icon: Icons.help_outline_rounded,
                title: 'How to share',
                subtitle: 'Learn how to save from TikTok, YouTube, Instagram',
                onTap: () => _push(const HowToShareScreen()),
              ),
            ],
          ),
          SettingsSection(
            title: 'Library',
            children: [
              SettingsTile(
                icon: Icons.favorite_border_rounded,
                title: 'Favorites',
                onTap: () => _push(const FavoritesScreen()),
              ),
              SettingsTile(
                icon: Icons.archive_outlined,
                title: 'Archived',
                onTap: () => _push(const ArchivedNotesScreen()),
              ),
              SettingsTile(
                icon: Icons.delete_outline_rounded,
                title: 'Trash',
                onTap: () => _push(const TrashScreen()),
              ),
              SettingsTile(
                icon: Icons.sell_outlined,
                title: 'Manage topics',
                subtitle: 'Rename or merge topics',
                onTap: () => _push(const ManageTopicsScreen()),
              ),
            ],
          ),
          SettingsSection(
            title: 'Security',
            children: [
              SettingsTile(
                icon: Icons.lock_outline_rounded,
                title: 'Require PIN to open',
                trailing: Switch(
                  value: pinEnabled,
                  onChanged: (value) => value ? _enablePinLock() : _disablePinLock(),
                ),
              ),
              if (pinEnabled)
                SettingsTile(
                  icon: Icons.timer_outlined,
                  title: 'Auto-lock',
                  subtitle: _autoLockLabel(appPrefs.autoLockMinutes),
                  trailing: PopupMenuButton<int>(
                    icon: Icon(Icons.chevron_right_rounded, color: DoomNotesTheme.muted),
                    tooltip: 'Change auto-lock timing',
                    initialValue: appPrefs.autoLockMinutes,
                    onSelected: (minutes) async {
                      await appPrefs.setAutoLockMinutes(minutes);
                      setState(() {});
                    },
                    itemBuilder: (context) => [
                      for (final minutes in const [0, 1, 5, 30, -1])
                        PopupMenuItem(value: minutes, child: Text(_autoLockLabel(minutes))),
                    ],
                  ),
                ),
            ],
          ),
          SettingsSection(
            title: 'Account & Sync',
            children: [
              SettingsTile(
                icon: Icons.cloud_outlined,
                title: 'Enable cloud sync',
                subtitle: 'Requires your own Firebase project — see docs/ENABLE_CLOUD_SYNC.md',
                trailing: Switch(
                  value: appPrefs.cloudSyncEnabled,
                  onChanged: (value) async {
                    await appPrefs.setCloudSyncEnabled(value);
                    if (mounted) {
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Restart DoomNotes for this to take effect.')),
                      );
                    }
                  },
                ),
              ),
              if (appPrefs.cloudSyncEnabled)
                if (firebaseReady)
                  const AccountSyncTile()
                else
                  const SettingsTile(
                    icon: Icons.warning_amber_rounded,
                    title: 'Not configured yet',
                    subtitle: 'lib/firebase_options.dart still has placeholder values — '
                        'run "flutterfire configure" with your own Firebase project, '
                        'then restart the app.',
                  ),
            ],
          ),
          SettingsSection(
            title: 'Data',
            children: [
              SettingsTile(
                icon: Icons.backup_rounded,
                title: 'Export / Import',
                subtitle: 'Back up or restore your library',
                onTap: () => _push(const ExportImportScreen()),
              ),
            ],
          ),
          SettingsSection(
            title: 'Legal',
            children: [
              SettingsTile(
                icon: Icons.privacy_tip_rounded,
                title: 'Privacy Policy',
                // TODO(you): replace with your real, hosted Privacy Policy URL
                // before submitting to the App Store / Play Store. A draft you
                // can host as-is is at docs/PRIVACY_POLICY.md.
                onTap: () => _openUrl('https://REPLACE_WITH_YOUR_PRIVACY_POLICY_URL'),
              ),
              SettingsTile(
                icon: Icons.description_rounded,
                title: 'Terms of Service',
                // TODO(you): replace with your real, hosted Terms of Service URL.
                onTap: () => _openUrl('https://REPLACE_WITH_YOUR_TERMS_URL'),
              ),
            ],
          ),
          SettingsSection(
            title: 'About',
            children: [
              SettingsTile(
                icon: Icons.info_outline_rounded,
                title: 'About DoomNotes',
                subtitle: 'Version $_version ($_buildNumber)',
                onTap: _showAbout,
              ),
              SettingsTile(
                icon: Icons.share_rounded,
                title: 'Share DoomNotes',
                onTap: _shareApp,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecoverySetup {
  final int? questionIndex;
  final String? customQuestion;
  final String answer;

  const _RecoverySetup({
    required this.questionIndex,
    required this.customQuestion,
    required this.answer,
  });
}
