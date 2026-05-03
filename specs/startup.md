# Startup — Specification

> Status: draft v1 · Owner: @guiga · Last updated: 2026-05-03

Sequences cold-start work between Firebase init and the first interactive screen. Owns the splash UI and gates the router redirect.

---

## Why a dedicated cubit

Without an explicit startup phase, every screen has to defend against "auth is still resolving" and "Hive cache is still empty." Splitting it out means:

- The **router redirect** has a single boolean — "is startup done?" — instead of decoding partial states.
- The **splash UI** can show real progress (auth check, cache warmup, sync) instead of a parked spinner.
- Future initialization steps (Hive box hydration, Firestore prefetch, biometric gate) plug in here without touching feature code.

The `AuthCubit` resolves on its own via the Firebase auth stream; `StartupCubit` is the orchestrator that *waits* for that resolution and then runs whatever needs to run before home is rendered.

---

## State machine — `StartupCubit`

```
[Initial] ──initialize()──> [Loading(progress: 0.2)]
                              │
                              ▼
                            wait for AuthCubit to leave Unknown
                              │
                              ▼
                          [Loading(progress: 0.7)]
                              │
                ┌─────────────┴─────────────┐
                ▼                           ▼
       [Authenticated]              [Unauthenticated]
```

Today only auth resolution gates the transition. Future hooks slot into the `Loading(progress: 0.7)` window before the terminal state is emitted.

`initialize()` is idempotent — calling it again from a non-`Initial` state is a no-op.

---

## Public API

```dart
class StartupCubit extends Cubit<StartupState> {
  StartupCubit({required AuthCubit authCubit});
  Future<void> initialize();
}

sealed class StartupState {}
final class StartupInitial extends StartupState {}
final class StartupLoading extends StartupState {
  final double progress;       // 0..1
}
final class StartupAuthenticated extends StartupState {}
final class StartupUnauthenticated extends StartupState {}
```

Registered as a DI singleton. `StartupPage.initState` posts a frame callback that calls `initialize()` once.

---

## Router integration

The `AppRouter` redirect short-circuits to the splash route until startup emits a terminal state:

```dart
final startupDone =
    startupState is StartupAuthenticated ||
    startupState is StartupUnauthenticated;
if (!startupDone) return AppRoutes.splash;
```

`GoRouterRefreshStream.fromStreams([authCubit.stream, startupCubit.stream])` re-evaluates the redirect on emissions from either cubit.

---

## Splash UI

`StartupPage` shows the app wordmark and a thin `LinearProgressIndicator`:

- `Initial` → indeterminate
- `Loading(progress)` → determinate at the given progress
- Terminal states → router redirect kicks in and replaces the page; the UI is never seen long enough to render the terminal state visually

---

## Edge cases

1. **Firebase already has a session on cold start** — `AuthCubit` emits `Authenticated` synchronously; `_waitForAuth()` returns immediately. Splash is gone in one frame.
2. **No session, never signed in** — `AuthCubit` emits `Unauthenticated` after the Firebase auth check; `StartupCubit` emits `Unauthenticated`; redirect routes to `/sign-in`.
3. **`initialize()` called twice** — second call is a no-op (early return when state is not `Initial`).
4. **Auth state flips during startup** — `_waitForAuth()` completes on the first non-`Unknown` emission and unsubscribes; later flips are ignored by the cubit (auth-state-driven navigation takes over via the router redirect).
5. **Future: initial work fails (e.g., Hive open)** — emit a `StartupError(message)` state and add a retry path. Not implemented yet.

---

## Test plan

- Initial state is `StartupInitial`.
- `initialize()` from `Authenticated` auth state emits `Loading → Authenticated`.
- `initialize()` from `Unauthenticated` auth state emits `Loading → Unauthenticated`.
- `initialize()` while `Unknown`, then auth resolves to `Authenticated`, emits `Loading → Authenticated`.
- Calling `initialize()` twice does not re-emit.
