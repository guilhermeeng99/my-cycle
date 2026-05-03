import 'dart:async';

import 'package:flutter/foundation.dart';

/// Bridges one or more [Stream]s to a [Listenable] for `go_router`'s
/// `refreshListenable`.
///
/// Notifies listeners on every event from any source stream (and once on
/// construction) so the router re-evaluates its redirect whenever any of
/// the wired-up cubits/blocs emit.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<Object?> stream) : this.fromStreams([stream]);

  GoRouterRefreshStream.fromStreams(List<Stream<Object?>> streams) {
    notifyListeners();
    _subscriptions = streams
        .map((s) => s.asBroadcastStream().listen((_) => notifyListeners()))
        .toList(growable: false);
  }

  late final List<StreamSubscription<Object?>> _subscriptions;

  @override
  void dispose() {
    for (final sub in _subscriptions) {
      unawaited(sub.cancel());
    }
    super.dispose();
  }
}
