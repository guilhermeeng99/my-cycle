/// Hive box names — kept here so repositories don't sprinkle string
/// literals across the codebase.
///
/// All boxes hold JSON-encoded documents (`Box<String>`). Keyed by Firestore
/// document id. We deliberately avoid `@HiveType` codegen — JSON via
/// `dart:convert` is enough for documents this size and keeps the build
/// pipeline simpler.
abstract final class HiveBoxes {
  static const String users = 'users';
  static const String couples = 'couples';

  /// Recent cycles list per couple, keyed by `coupleId`. Stores the result
  /// of `CycleRepository.watchRecentCycles` as a JSON-encoded list.
  static const String cycles = 'cycles';

  /// Generic key/value box for per-app metadata (cache versions, last-sync
  /// timestamps, etc.). Use sparingly — feature data belongs in its own box.
  static const String meta = 'meta';

  static const List<String> all = <String>[users, couples, cycles, meta];
}
