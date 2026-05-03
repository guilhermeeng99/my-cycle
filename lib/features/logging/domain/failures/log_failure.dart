import 'package:mycycle/core/errors/app_failure.dart';

sealed class LogFailure extends AppFailure {
  const LogFailure();
}

final class LogValidationFailure extends LogFailure {
  const LogValidationFailure(this.field, this.reason);
  final String field;
  final String reason;
  @override
  String get debugMessage => 'Log validation failed on $field: $reason';
}

final class LogNetworkFailure extends LogFailure {
  const LogNetworkFailure();
  @override
  String get debugMessage => 'Network error during log save';
}

final class LogStorageFailure extends LogFailure {
  const LogStorageFailure(this.code, this.message);
  final String code;
  final String message;
  @override
  String get debugMessage => 'Log storage error [$code]: $message';
}

final class UnknownLogFailure extends LogFailure {
  const UnknownLogFailure(this.cause);
  final Object cause;
  @override
  String get debugMessage => 'Unknown log failure: $cause';
}
