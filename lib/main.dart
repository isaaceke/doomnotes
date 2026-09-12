import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'models/note.dart';
import 'services/app_prefs_service.dart';
import 'services/auth_service.dart';
import 'services/cloud_sync_service.dart';
import 'services/topic_keyword_database_service.dart';
import 'services/share_capture_service.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'screens/lock_screen.dart';
import 'theme/doomnotes_theme.dart';

late Isar isarDb;
late AppPrefsService appPrefs;
final topicService = TopicKeywordDatabaseService();
final shareCaptureService = ShareCaptureService();

/// True only if Firebase actually finished initializing this run. Cloud
/// sync UI (see settings_screen.dart) checks this before offering sign-in,
/// since `cloudSyncEnabled` alone just means the user asked for it — it
/// doesn't mean a real Firebase project is configured yet.
bool firebaseReady = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Isar
  final dir = await getApplicationDocumentsDirectory();
  isarDb = await Isar.open(
    [NoteSchema],
    directory: dir.path,
    name: 'doomnotes',
  );

  // Initialize preferences
  final prefs = await SharedPreferences.getInstance();
  appPrefs = AppPrefsService(prefs);

  // Cloud sync is entirely optional and off by default. Firebase is only
  // ever touched if the user explicitly turned this on in Settings AND
  // lib/firebase_options.dart has been replaced with real values via
  // `flutterfire configure` — otherwise this fails harmlessly and the app
  // continues in local-only mode. See docs/ENABLE_CLOUD_SYNC.md.
  if (appPrefs.cloudSyncEnabled) {
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      firebaseReady = true;

      await CloudSyncService.instance.initialize(isarDb);
      AuthService.instance.authStateChanges.listen((user) async {
        await CloudSyncService.instance.stop();
        if (user != null) await CloudSyncService.instance.initialize(isarDb);
      });
    } catch (e) {
      // Expected until a real Firebase project is configured. The app
      // continues normally in local-only mode; Settings surfaces this so
      // it isn't a silent failure.
      firebaseReady = false;
    }
  }

  // Load topic packs
  await topicService.load();

  // Handle incoming share when app is launched via share
  await shareCaptureService.handleInitialShare();

  runApp(const DoomNotesApp());
}

class DoomNotesApp extends StatefulWidget {
  const DoomNotesApp({super.key});

  @override
  State<DoomNotesApp> createState() => DoomNotesAppState();
}

class DoomNotesAppState extends State<DoomNotesApp> with WidgetsBindingObserver {
  late ThemeMode _themeMode;
  DateTime? _backgroundedAt;
  int _lockGeneration = 0;

  @override
  void initState() {
    super.initState();
    _themeMode = appPrefs.themeMode;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    // Only matters when following the system setting; forces a rebuild so
    // DoomNotesTheme's static colors get re-resolved for the new brightness.
    if (_themeMode == ThemeMode.system) setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!appPrefs.requireUnlockToOpen) return;

    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _backgroundedAt ??= DateTime.now();
      return;
    }

    if (state == AppLifecycleState.resumed) {
      final backgroundedAt = _backgroundedAt;
      _backgroundedAt = null;
      if (backgroundedAt == null) return;

      final minutes = appPrefs.autoLockMinutes;
      if (minutes < 0) return; // "Never" — only locks on full relaunch

      final elapsed = DateTime.now().difference(backgroundedAt);
      if (elapsed >= Duration(minutes: minutes)) {
        // Bumping this changes LockScreen's key below, which makes Flutter
        // treat it as a new widget and remount it — resetting its internal
        // "unlocked" state back to locked. LockScreen otherwise only ever
        // asks once per app-process lifetime, which isn't enough for a
        // configurable auto-lock timeout.
        setState(() => _lockGeneration++);
      }
    }
  }

  /// Called by SettingsScreen when the user changes the appearance setting.
  void setThemeMode(ThemeMode mode) {
    setState(() => _themeMode = mode);
    appPrefs.setThemeMode(mode);
  }

  @override
  Widget build(BuildContext context) {
    final systemIsDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    final isDark = _themeMode == ThemeMode.dark ||
        (_themeMode == ThemeMode.system && systemIsDark);

    // Must happen before building any descendant that reads
    // DoomNotesTheme.ink/canvas/surface/etc., since those are resolved
    // from this flag rather than from Theme.of(context).
    DoomNotesTheme.setDark(isDark);

    final home = appPrefs.hasSeenOnboarding ? const HomeScreen() : const OnboardingScreen();

    return MaterialApp(
      title: 'DoomNotes',
      theme: isDark ? DoomNotesTheme.darkTheme() : DoomNotesTheme.lightTheme(),
      home: appPrefs.requireUnlockToOpen
          ? LockScreen(key: ValueKey(_lockGeneration), child: home)
          : home,
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Lets SettingsScreen reach the app root to change the theme mode live,
/// without pulling in a state-management package for a single value.
extension DoomNotesAppAccess on BuildContext {
  void setDoomNotesThemeMode(ThemeMode mode) {
    findAncestorStateOfType<DoomNotesAppState>()?.setThemeMode(mode);
  }
}
