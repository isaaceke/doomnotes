import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import '../theme/doomnotes_theme.dart';

String _randomSalt([int length = 16]) {
  const charset = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  final random = Random.secure();
  return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
}

String generatePinSalt() => _randomSalt();
String generateAnswerSalt() => _randomSalt();

String hashPin(String pin, String salt) =>
    sha256.convert(utf8.encode('$salt:$pin')).toString();

String hashAnswer(String answer, String salt) =>
    sha256.convert(utf8.encode('$salt:${answer.trim().toLowerCase()}')).toString();

/// Preset recovery questions. A user can also write their own — see
/// AppPrefsService.customSecurityQuestion.
const securityQuestions = [
  'What was your first pet\'s name?',
  'What city were you born in?',
  'What was the name of your first school?',
  'What\'s your mother\'s maiden name?',
  'What was your childhood nickname?',
];

/// Wraps [child] behind a PIN prompt when the user has enabled
/// "Require PIN to open" in Settings. Give this widget a new `key` (see
/// main.dart's auto-lock handling) to force it to remount and re-prompt
/// for the PIN after the app has been backgrounded past the configured
/// auto-lock timeout — it otherwise only asks once per app-process
/// lifetime, which "auto-lock after N minutes" needs to override.
class LockScreen extends StatefulWidget {
  final Widget child;

  const LockScreen({super.key, required this.child});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  bool _unlocked = false;
  String _entered = '';
  String? _error;

  void _onDigit(String digit) {
    if (_entered.length >= 6) return;
    setState(() {
      _entered += digit;
      _error = null;
    });
    if (_entered.length >= 4) _tryUnlock();
  }

  void _onBackspace() {
    if (_entered.isEmpty) return;
    setState(() => _entered = _entered.substring(0, _entered.length - 1));
  }

  void _tryUnlock() {
    final storedHash = appPrefs.pinHash;
    final salt = appPrefs.pinSalt;
    if (storedHash != null && salt != null && hashPin(_entered, salt) == storedHash) {
      setState(() => _unlocked = true);
      return;
    }
    // Give a short beat before clearing so the filled dots are visible.
    Future.delayed(const Duration(milliseconds: 150), () {
      if (!mounted) return;
      setState(() {
        _error = 'Incorrect PIN';
        _entered = '';
      });
    });
  }

  Future<void> _openRecovery() async {
    if (!appPrefs.hasRecoveryConfigured) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('No recovery set up'),
          content: const Text(
            'This PIN was set before recovery questions existed, so there\'s '
            'no way to verify it\'s you without the PIN itself. Uninstalling '
            'and reinstalling the app is the only way back in, which will '
            'also erase your local notes.',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
          ],
        ),
      );
      return;
    }

    final recovered = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const _PinRecoveryScreen()),
    );

    if (recovered == true) {
      setState(() {
        _unlocked = true;
        _entered = '';
        _error = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_unlocked) return widget.child;

    return Scaffold(
      backgroundColor: DoomNotesTheme.canvas,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_rounded, size: 40, color: DoomNotesTheme.violet),
              const SizedBox(height: 16),
              Text('Enter your PIN', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                _error ?? 'DoomNotes is locked',
                style: TextStyle(color: _error != null ? DoomNotesTheme.rose : DoomNotesTheme.muted),
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (i) {
                  final filled = i < _entered.length;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: filled ? DoomNotesTheme.violet : Colors.transparent,
                      border: Border.all(color: DoomNotesTheme.border),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 36),
              _NumberPad(onDigit: _onDigit, onBackspace: _onBackspace),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _openRecovery,
                child: const Text('Forgot PIN?'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PinRecoveryScreen extends StatefulWidget {
  const _PinRecoveryScreen();

  @override
  State<_PinRecoveryScreen> createState() => _PinRecoveryScreenState();
}

class _PinRecoveryScreenState extends State<_PinRecoveryScreen> {
  final _answerController = TextEditingController();
  final _newPinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  bool _answerVerified = false;
  String? _error;

  @override
  void dispose() {
    _answerController.dispose();
    _newPinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  void _checkAnswer() {
    final expected = appPrefs.securityAnswerHash;
    final salt = appPrefs.securityAnswerSalt;
    if (expected != null && salt != null && hashAnswer(_answerController.text, salt) == expected) {
      setState(() {
        _answerVerified = true;
        _error = null;
      });
    } else {
      setState(() => _error = 'That doesn\'t match.');
    }
  }

  Future<void> _setNewPin() async {
    final newPin = _newPinController.text;
    if (newPin.length < 4) {
      setState(() => _error = 'PIN must be at least 4 digits.');
      return;
    }
    if (newPin != _confirmPinController.text) {
      setState(() => _error = 'PINs didn\'t match.');
      return;
    }

    final salt = generatePinSalt();
    await appPrefs.replacePin(hashPin(newPin, salt), salt);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final question = appPrefs.customSecurityQuestion ??
        securityQuestions[(appPrefs.securityQuestionIndex ?? 0).clamp(0, securityQuestions.length - 1)];

    return Scaffold(
      appBar: AppBar(title: const Text('Recover PIN')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_answerVerified) ...[
              Text(question, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              TextField(
                controller: _answerController,
                autofocus: true,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                onSubmitted: (_) => _checkAnswer(),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(onPressed: _checkAnswer, child: const Text('Continue')),
              ),
            ] else ...[
              Text('Set a new PIN', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              TextField(
                controller: _newPinController,
                autofocus: true,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: const InputDecoration(labelText: 'New PIN', counterText: ''),
              ),
              TextField(
                controller: _confirmPinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: const InputDecoration(labelText: 'Confirm new PIN', counterText: ''),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(onPressed: _setNewPin, child: const Text('Save new PIN')),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: TextStyle(color: DoomNotesTheme.rose)),
            ],
          ],
        ),
      ),
    );
  }
}

class _NumberPad extends StatelessWidget {
  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;

  const _NumberPad({required this.onDigit, required this.onBackspace});

  @override
  Widget build(BuildContext context) {
    Widget key(String label, {VoidCallback? onTap, Widget? child}) {
      return Expanded(
        child: AspectRatio(
          aspectRatio: 1,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Material(
              color: DoomNotesTheme.surface,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onTap,
                child: Center(
                  child: child ??
                      Text(label, style: Theme.of(context).textTheme.titleLarge),
                ),
              ),
            ),
          ),
        ),
      );
    }

    final rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final row in rows)
          Row(children: [for (final d in row) key(d, onTap: () => onDigit(d))]),
        Row(children: [
          const Expanded(child: SizedBox()),
          key('0', onTap: () => onDigit('0')),
          key(
            '',
            onTap: onBackspace,
            child: const Icon(Icons.backspace_outlined),
          ),
        ]),
      ],
    );
  }
}
