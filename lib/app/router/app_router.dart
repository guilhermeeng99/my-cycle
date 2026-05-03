import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:mycycle/app/di/injection_container.dart';
import 'package:mycycle/app/router/go_router_refresh_stream.dart';
import 'package:mycycle/app/router/routes.dart';
import 'package:mycycle/core/clock/clock.dart';
import 'package:mycycle/core/notifications/notifications_repository.dart';
import 'package:mycycle/features/auth/domain/auth_state.dart';
import 'package:mycycle/features/auth/domain/repositories/auth_repository.dart';
import 'package:mycycle/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:mycycle/features/auth/presentation/pages/sign_in_page.dart';
import 'package:mycycle/features/auth/presentation/pages/splash_page.dart';
import 'package:mycycle/features/calendar/presentation/cubits/calendar_cubit.dart';
import 'package:mycycle/features/calendar/presentation/pages/calendar_page.dart';
import 'package:mycycle/features/cycle/domain/repositories/cycle_repository.dart';
import 'package:mycycle/features/cycle/domain/repositories/day_log_repository.dart';
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
import 'package:mycycle/features/today/presentation/cubits/today_cubit.dart';
import 'package:mycycle/features/today/presentation/pages/today_page.dart';

/// Auth-aware [GoRouter].
class AppRouter {
  AppRouter(this._authCubit) {
    _refreshListenable = GoRouterRefreshStream(_authCubit.stream);
    _router = GoRouter(
      initialLocation: AppRoutes.splash,
      refreshListenable: _refreshListenable,
      redirect: _redirect,
      routes: <RouteBase>[
        GoRoute(
          path: AppRoutes.splash,
          builder: (_, _) => const SplashPage(),
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
          path: AppRoutes.home,
          builder: _buildHome,
        ),
        GoRoute(
          path: AppRoutes.calendar,
          builder: _buildCalendar,
        ),
        GoRoute(
          path: AppRoutes.settings,
          builder: _buildSettings,
        ),
      ],
    );
  }

  final AuthCubit _authCubit;
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
    final authState = _authCubit.state;

    if (authState is AuthStateUnknown) {
      return loc == AppRoutes.splash ? null : AppRoutes.splash;
    }
    if (authState is AuthStateUnauthenticated) {
      return loc == AppRoutes.signIn ? null : AppRoutes.signIn;
    }

    final user = (authState as AuthStateAuthenticated).user;

    if (!user.isPaired) {
      const allowed = <String>{
        AppRoutes.pairingChoice,
        AppRoutes.ownerOnboarding,
        AppRoutes.partnerPairing,
      };
      return allowed.contains(loc) ? null : AppRoutes.pairingChoice;
    }

    // Paired — keep them out of the pre-home flow.
    const preHome = <String>{
      AppRoutes.splash,
      AppRoutes.signIn,
      AppRoutes.pairingChoice,
      AppRoutes.ownerOnboarding,
      AppRoutes.partnerPairing,
    };
    return preHome.contains(loc) ? AppRoutes.home : null;
  }
}
