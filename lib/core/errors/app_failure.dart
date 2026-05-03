/// Root of all domain failures in MyCycle.
///
/// Concrete subclasses live next to the feature that owns them, e.g.
/// `lib/features/auth/domain/failures/auth_failure.dart`. UI strings come
/// from slang — [debugMessage] is for logs, never for end-user display.
///
/// Per-feature failure groups seal their own hierarchies (e.g. `AuthFailure`),
/// so callers still get exhaustive pattern matching within a feature.
abstract class AppFailure {
  const AppFailure();

  String get debugMessage;
}
