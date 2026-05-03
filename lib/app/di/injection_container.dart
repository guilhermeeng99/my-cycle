import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:mycycle/core/clock/clock.dart';
import 'package:mycycle/core/notifications/notifications_coordinator.dart';
import 'package:mycycle/core/notifications/notifications_repository.dart';
import 'package:mycycle/core/notifications/notifications_repository_impl.dart';
import 'package:mycycle/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:mycycle/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:mycycle/features/auth/domain/repositories/auth_repository.dart';
import 'package:mycycle/features/cycle/data/datasources/cycle_remote_datasource.dart';
import 'package:mycycle/features/cycle/data/datasources/day_log_remote_datasource.dart';
import 'package:mycycle/features/cycle/data/repositories/cycle_repository_impl.dart';
import 'package:mycycle/features/cycle/data/repositories/day_log_repository_impl.dart';
import 'package:mycycle/features/cycle/domain/repositories/cycle_repository.dart';
import 'package:mycycle/features/cycle/domain/repositories/day_log_repository.dart';
import 'package:mycycle/features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'package:mycycle/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:mycycle/features/pairing/data/datasources/couple_remote_datasource.dart';
import 'package:mycycle/features/pairing/data/repositories/couple_repository_impl.dart';
import 'package:mycycle/features/pairing/domain/repositories/couple_repository.dart';
import 'package:mycycle/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:mycycle/features/settings/domain/repositories/settings_repository.dart';

final GetIt getIt = GetIt.instance;

/// Wires up the app's dependency graph.
///
/// Call once from `main()` after Firebase has been initialized.
void configureDependencies() {
  getIt
    // External singletons
    ..registerLazySingleton<fb.FirebaseAuth>(() => fb.FirebaseAuth.instance)
    ..registerLazySingleton<FirebaseFirestore>(
      () => FirebaseFirestore.instance,
    )
    ..registerLazySingleton<GoogleSignIn>(() => GoogleSignIn.instance)
    ..registerLazySingleton<Clock>(() => const SystemClock())
    // Auth feature
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(
        firebaseAuth: getIt<fb.FirebaseAuth>(),
        googleSignIn: getIt<GoogleSignIn>(),
        firestore: getIt<FirebaseFirestore>(),
      ),
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        remote: getIt<AuthRemoteDataSource>(),
        clock: getIt<Clock>(),
      ),
    )
    // Onboarding feature
    ..registerLazySingleton<OnboardingRepository>(
      () => OnboardingRepositoryImpl(
        firestore: getIt<FirebaseFirestore>(),
        clock: getIt<Clock>(),
      ),
    )
    // Cycle feature
    ..registerLazySingleton<CycleRemoteDataSource>(
      () => CycleRemoteDataSourceImpl(
        firestore: getIt<FirebaseFirestore>(),
      ),
    )
    ..registerLazySingleton<CycleRepository>(
      () => CycleRepositoryImpl(
        remote: getIt<CycleRemoteDataSource>(),
        clock: getIt<Clock>(),
      ),
    )
    ..registerLazySingleton<DayLogRemoteDataSource>(
      () => DayLogRemoteDataSourceImpl(
        firestore: getIt<FirebaseFirestore>(),
      ),
    )
    ..registerLazySingleton<DayLogRepository>(
      () => DayLogRepositoryImpl(remote: getIt<DayLogRemoteDataSource>()),
    )
    // Pairing / couple feature
    ..registerLazySingleton<CoupleRemoteDataSource>(
      () => CoupleRemoteDataSourceImpl(
        firestore: getIt<FirebaseFirestore>(),
      ),
    )
    ..registerLazySingleton<CoupleRepository>(
      () => CoupleRepositoryImpl(
        remote: getIt<CoupleRemoteDataSource>(),
        clock: getIt<Clock>(),
      ),
    )
    // Settings feature
    ..registerLazySingleton<SettingsRepository>(
      () => SettingsRepositoryImpl(
        firestore: getIt<FirebaseFirestore>(),
        clock: getIt<Clock>(),
      ),
    )
    // Notifications
    ..registerLazySingleton<NotificationsRepository>(
      NotificationsRepositoryImpl.new,
    )
    ..registerLazySingleton<NotificationsCoordinator>(
      () => NotificationsCoordinator(
        authRepository: getIt<AuthRepository>(),
        cycleRepository: getIt<CycleRepository>(),
        notificationsRepository: getIt<NotificationsRepository>(),
        clock: getIt<Clock>(),
      ),
    );
}
