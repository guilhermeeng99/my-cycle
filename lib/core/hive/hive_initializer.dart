import 'package:hive_ce_flutter/hive_flutter.dart';

import 'package:mycycle/core/hive/box_names.dart';

/// Opens every Hive box the app needs. Called from `main()` after
/// `Firebase.initializeApp()` and before `runApp()` so the box handles
/// are ready by the time the first frame renders.
Future<void> initHive() async {
  await Hive.initFlutter();
  for (final name in HiveBoxes.all) {
    if (!Hive.isBoxOpen(name)) {
      await Hive.openBox<String>(name);
    }
  }
}

/// Wipes every cached document. Called on sign-out so the next user
/// doesn't see the previous user's cached state on the splash.
Future<void> clearAllCaches() async {
  for (final name in HiveBoxes.all) {
    if (Hive.isBoxOpen(name)) {
      await Hive.box<String>(name).clear();
    }
  }
}
