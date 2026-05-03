import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:mycycle/app/app_widget.dart';
import 'package:mycycle/app/di/injection_container.dart';
import 'package:mycycle/core/notifications/notifications_coordinator.dart';
import 'package:mycycle/firebase_options.dart';
import 'package:mycycle/gen/i18n/strings.g.dart';

/// OAuth 2.0 Web client ID from `android/app/google-services.json`
/// (`oauth_client[client_type=3]`). Required by Google Sign-In so the ID
/// token it returns is signed for our Firebase project. OAuth client IDs
/// are public identifiers — safe to commit; security comes from package
/// name + SHA-1 fingerprint restrictions in the Google Cloud Console.
const String _googleSignInServerClientId =
    '1071997209882-mjsv5ursdqt3nd56u6adprbpiae6503d.apps.googleusercontent.com';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await GoogleSignIn.instance.initialize(
    serverClientId: _googleSignInServerClientId,
  );
  configureDependencies();

  // Long-lived service: schedules period reminders as cycles change.
  // Permission is requested only when the user toggles notifications on.
  unawaited(getIt<NotificationsCoordinator>().start());

  await LocaleSettings.useDeviceLocale();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  runApp(TranslationProvider(child: const MyCycleApp()));
}
