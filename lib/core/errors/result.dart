import 'package:mycycle/core/errors/app_failure.dart';

/// Sealed result type for repository methods.
///
/// Use Dart 3 pattern matching to handle both branches:
/// ```dart
/// switch (result) {
///   case Ok(:final value): handleSuccess(value);
///   case Err(error: GoogleSignInCancelled()): handleCancel();
///   case Err(:final error): handleOther(error);
/// }
/// ```
sealed class Result<T> {
  const Result();

  bool get isOk => this is Ok<T>;
  bool get isErr => this is Err<T>;
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;
}

final class Err<T> extends Result<T> {
  const Err(this.error);
  final AppFailure error;
}
