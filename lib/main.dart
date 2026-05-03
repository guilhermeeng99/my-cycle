import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:mycycle/app/app_widget.dart';
import 'package:mycycle/app/di/injection_container.dart';
import 'package:mycycle/core/notifications/notifications_coordinator.dart';
import 'package:mycycle/firebase_options.dart';
import 'package:mycycle/gen/i18n/strings.g.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initDependencies();
  await LocaleSettings.useDeviceLocale();

  // Long-lived service: schedules period reminders as cycles change.
  // Permission is requested only when the user toggles notifications on.
  unawaited(getIt<NotificationsCoordinator>().start());

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  runApp(TranslationProvider(child: const MyCycleApp()));
}
