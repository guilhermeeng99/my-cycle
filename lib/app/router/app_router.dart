import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:mycycle/app/di/injection_container.dart';
import 'package:mycycle/app/router/go_router_refresh_stream.dart';
import 'package:mycycle/app/router/routes.dart';
import 'package:mycycle/app/widgets/bloom_bottom_nav.dart';
import 'package:mycycle/core/clock/clock.dart';
import 'package:mycycle/core/notifications/notifications_repository.dart';
import 'package:mycycle/features/auth/domain/auth_state.dart';
import 'package:mycycle/features/auth/domain/repositories/auth_repository.dart';
import 'package:mycycle/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:mycycle/features/auth/presentation/pages/sign_in_page.dart';
import 'package:mycycle/features/auth/presentation/pages/splash_page.dart';
import 'package:mycycle/features/biometric/presentation/cubits/biometric_lock_cubit.dart';
import 'package:mycycle/features/biometric/presentation/pages/biometric_lock_page.dart';
import 'package:mycycle/features/calendar/presentation/cubits/calendar_cubit.dart';
import 'package:mycycle/features/calendar/presentation/pages/calendar_page.dart';
import 'package:mycycle/features/cycle/domain/repositories/cycle_repository.dart';
import 'package:mycycle/features/cycle/domain/repositories/day_log_repository.dart';
import 'package:mycycle/features/insights/presentation/cubits/insights_cubit.dart';
import 'package:mycycle/features/insights/presentation/pages/insights_page.dart';
import 'package:mycycle/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:mycycle/features/onboarding/presentation/cubits/owner_onboarding_cubit.dart';
import 'package:mycycle/features/onboarding/presentation/pages/owner_onboarding_page.dart';
import 'package:mycycle/features/pairing/domain/repositories/couple_repository.dart';
import 'package:mycycle/features/pairing/presentation/cubits/partner_pairing_cubit.dart';
import 'package:mycycle/features/pairing/presentation/pages/pairing_choice_page.dart';
import 'package:mycycle/features/pairing/presentation/pages/partner_pairing_page.dart';
import 'package:mycycle/features/settings/domain/repositories/settings_repository.dart';
import 'package:mycycle/features/settings/presentation/cubits/settings_cubit.dart';
import 'package:mycycle/features/settings/presentation/pages/settings_page.dart';
import 'package:mycycle/features/startup/presentation/cubits/startup_cubit.dart';
import 'package:mycycle/features/startup/presentation/pages/startup_page.dart';
import 'package:mycycle/features/today/presentation/cubits/today_cubit.dart';
import 'package:mycycle/features/today/presentation/pages/today_page.dart';

