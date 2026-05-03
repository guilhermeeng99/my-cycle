/// Centralized route paths.
///
/// Routes split into two flows:
///   - **Pre-home flow**: splash, sign-in, pairing/onboarding gates
///   - **Shell flow**: paired users live inside a `StatefulShellRoute` with
///     tabs (Today, Calendar, Insights, Settings)
abstract final class AppRoutes {
  static const String splash = '/';
  static const String signIn = '/sign-in';
  static const String pairingChoice = '/pairing-choice';
  static const String ownerOnboarding = '/onboarding/owner';
  static const String partnerPairing = '/pairing/redeem';
  static const String biometricLock = '/biometric-lock';

  // Shell tabs
  static const String home = '/home';
  static const String calendar = '/calendar';
  static const String insights = '/insights';
  static const String settings = '/settings';
}
