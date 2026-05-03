import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive_ce/hive.dart';

/// Generic write-through JSON cache for a single key inside a Hive box.
///
/// `T` may be a domain entity (`User`, `Couple`) or a list of them
/// (`List<Cycle>`) — anything whose `toJson` returns a JSON-encodable
/// `Object` (`Map`, `List`, primitives). Repositories use [merge] to expose
/// a `Stream<T?>` that emits the cached value first (synchronously, on
/// subscribe) and then forwards every remote emission while persisting it
/// back into Hive.
///
/// Stored on disk as raw JSON strings — no Hive type adapters, no codegen.
/// Documents are small and JSON is forgiving across schema migrations.
class HiveDocCache<T> {
  HiveDocCache({
    required Box<String> box,
    required Object Function(T) toJson,
    required T Function(Object) fromJson,
  }) : _box = box,
       _toJson = toJson,
       _fromJson = fromJson;

  final Box<String> _box;
  final Object Function(T) _toJson;
  final T Function(Object) _fromJson;

  T? read(String key) {
    final raw = _box.get(key);
    if (raw == null) return null;
    try {
      return _fromJson(jsonDecode(raw) as Object);
    } on Object catch (e, stack) {
      // Corrupt cache entry — drop it and move on. Better to fall through
      // to the live read than crash the app.
      debugPrint('HiveDocCache.read($key) corrupt: $e\n$stack');
      unawaited(_box.delete(key));
      return null;
    }
  }

  Future<void> write(String key, T value) {
    return _box.put(key, jsonEncode(_toJson(value)));
  }

  Future<void> delete(String key) => _box.delete(key);

  /// Yields the cached value first (if any), then every event from
  /// [remote], persisting each non-null event back into the cache.
  ///
  /// Implemented with an explicit [StreamController] (rather than `async*`)
  /// so subscription cancel is immediate — `async*` holds the awaited box
  /// reference through one extra microtask, which trips test teardowns
  /// that try to close the box right after `sub.cancel()`.
  Stream<T?> merge({required String key, required Stream<T?> remote}) {
    final controller = StreamController<T?>();
    StreamSubscription<T?>? sub;
    controller
      ..onListen = () {
        final cached = read(key);
        if (cached != null) controller.add(cached);
        sub = remote.listen(
          (v) async {
            if (v == null) {
              await delete(key);
            } else {
              await write(key, v);
            }
            if (!controller.isClosed) controller.add(v);
          },
          onError: controller.addError,
          onDone: controller.close,
        );
      }
      ..onCancel = () async {
        await sub?.cancel();
      };
    return controller.stream;
  }
}
