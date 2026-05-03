import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:mycycle/app/di/injection_container.dart';
import 'package:mycycle/app/router/app_router.dart';
import 'package:mycycle/app/theme/app_theme.dart';
import 'package:mycycle/core/entities/user.dart';
import 'package:mycycle/features/auth/domain/auth_state.dart';
import 'package:mycycle/features/auth/domain/repositories/auth_repository.dart';
import 'package:mycycle/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:mycycle/gen/i18n/strings.g.dart';

class MyCycleApp extends StatefulWidget {
  const MyCycleApp({super.key});

  @override
  State<MyCycleApp> createState() => _MyCycleAppState();
}

class _MyCycleAppState extends State<MyCycleApp> {
  late final AuthCubit _authCubit;
  late final AppRouter _router;
  StreamSubscription<AuthState>? _localeSyncSub;

  @override
  void initState() {
    super.initState();
    _authCubit = AuthCubit(repository: getIt<AuthRepository>());
    _router = AppRouter(_authCubit);
    _localeSyncSub = _authCubit.stream.listen(_syncLocaleToUser);
  }

  // Apply the signed-in user's saved language to the running app. Without this
  // every cold start defaults to the device locale (set in main()), which
  // silently overrides whatever the user picked in settings.
  void _syncLocaleToUser(AuthState authState) {
    if (authState is! AuthStateAuthenticated) return;
    final desired = authState.user.language == AppLanguage.en
        ? AppLocale.en
        : AppLocale.ptBr;
    if (LocaleSettings.currentLocale == desired) return;
    unawaited(LocaleSettings.setLocale(desired));
  }

  @override
  void dispose() {
    unawaited(_localeSyncSub?.cancel());
    _router.dispose();
    unawaited(_authCubit.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>.value(
      value: _authCubit,
      child: MaterialApp.router(
        title: 'MyCycle',
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        locale: TranslationProvider.of(context).flutterLocale,
        supportedLocales: AppLocaleUtils.supportedLocales,
        localizationsDelegates: const <LocalizationsDelegate<Object>>[
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        routerConfig: _router.router,
      ),
    );
  }
}
