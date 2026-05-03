// Template for `firebase_options.dart`.
//
// 1. Create a Firebase project at https://console.firebase.google.com
// 2. Add an Android app with package name `com.guiga.mycycle` (or your fork's
//    package) and your debug + release SHA-1 fingerprints.
// 3. Run `flutterfire configure` — it generates `lib/firebase_options.dart`
//    with the values below populated. That file is gitignored.
//
// Firebase API keys are public identifiers (see
// https://firebase.google.com/docs/projects/api-keys). Restrict abuse via:
//   - API key restrictions in Google Cloud Console (Android package + SHA-1)
//   - Firestore security rules (see firestore.rules)
//   - Firebase App Check (recommended before going public)

// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Web is not configured.');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      // ignore: no_default_cases
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_FIREBASE_ANDROID_API_KEY',
    appId: 'YOUR_FIREBASE_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'your-firebase-project-id',
    storageBucket: 'your-firebase-project-id.firebasestorage.app',
  );
}