/// Auth-aware [GoRouter] with a four-tab shell for paired users.
///
/// Pre-home routes (splash, sign-in, pairing/onboarding gates) live at the
/// top level. Once a user is authenticated and paired, navigation lands
/// inside a [StatefulShellRoute.indexedStack] so each tab keeps its own
/// stack and the bottom nav stays mounted across switches.
class AppRouter {
  AppRouter({
    required AuthCubit authCubit,
    required StartupCubit startupCubit,
    required BiometricLockCubit biometricLockCubit,
  }) : _authCubit = authCubit,
       _startupCubit = startupCubit,
       _lockCubit = biometricLockCubit {
    _refreshListenable = GoRouterRefreshStream.fromStreams(<Stream<Object?>>[
      _authCubit.stream,
      _startupCubit.stream,
      _lockCubit.stream,
    ]);
    _router = GoRouter(
      initialLocation: AppRoutes.splash,
      refreshListenable: _refreshListenable,
      redirect: _redirect,
      routes: <RouteBase>[
        GoRoute(
          path: AppRoutes.splash,
          builder: (_, _) => const StartupPage(),
        ),
        GoRoute(
          path: AppRoutes.signIn,
          builder: (_, _) => const SignInPage(),
        ),
        GoRoute(
          path: AppRoutes.pairingChoice,
          builder: (_, _) => const PairingChoicePage(),
        ),
        GoRoute(
          path: AppRoutes.ownerOnboarding,
          builder: _buildOwnerOnboarding,
        ),
        GoRoute(
          path: AppRoutes.partnerPairing,
          builder: _buildPartnerPairing,
        ),
        GoRoute(
          path: AppRoutes.biometricLock,
          builder: (_, _) => const BiometricLockPage(),
        ),
        StatefulShellRoute.indexedStack(
          builder: (_, _, shell) => ShellScaffold(shell: shell),
          branches: <StatefulShellBranch>[
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(path: AppRoutes.home, builder: _buildHome),
              ],
            ),
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(path: AppRoutes.calendar, builder: _buildCalendar),
              ],
            ),
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(path: AppRoutes.insights, builder: _buildInsights),
              ],
            ),
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(path: AppRoutes.settings, builder: _buildSettings),
              ],
            ),
          ],
        ),
      ],
    );
  }

  final AuthCubit _authCubit;
  final StartupCubit _startupCubit;
  final BiometricLockCubit _lockCubit;
  late final GoRouter _router;
  late final GoRouterRefreshStream _refreshListenable;

  GoRouter get router => _router;

  void dispose() {
    _refreshListenable.dispose();
  }

  Widget _buildHome(BuildContext context, GoRouterState state) {
    final authState = _authCubit.state;
    if (authState is! AuthStateAuthenticated) return const SplashPage();
    final user = authState.user;
    return BlocProvider<TodayCubit>(
      create: (_) => TodayCubit(
        user: user,
        cycleRepository: getIt<CycleRepository>(),
        coupleRepository: getIt<CoupleRepository>(),
        clock: getIt<Clock>(),
      ),
      child: const TodayPage(),
    );
  }

  Widget _buildCalendar(BuildContext context, GoRouterState state) {
    final authState = _authCubit.state;
    if (authState is! AuthStateAuthenticated) return const SplashPage();
    final coupleId = authState.user.coupleId;
    if (coupleId == null) return const SplashPage();
    return BlocProvider<CalendarCubit>(
      create: (_) => CalendarCubit(
        coupleId: coupleId,
        cycleRepository: getIt<CycleRepository>(),
        dayLogRepository: getIt<DayLogRepository>(),
        coupleRepository: getIt<CoupleRepository>(),
        clock: getIt<Clock>(),
      ),
      child: CalendarPage(coupleId: coupleId),
    );
  }

  Widget _buildInsights(BuildContext context, GoRouterState state) {
    final authState = _authCubit.state;
    if (authState is! AuthStateAuthenticated) return const SplashPage();
    final coupleId = authState.user.coupleId;
    if (coupleId == null) return const SplashPage();
    return BlocProvider<InsightsCubit>(
      create: (_) => InsightsCubit(
        coupleId: coupleId,
        cycleRepository: getIt<CycleRepository>(),
        coupleRepository: getIt<CoupleRepository>(),
        clock: getIt<Clock>(),
      ),
      child: const InsightsPage(),
    );
  }

  Widget _buildSettings(BuildContext context, GoRouterState state) {
    final authState = _authCubit.state;
    if (authState is! AuthStateAuthenticated) return const SplashPage();
    return BlocProvider<SettingsCubit>(
      create: (_) => SettingsCubit(
        initialUser: authState.user,
        settingsRepository: getIt<SettingsRepository>(),
        coupleRepository: getIt<CoupleRepository>(),
        authRepository: getIt<AuthRepository>(),
        notificationsRepository: getIt<NotificationsRepository>(),
      ),
      child: const SettingsPage(),
    );
  }

  Widget _buildOwnerOnboarding(BuildContext context, GoRouterState state) {
    final authState = _authCubit.state;
    if (authState is! AuthStateAuthenticated) return const SplashPage();
    final user = authState.user;
    return BlocProvider<OwnerOnboardingCubit>(
      create: (_) => OwnerOnboardingCubit(
        repository: getIt<OnboardingRepository>(),
        userId: user.id,
        userName: user.name,
        userEmail: user.email,
        userPhotoUrl: user.photoUrl,
        initialLanguage: user.language,
      ),
      child: const OwnerOnboardingPage(),
    );
  }

  Widget _buildPartnerPairing(BuildContext context, GoRouterState state) {
    final authState = _authCubit.state;
    if (authState is! AuthStateAuthenticated) return const SplashPage();
    return BlocProvider<PartnerPairingCubit>(
      create: (_) => PartnerPairingCubit(
        coupleRepository: getIt<CoupleRepository>(),
        partnerId: authState.user.id,
      ),
      child: const PartnerPairingPage(),
    );
  }

  String? _redirect(BuildContext context, GoRouterState state) {
    final loc = state.matchedLocation;
    final startupState = _startupCubit.state;
    final authState = _authCubit.state;

    final startupDone =
        startupState is StartupAuthenticated ||
        startupState is StartupUnauthenticated;
    if (!startupDone) {
      return loc == AppRoutes.splash ? null : AppRoutes.splash;
    }

    if (authState is AuthStateUnauthenticated) {
      return loc == AppRoutes.signIn ? null : AppRoutes.signIn;
    }

    if (authState is! AuthStateAuthenticated) {
      return loc == AppRoutes.splash ? null : AppRoutes.splash;
    }

    // Biometric gate: any locked state parks the user on the lock page
    // until they unlock or get force-signed-out.
    if (_lockCubit.state is BiometricLockLocked) {
      return loc == AppRoutes.biometricLock ? null : AppRoutes.biometricLock;
    }

    final user = authState.user;

    if (!user.isPaired) {
      const allowed = <String>{
        AppRoutes.pairingChoice,
        AppRoutes.ownerOnboarding,
        AppRoutes.partnerPairing,
      };
      return allowed.contains(loc) ? null : AppRoutes.pairingChoice;
    }

    const preHome = <String>{
      AppRoutes.splash,
      AppRoutes.signIn,
      AppRoutes.pairingChoice,
      AppRoutes.ownerOnboarding,
      AppRoutes.partnerPairing,
      AppRoutes.biometricLock,
    };
    return preHome.contains(loc) ? AppRoutes.home : null;
  }
}
