# Biometric Lock — Specification

> Status: draft v1 · Owner: @guiga · Last updated: 2026-05-03

A privacy gate layered **on top** of authentication. When enabled, the app
demands a Face ID / fingerprint check on resume after a configurable idle
window. Three failed attempts force a sign-out.

This is a deliberate "small but loud" privacy feature: the app already
encrypts data via Firestore Rules, but cycle data is sensitive enough that
a phone-level passcode bypass shouldn't be enough to read it.

---

## Goals

- Optional, opt-in. Hidden from users on devices without biometrics.
- Non-blocking on cold start when disabled — the gate has no cost.
- Recoverable: a forgotten biometric falls back to Google re-auth, never
  to a "you lost your data" message.

Non-goals: PIN/password fallback (out of scope for v1, OS already provides
one in the system biometric prompt).

---

## Public surface

- **Settings → Security**: a single switch (`Biometric lock`).
- **`/biometric-lock` route**: full-screen gate; auto-prompts on enter and
  shows an "Unlock" button + remaining-attempts hint after a failure.

The gate UI does not navigate manually — once the cubit emits
`BiometricLockUnlocked`, the router redirect kicks in.

---

## Business rules

| # | Rule |
|---|---|
| BR-1 | The toggle is **hidden** when `BiometricRepository.isAvailable()` returns false (no hardware, no enrollment, unsupported platform). |
| BR-2 | Toggling on persists `users/{uid}.biometricEnabled = true` via `SettingsCubit.setBiometricEnabled`. Toggling off persists `false`. |
| BR-3 | The lock is evaluated only on **resume** (transition from `paused`/`inactive`/`hidden` to `resumed`). Background notifications, time changes, and similar do not trigger it. |
| BR-4 | Idle threshold is 5 minutes by default. The cubit accepts an `idleThreshold` parameter for testability. |
| BR-5 | Three consecutive failed attempts emit `BiometricLockForcedSignOut` and call `AuthCubit.signOut()`. The router then routes to `/sign-in`. |
| BR-6 | Successful unlock resets the failure counter to zero. |
| BR-7 | When auth flips to `Unauthenticated` mid-flow, the cubit drops back to `Unlocked` and clears state. |
| BR-8 | The cubit never holds onto sensitive data — it observes auth and biometric repository only. |

---

## State machine — `BiometricLockCubit`

```
[Unlocked]
  ── onAppPaused → recordTimestamp
  ── onAppResumed (biometricEnabled && idle≥threshold) → [Locked(remaining=3)]
  ── lock() (biometricEnabled) → [Locked(remaining=3)]

[Locked(remaining)]
  ── unlock() ok=true → [Unlocked]
  ── unlock() ok=false || error
       └── remaining > 1 → [Locked(remaining-1)]
       └── remaining == 1 → [ForcedSignOut] (also fires authCubit.signOut)

[ForcedSignOut]
  └── auth flips to Unauthenticated → [Unlocked]   (clean slate)
```

---

## Repository contract

```dart
abstract class BiometricRepository {
  Future<bool> isAvailable();
  Future<Result<bool>> authenticate({required String reason});
  // Ok(true)  — user authenticated
  // Ok(false) — user dismissed; counts toward failure budget
  // Err(BiometricUnavailable | BiometricCancelled | BiometricPlatformFailure)
}
```

The implementation wraps `local_auth` so the rest of the app never imports
that package directly. `AuthenticationOptions` are set to:

- `biometricOnly: true` — system passcode is rejected; the user must use
  Face ID or fingerprint.
- `persistAcrossBackgrounding: true` — backgrounding doesn't reset the
  prompt (matches the OS expectation; the app may be suspended while the
  prompt is up).

---

## Lifecycle integration

`MyCycleApp` registers the root state widget as a `WidgetsBindingObserver`
and forwards `didChangeAppLifecycleState`:

```dart
case AppLifecycleState.paused:
case AppLifecycleState.inactive:
case AppLifecycleState.hidden:
  lock.onAppPaused();
case AppLifecycleState.resumed:
  lock.onAppResumed();
```

The router `redirect` adds a single rule:

```dart
if (_lockCubit.state is BiometricLockLocked) {
  return loc == AppRoutes.biometricLock ? null : AppRoutes.biometricLock;
}
```

`GoRouterRefreshStream.fromStreams` includes the lock cubit's stream, so
the redirect re-evaluates when the lock state flips.

---

## Edge cases

1. **Device has biometrics but none enrolled** — `isAvailable()` returns false; toggle hidden. Same as no hardware.
2. **User disables biometrics in OS while the app is locked** — the next `unlock()` returns `BiometricUnavailable`, counts as a strike. After 3 strikes the user is signed out and can re-authenticate via Google.
3. **App killed while locked** — on relaunch, the lock state is **not** persisted; the user goes through Startup → auth check → home (no lock prompt). This is a deliberate trade-off: the gate is for "I left the phone unlocked on the table", not "thief stole my phone". For the latter, the OS-level lockscreen is the boundary.
4. **Time set backwards on the device** — `_clock.now().difference(backgroundedAt)` becomes negative; the threshold check fails, no lock. Acceptable: clock skew this large is very rare and a "soft fail open" is safer than a "false lock that the user can't escape."
5. **Idle threshold of zero** — for tests; passes immediately on resume.

---

## Test plan

- Initial state is `Unlocked`.
- With `biometricEnabled=false`, idle past threshold does NOT lock.
- With `biometricEnabled=true` and idle ≥ threshold on resume → `Locked`.
- With `biometricEnabled=true` and idle < threshold → still `Unlocked`.
- Successful unlock returns to `Unlocked`.
- Three failures emit `ForcedSignOut` AND call `AuthCubit.signOut()` exactly once.
- Auth flipping to `Unauthenticated` clears the lock state.
