import 'dart:io';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/doomnotes_theme.dart';
import '../widgets/auth_provider_button.dart';

class AuthScreen extends StatefulWidget {
  final bool isLinkingAnonymousAccount;

  const AuthScreen({
    super.key,
    this.isLinkingAnonymousAccount = false,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isSignUp = false;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _isLoading = true);

    try {
      await action();

      if (!mounted) return;
      Navigator.pop(context, true);
    } on Exception catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_friendlyError(error))),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _continueWithGoogle() async {
    await _run(() async {
      if (widget.isLinkingAnonymousAccount) {
        await AuthService.instance.linkAnonymousUserWithGoogle();
      } else {
        await AuthService.instance.signInWithGoogle();
      }
    });
  }

  Future<void> _continueWithApple() async {
    await _run(() async {
      if (widget.isLinkingAnonymousAccount) {
        await AuthService.instance.linkAnonymousUserWithApple();
      } else {
        await AuthService.instance.signInWithApple();
      }
    });
  }

  Future<void> _submitEmail() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    await _run(() async {
      if (widget.isLinkingAnonymousAccount && _isSignUp) {
        await AuthService.instance.linkAnonymousUserWithEmail(
          email: email,
          password: password,
          displayName: _nameController.text.trim(),
        );
        return;
      }

      if (_isSignUp) {
        await AuthService.instance.signUpWithEmail(
          email: email,
          password: password,
          displayName: _nameController.text.trim(),
        );
      } else {
        await AuthService.instance.signInWithEmail(
          email: email,
          password: password,
        );
      }
    });
  }

  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter your email first, then tap Forgot password.')),
      );
      return;
    }

    await _run(() async {
      await AuthService.instance.sendPasswordResetEmail(email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password-reset email sent.')),
      );
    });
  }

  String _friendlyError(Object error) {
    if (error is AuthException) return error.message;

    final value = error.toString();

    if (value.contains('email-already-in-use')) {
      return 'An account already exists with this email. Sign in instead.';
    }
    if (value.contains('invalid-email')) {
      return 'Enter a valid email address.';
    }
    if (value.contains('weak-password')) {
      return 'Use a password with at least 8 characters.';
    }
    if (value.contains('wrong-password') || value.contains('invalid-credential')) {
      return 'Incorrect email or password.';
    }
    if (value.contains('user-not-found')) {
      return 'No account exists with that email yet.';
    }
    if (value.contains('network-request-failed')) {
      return 'Check your internet connection and try again.';
    }
    if (value.contains('account-exists-with-different-credential')) {
      return 'This email already uses another sign-in method.';
    }

    return 'Could not sign you in. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isLinkingAnonymousAccount
        ? 'Back up your library'
        : (_isSignUp ? 'Create your account' : 'Welcome back');

    final subtitle = widget.isLinkingAnonymousAccount
        ? 'Sign in to sync your saved videos and notes across devices.'
        : 'Save what matters. Find it later. Return to the original source.';

    return Scaffold(
      appBar: AppBar(
        title: const Text('DoomNotes'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.bookmark_added_rounded,
                    size: 52,
                    color: DoomNotesTheme.violet,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: DoomNotesTheme.muted,
                        ),
                  ),
                  const SizedBox(height: 28),
                  AuthProviderButton(
                    label: 'Continue with Google',
                    icon: Icons.g_mobiledata_rounded,
                    onPressed: _isLoading ? null : _continueWithGoogle,
                  ),
                  if (Platform.isIOS || Platform.isMacOS) ...[
                    const SizedBox(height: 12),
                    AuthProviderButton(
                      label: 'Continue with Apple',
                      icon: Icons.apple_rounded,
                      dark: true,
                      onPressed: _isLoading ? null : _continueWithApple,
                    ),
                  ],
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'OR',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        if (_isSignUp) ...[
                          TextFormField(
                            controller: _nameController,
                            textCapitalization: TextCapitalization.words,
                            decoration: const InputDecoration(
                              labelText: 'Name',
                              prefixIcon: Icon(Icons.person_outline_rounded),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: (value) {
                            if (value == null || !value.contains('@')) {
                              return 'Enter a valid email address.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          enableSuggestions: false,
                          autocorrect: false,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            suffixIcon: IconButton(
                              tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () {
                                setState(() => _obscurePassword = !_obscurePassword);
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.length < 8) {
                              return 'Use at least 8 characters.';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  if (!_isSignUp) ...[
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _isLoading ? null : _forgotPassword,
                        child: const Text('Forgot password?'),
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  FilledButton(
                    onPressed: _isLoading ? null : _submitEmail,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            _isSignUp
                                ? 'Create account'
                                : 'Sign in with email',
                          ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () => setState(() => _isSignUp = !_isSignUp),
                    child: Text(
                      _isSignUp
                          ? 'Already have an account? Sign in'
                          : 'New here? Create an account',
                    ),
                  ),
                  if (!widget.isLinkingAnonymousAccount) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Your saved library syncs only after you sign in. You can continue using DoomNotes locally before creating an account.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}