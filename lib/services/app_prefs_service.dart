import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPrefsService {
  final SharedPreferences _prefs;

  AppPrefsService(this._prefs);

  bool get hasSeenOnboarding => _prefs.getBool('has_seen_onboarding') ?? false;

  Future<void> setHasSeenOnboarding(bool value) async {
    await _prefs.setBool('has_seen_onboarding', value);
  }

  bool get useAutomaticTopicMode =>
      _prefs.getBool('use_automatic_topic_mode') ?? true;

  Future<void> setUseAutomaticTopicMode(bool value) async {
    await _prefs.setBool('use_automatic_topic_mode', value);
  }

  ThemeMode get themeMode {
    switch (_prefs.getString('theme_mode')) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setString('theme_mode', mode.name);
  }

  // ---- PIN lock + recovery ----

  bool get requireUnlockToOpen => _prefs.getBool('require_unlock') ?? false;

  String? get pinHash => _prefs.getString('pin_hash');

  String? get pinSalt => _prefs.getString('pin_salt');

  int? get securityQuestionIndex => _prefs.getInt('security_question_index');

  /// Null for a preset question (use [securityQuestionIndex] instead),
  /// set when the user wrote their own question.
  String? get customSecurityQuestion => _prefs.getString('custom_security_question');

  String? get securityAnswerHash => _prefs.getString('security_answer_hash');

  String? get securityAnswerSalt => _prefs.getString('security_answer_salt');

  bool get hasRecoveryConfigured => securityAnswerHash != null;

  /// Enables the lock and stores the PIN's hash (never the raw PIN) plus
  /// a random per-install salt — a bare SHA-256 of a 4-6 digit PIN is only
  /// 10,000-1,000,000 possibilities and trivially brute-forceable if the
  /// raw prefs file is ever extracted, so it's salted like the security
  /// answer below. Also stores a recovery question so a forgotten PIN
  /// doesn't permanently lock the user out of their own local notes.
  Future<void> setPin(
    String pinHashValue, {
    required String pinSaltValue,
    int? questionIndex,
    String? customQuestion,
    required String answerHash,
    required String answerSalt,
  }) async {
    await _prefs.setString('pin_hash', pinHashValue);
    await _prefs.setString('pin_salt', pinSaltValue);
    if (questionIndex != null) {
      await _prefs.setInt('security_question_index', questionIndex);
    } else {
      await _prefs.remove('security_question_index');
    }
    if (customQuestion != null) {
      await _prefs.setString('custom_security_question', customQuestion);
    } else {
      await _prefs.remove('custom_security_question');
    }
    await _prefs.setString('security_answer_hash', answerHash);
    await _prefs.setString('security_answer_salt', answerSalt);
    await _prefs.setBool('require_unlock', true);
  }

  /// Replaces just the PIN (with a fresh salt), keeping the same recovery
  /// question/answer — used after a successful "Forgot PIN" recovery.
  Future<void> replacePin(String pinHashValue, String pinSaltValue) async {
    await _prefs.setString('pin_hash', pinHashValue);
    await _prefs.setString('pin_salt', pinSaltValue);
  }

  Future<void> clearPin() async {
    await _prefs.remove('pin_hash');
    await _prefs.remove('pin_salt');
    await _prefs.remove('security_question_index');
    await _prefs.remove('custom_security_question');
    await _prefs.remove('security_answer_hash');
    await _prefs.remove('security_answer_salt');
    await _prefs.setBool('require_unlock', false);
  }

  // ---- Auto-lock ----
  // Minutes of being backgrounded before the PIN is required again on
  // resume. 0 means "immediately", -1 means "never" (only on full
  // relaunch). Default is a middle ground, not immediate — re-prompting
  // every time you switch briefly to reply to a text is more annoying
  // than most people want from a notes app.

  int get autoLockMinutes => _prefs.getInt('auto_lock_minutes') ?? 2;

  Future<void> setAutoLockMinutes(int minutes) async {
    await _prefs.setInt('auto_lock_minutes', minutes);
  }

  // ---- Topic aliases ----
  // When a topic is renamed/merged via Manage Topics, the rename only
  // affects notes that already exist unless we also remember the mapping
  // here — otherwise the next auto-classified share just recreates the
  // old topic name from scratch. Applied as a final remap step after
  // classification (see share_capture_service.dart).

  Map<String, String> get topicAliases {
    final raw = _prefs.getString('topic_aliases');
    if (raw == null) return {};
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map((k, v) => MapEntry(k, v as String));
  }

  Future<void> setTopicAlias(String oldName, String newName) async {
    final aliases = topicAliases;
    // Also repoint anything that already aliased to oldName, so chains
    // (A -> B, then later B -> C) collapse to a direct mapping.
    aliases.removeWhere((from, to) => to == oldName);
    aliases[oldName] = newName;
    await _prefs.setString('topic_aliases', jsonEncode(aliases));
  }

  // ---- Cloud sync ----
  // Off by default. Turning this on only does something once a real
  // Firebase project has been configured (see docs/ENABLE_CLOUD_SYNC.md);
  // main.dart checks this flag and skips Firebase init entirely when off,
  // so an unconfigured project can't crash the app on startup.

  bool get cloudSyncEnabled => _prefs.getBool('cloud_sync_enabled') ?? false;

  Future<void> setCloudSyncEnabled(bool value) async {
    await _prefs.setBool('cloud_sync_enabled', value);
  }
}
