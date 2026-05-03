# Auth — Specification

> Status: draft v2 · Owner: @guiga · Last updated: 2026-05-03

Auth handles Firebase Auth + Google Sign-In. Required for any cycle-related action — both owner and partner must be signed in.

---

## Overview

Single sign-in method: **Google Sign-In** via `firebase_auth` + `google_sign_in`. No email/password. No anonymous mode. Personal app — both users have Google accounts.

The startup flow is sequenced by [`StartupCubit`](startup.md), which gates the redirect:

```
cold start
 │
 ▼
StartupPage  ←─── StartupCubit waits for auth resolution + initial work
 │
 ├── StartupUnauthenticated         → /sign-in
 │
 └── StartupAuthenticated
       ├── no users/{uid} doc           → owner onboarding
       ├── has user doc, coupleId null  → pairing choice
       └── has user doc, coupleId set   → /home
```

`AuthCubit` is registered as a DI singleton (`getIt<AuthCubit>()`) and provided at the root via `MultiBlocProvider`. Any screen can read it via `context.read<AuthCubit>()`.

Biometric lock is layered **on top** of the auth state: even when authenticated, the app re-asks for Face ID / fingerprint after 5 minutes of inactivity (opt-in).

---

## Business rules

| # | Rule |
|---|---|
| BR-1 | Only Google Sign-In is supported. No fallbacks. |
| BR-2 | First-time users (no `users/{uid}` doc) go to onboarding immediately after Firebase auth succeeds. |
| BR-3 | Returning users with a `coupleId` skip onboarding and pairing — go straight to `/today`. |
| BR-4 | Returning users without a `coupleId` go to the pairing flow (choose owner or partner role). |
| BR-5 | Sign-out wipes every Hive cache (`clearAllCaches`, wired via the `onSignOut` hook on `AuthRepositoryImpl`) and routes to `/sign-in`. |
| BR-6 | Account deletion: removes `users/{uid}` doc, dissolves or leaves the couple, revokes Firebase auth credential. **Two-step confirmation required.** |
| BR-7 | If the owner deletes their account, the couple is dissolved. The partner sees a "Couple ended" notice on next launch. |
| BR-8 | Biometric lock (Face ID / fingerprint) is opt-in via Settings. When enabled, app requires unlock on resume after 5 minutes of inactivity. |
| BR-9 | Biometric unlock failed 3 times → force full Google re-auth. |
| BR-10 | All authenticated routes are protected by the router redirect, which considers both `StartupState` and `AuthState`. Unauthenticated access redirects to `/sign-in`. |
| BR-11 | While `StartupState` is `Initial` or `Loading`, every navigation lands on the splash route (`/`). The redirect only branches on auth once startup has emitted a terminal state. |
| BR-12 | When [biometric lock](biometric.md) is enabled and the lock state is `Locked`, every navigation lands on `/biometric-lock` until unlock or forced sign-out. |
| BR-13 | `AuthRepositoryImpl` is wired with a `HiveDocCache<User>` (see [hive_cache.md](hive_cache.md)). On `watchAuthState`, the cached user is yielded synchronously before the live Firestore read so the splash hands off to home immediately. |

---

## Repository contract

```dart
abstract class AuthRepository {
  Stream<AuthState> watchAuthState();
  Future<Result<User>> signInWithGoogle();
  Future<Result<void>> signOut();
  Future<Result<void>> deleteAccount();
  Future<Result<User?>> getCurrentUser();
}

sealed class AuthState {
  const AuthState();
}
final class AuthStateUnknown extends AuthState {}            // initial, before first check
final class AuthStateUnauthenticated extends AuthState {}
final class AuthStateAuthenticated extends AuthState {
  const AuthStateAuthenticated(this.user);
  final User user;
}
```

The `User` entity:

| Field | Type | Notes |
|---|---|---|
| `id` | `String` | Firebase auth uid |
| `name` | `String` | from Google profile |
| `email` | `String` | |
| `photoUrl` | `String?` | |
| `coupleId` | `String?` | null until paired |
| `role` | `enum {owner, partner}?` | null until paired |
| `language` | `enum {en, ptBr}` | defaults to device locale |
| `biometricEnabled` | `bool` | default false |
| `createdAt` | `DateTime` | |
| `updatedAt` | `DateTime` | |

---

## State machine — `AuthCubit`

```
[Unknown] ──init──> [CheckingSession] ──ok──> [Authenticated(user)]
                                       └──no session──> [Unauthenticated]

[Unauthenticated] ──signInWithGoogle──> [SigningIn] ──ok──> [Authenticated(user)]
                                                    ├──cancelled──> [Unauthenticated]   // silent
                                                    └──error──> [Error(failure)] ──reset──> [Unauthenticated]

[Authenticated] ──signOut──> [SigningOut] ──> [Unauthenticated]
[Authenticated] ──deleteAccount──> [Deleting] ──> [Unauthenticated]
```

A separate `BiometricLockCubit` layers on top:

```
[Unlocked] ──appBackgroundedFor5min──> [Locked]
[Locked] ──unlock──> [Unlocking] ──ok──> [Unlocked]
                                  ├──fail (1-2)──> [Locked]
                                  └──fail (3)──> [ForcedSignOut]
```

---

## Edge cases

1. **Sign-in cancelled by user** → `Unauthenticated`, no error UI (deliberate cancel).
2. **Network error during sign-in** → `Error(NetworkFailure)`, retry button.
3. **Brand new Google account, first sign-in** → Firebase creates the auth record; we create `users/{uid}` doc lazily on first onboarding step.
4. **Sign-in on a second device** → reads existing `users/{uid}`, auto-rejoins existing couple via stored `coupleId`.
5. **Token refresh failure** → forces sign-out, routes to `/sign-in`. UI shows a soft "Please sign in again" message.
6. **App opened offline with cached auth state** → use cached user, show offline banner; cycle features work via Hive cache.
7. **Biometric not available on device** → setting is hidden; app behaves as if `biometricEnabled = false`.
8. **App backgrounded during sign-in** → on resume, retry the sign-in flow from where it stopped (Firebase preserves state).

---

## Failures

- `AuthFailure.googleSignInCancelled` — silent, no UI
- `AuthFailure.networkError` — retry-able
- `AuthFailure.firebaseError(cause)` — surface message, log
- `AuthFailure.biometricFailed` — 3-strike rule
- `AuthFailure.biometricUnavailable` — soft, hide setting

---

## Test plan

- AuthCubit transitions for each input (8+ tests via `bloc_test`)
- `AuthRepository` happy paths and failures (mock Firebase auth)
- `BiometricLockCubit`: 5-min timer, 3-strike rule, biometric unavailable
- Edge cases 1–8 each get a named test
- Integration: AuthGuard redirect logic in router (widget test)
