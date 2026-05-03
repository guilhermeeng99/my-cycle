import 'package:mycycle/core/entities/user.dart';
import 'package:mycycle/core/errors/result.dart';

/// Owns the post-sign-in setup flow.
///
/// `completeOwnerOnboarding` writes user doc + couple doc + first cycle in a
/// single Firestore transaction. After it completes, the AuthCubit's reactive
/// stream picks up the new user doc and the router redirects to /home.
abstract class OnboardingRepository {
  Future<Result<void>> completeOwnerOnboarding({
    required String userId,
    required String name,
    required String email,
    required DateTime lastPeriodStart,
    required int defaultCycleLength,
    required bool notificationsEnabled,
    required AppLanguage language,
    String? photoUrl,
  });
}
