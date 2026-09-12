import 'dart:math';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../models/app_user.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Stream<AppUser?> get authStateChanges {
    return _auth.authStateChanges().map(
      (firebaseUser) =>
          firebaseUser == null ? null : AppUser.fromFirebase(firebaseUser),
    );
  }

  AppUser? get currentUser {
    final user = _auth.currentUser;
    return user == null ? null : AppUser.fromFirebase(user);
  }

  bool get isSignedIn =>
      _auth.currentUser != null && !_auth.currentUser!.isAnonymous;

  // ----------------------------------------------------------
  // Email/password
  // ----------------------------------------------------------

  Future<AppUser> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user!;
    if (displayName != null && displayName.trim().isNotEmpty) {
      await user.updateDisplayName(displayName.trim());
      await user.reload();
    }

    await _createOrUpdateUserProfile(_auth.currentUser!);
    return AppUser.fromFirebase(_auth.currentUser!);
  }

  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    await _createOrUpdateUserProfile(credential.user!);
    return AppUser.fromFirebase(credential.user!);
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  // ----------------------------------------------------------
  // Google
  // ----------------------------------------------------------

  Future<AppUser?> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();

    // User closed the account chooser.
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final result = await _auth.signInWithCredential(credential);

    await _createOrUpdateUserProfile(result.user!);
    return AppUser.fromFirebase(result.user!);
  }

  // ----------------------------------------------------------
  // Apple
  // ----------------------------------------------------------

  Future<AppUser?> signInWithApple() async {
    if (!await SignInWithApple.isAvailable()) {
      throw const AuthException(
        code: 'apple-not-available',
        message: 'Sign in with Apple is not available on this device.',
      );
    }

    final rawNonce = _generateNonce();
    final nonce = _sha256ofString(rawNonce);

    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: const [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );

    final oauthCredential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
    );

    final result = await _auth.signInWithCredential(oauthCredential);
    final user = result.user!;

    // Apple only gives name/email on the first authorization.
    final appleName = [
      appleCredential.givenName,
      appleCredential.familyName,
    ].whereType<String>().where((value) => value.trim().isNotEmpty).join(' ');

    if (appleName.isNotEmpty && (user.displayName == null || user.displayName!.isEmpty)) {
      await user.updateDisplayName(appleName);
      await user.reload();
    }

    await _createOrUpdateUserProfile(_auth.currentUser!);
    return AppUser.fromFirebase(_auth.currentUser!);
  }

  // ----------------------------------------------------------
  // Anonymous account migration
  // Important: preserves local cloud notes when a guest signs in.
  // ----------------------------------------------------------

  Future<AppUser?> linkAnonymousUserWithGoogle() async {
    final current = _auth.currentUser;
    if (current == null || !current.isAnonymous) {
      return signInWithGoogle();
    }

    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final result = await current.linkWithCredential(credential);
    await _createOrUpdateUserProfile(result.user!);
    return AppUser.fromFirebase(result.user!);
  }

  Future<AppUser> linkAnonymousUserWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final current = _auth.currentUser;

    if (current == null || !current.isAnonymous) {
      return signUpWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );
    }

    final credential = EmailAuthProvider.credential(
      email: email.trim(),
      password: password,
    );

    final result = await current.linkWithCredential(credential);

    if (displayName != null && displayName.trim().isNotEmpty) {
      await result.user!.updateDisplayName(displayName.trim());
      await result.user!.reload();
    }

    await _createOrUpdateUserProfile(_auth.currentUser!);
    return AppUser.fromFirebase(_auth.currentUser!);
  }

  Future<AppUser?> linkAnonymousUserWithApple() async {
    final current = _auth.currentUser;
    if (current == null || !current.isAnonymous) {
      return signInWithApple();
    }

    if (!await SignInWithApple.isAvailable()) {
      throw const AuthException(
        code: 'apple-not-available',
        message: 'Sign in with Apple is not available on this device.',
      );
    }

    final rawNonce = _generateNonce();
    final nonce = _sha256ofString(rawNonce);

    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: const [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );

    final oauthCredential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
    );

    final result = await current.linkWithCredential(oauthCredential);
    await _createOrUpdateUserProfile(result.user!);
    return AppUser.fromFirebase(result.user!);
  }

  // ----------------------------------------------------------
  // Account
  // ----------------------------------------------------------

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<void> _createOrUpdateUserProfile(User user) async {
    // Firestore user profile is created by CloudSyncService.
    // Kept here for a single future extension point.
  }

  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';

    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  String _sha256ofString(String input) {
    return sha256.convert(utf8.encode(input)).toString();
  }
}

class AuthException implements Exception {
  final String code;
  final String message;

  const AuthException({
    required this.code,
    required this.message,
  });

  @override
  String toString() => message;
}