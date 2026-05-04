import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive_ce/hive.dart';

import 'package:mycycle/app/theme/theme_cubit.dart';
import 'package:mycycle/core/clock/clock.dart';
import 'package:mycycle/core/entities/couple.dart';
import 'package:mycycle/core/entities/cycle.dart';
import 'package:mycycle/core/entities/user.dart';
import 'package:mycycle/core/hive/box_names.dart';
import 'package:mycycle/core/hive/cache_serializers.dart';
import 'package:mycycle/core/hive/hive_doc_cache.dart';
import 'package:mycycle/core/hive/hive_initializer.dart';
import 'package:mycycle/core/notifications/notifications_coordinator.dart';
import 'package:mycycle/core/notifications/notifications_repository.dart';
import 'package:mycycle/core/notifications/notifications_repository_impl.dart';
import 'package:mycycle/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:mycycle/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:mycycle/features/auth/domain/repositories/auth_repository.dart';
import 'package:mycycle/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:mycycle/features/biometric/data/repositories/biometric_repository_impl.dart';
import 'package:mycycle/features/biometric/domain/repositories/biometric_repository.dart';
import 'package:mycycle/features/biometric/presentation/cubits/biometric_lock_cubit.dart';
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
import 'package:mycycle/features/startup/presentation/cubits/startup_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GetIt getIt = GetIt.instance;

/// OAuth 2.0 Web client ID from `android/app/google-services.json`
/// (`oauth_client[client_type=3]`). Required by Google Sign-In so the ID
/// token it returns is signed for our Firebase project. Public per OAuth
/// design — security comes from package + SHA-1 restrictions in Cloud
/// Console.
const String _googleSignInServerClientId =
    '1071997209882-mjsv5ursdqt3nd56u6adprbpiae6503d.apps.googleusercontent.com';

/// Wires up the app's dependency graph.
///
/// Call once from `main()` after `Firebase.initializeApp()`. Performs the
/// async setup that the dependency graph needs (Google Sign-In, prefs,
/// device locale) before registering singletons.
Future<void> initDependencies() async {
  await GoogleSignIn.instance.initialize(
    serverClientId: _googleSignInServerClientId,
  );
  await initHive();
  final prefs = await SharedPreferences.getInstance();

  final userCache = HiveDocCache<User>(
    box: Hive.box<String>(HiveBoxes.users),
    toJson: CacheSerializers.userToJson,
    fromJson: CacheSerializers.userFromJson,
  );
  final coupleCache = HiveDocCache<Couple>(
    box: Hive.box<String>(HiveBoxes.couples),
    toJson: CacheSerializers.coupleToJson,
    fromJson: CacheSerializers.coupleFromJson,
  );
  final recentCyclesCache = HiveDocCache<List<Cycle>>(
    box: Hive.box<String>(HiveBoxes.cycles),
    toJson: CacheSerializers.cyclesListToJson,
    fromJson: CacheSerializers.cyclesListFromJson,
  );

  getIt
    // External singletons
    ..registerLazySingleton<SharedPreferences>(() => prefs)
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
        userCache: userCache,
        onSignOut: clearAllCaches,
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
      () => CycleRemoteDataSourceImpl(firestore: getIt<FirebaseFirestore>()),
    )
    ..registerLazySingleton<CycleRepository>(
      () => CycleRepositoryImpl(
        remote: getIt<CycleRemoteDataSource>(),
        clock: getIt<Clock>(),
        recentCyclesCache: recentCyclesCache,
      ),
    )
    ..registerLazySingleton<DayLogRemoteDataSource>(
      () => DayLogRemoteDataSourceImpl(firestore: getIt<FirebaseFirestore>()),
    )
    ..registerLazySingleton<DayLogRepository>(
      () => DayLogRepositoryImpl(
        remote: getIt<DayLogRemoteDataSource>(),
        clock: getIt<Clock>(),
      ),
    )
    // Pairing / couple feature
    ..registerLazySingleton<CoupleRemoteDataSource>(
      () => CoupleRemoteDataSourceImpl(firestore: getIt<FirebaseFirestore>()),
    )
    ..registerLazySingleton<CoupleRepository>(
      () => CoupleRepositoryImpl(
        remote: getIt<CoupleRemoteDataSource>(),
        clock: getIt<Clock>(),
        coupleCache: coupleCache,
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
    )
    // Global cubits — singletons so any screen can reach them via context.
    ..registerLazySingleton<ThemeCubit>(
      () => ThemeCubit(prefs: getIt<SharedPreferences>()),
    )
    ..registerLazySingleton<AuthCubit>(
      () => AuthCubit(repository: getIt<AuthRepository>()),
    )
    ..registerLazySingleton<StartupCubit>(
      () => StartupCubit(authCubit: getIt<AuthCubit>()),
    )
    ..registerLazySingleton<BiometricRepository>(
      BiometricRepositoryImpl.new,
    )
    ..registerLazySingleton<BiometricLockCubit>(
      () => BiometricLockCubit(
        authCubit: getIt<AuthCubit>(),
        biometricRepository: getIt<BiometricRepository>(),
        clock: getIt<Clock>(),
      ),
    );
}
