import 'dart:async';

import 'package:flutter/foundation.dart';

/// Bridges a [Stream] to a [Listenable] for `go_router`'s `refreshListenable`.
///
/// Notifies listeners on every event (and once on construction) so the router
/// re-evaluates its redirect whenever auth state changes.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
