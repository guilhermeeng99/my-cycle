import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:mycycle/app/di/injection_container.dart';
import 'package:mycycle/app/router/app_router.dart';
import 'package:mycycle/app/theme/app_theme.dart';
import 'package:mycycle/app/theme/theme_cubit.dart';
import 'package:mycycle/core/entities/user.dart';
import 'package:mycycle/features/auth/domain/auth_state.dart';
import 'package:mycycle/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:mycycle/features/biometric/presentation/cubits/biometric_lock_cubit.dart';
import 'package:mycycle/features/startup/presentation/cubits/startup_cubit.dart';
import 'package:mycycle/gen/i18n/strings.g.dart';

class MyCycleApp extends StatefulWidget {
  const MyCycleApp({super.key});

  @override
  State<MyCycleApp> createState() => _MyCycleAppState();
}

class _MyCycleAppState extends State<MyCycleApp> with WidgetsBindingObserver {
  late final AppRouter _router;
  late final StreamSubscription<AuthState> _localeSyncSub;
  late final StreamSubscription<BiometricLockState> _lockSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _router = AppRouter(
      authCubit: getIt<AuthCubit>(),
      startupCubit: getIt<StartupCubit>(),
      biometricLockCubit: getIt<BiometricLockCubit>(),
    );
    _localeSyncSub = getIt<AuthCubit>().stream.listen(_syncLocaleToUser);
    // The router redirect needs to re-run on lock-state changes too.
    _lockSub = getIt<BiometricLockCubit>().stream.listen((_) {});
  }

  void _syncLocaleToUser(AuthState authState) {
    if (authState is! AuthStateAuthenticated) return;
    final desired = authState.user.language == AppLanguage.en
        ? AppLocale.en
        : AppLocale.ptBr;
    if (LocaleSettings.currentLocale == desired) return;
    unawaited(LocaleSettings.setLocale(desired));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final lock = getIt<BiometricLockCubit>();
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        lock.onAppPaused();
      case AppLifecycleState.resumed:
        lock.onAppResumed();
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_localeSyncSub.cancel());
    unawaited(_lockSub.cancel());
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: <BlocProvider<Object?>>[
        BlocProvider<ThemeCubit>.value(value: getIt<ThemeCubit>()),
        BlocProvider<AuthCubit>.value(value: getIt<AuthCubit>()),
        BlocProvider<StartupCubit>.value(value: getIt<StartupCubit>()),
        BlocProvider<BiometricLockCubit>.value(
          value: getIt<BiometricLockCubit>(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp.router(
            title: 'MyCycle',
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: themeMode,
            locale: TranslationProvider.of(context).flutterLocale,
            supportedLocales: AppLocaleUtils.supportedLocales,
            localizationsDelegates: const <LocalizationsDelegate<Object>>[
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            routerConfig: _router.router,
          );
        },
      ),
    );
  }
}
