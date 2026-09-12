// DOOMNOTES - Placeholder Firebase options
//
// This is NOT real configuration. It exists only so main.dart can import
// and reference `DefaultFirebaseOptions.currentPlatform` without a
// compile error, before you've set up your own Firebase project.
//
// REPLACE THIS ENTIRE FILE by running:
//   flutterfire configure
// from your project root, once you have a Firebase project. That command
// overwrites this file with your real, working values.
//
// Safety: Firebase is never actually initialized with these placeholder
// values unless you turn on "Enable cloud sync" in Settings — see
// main.dart and docs/ENABLE_CLOUD_SYNC.md. Attempting to initialize with
// these fake values will fail (caught and surfaced as a friendly message,
// not a crash) rather than silently pretending to work.

import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: 'REPLACE_ME',
      appId: 'REPLACE_ME',
      messagingSenderId: 'REPLACE_ME',
      projectId: 'REPLACE_ME',
      storageBucket: 'REPLACE_ME',
    );
  }
}
