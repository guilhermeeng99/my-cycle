# Hive Cache — Specification

> Status: draft v2 · Owner: @guiga · Last updated: 2026-05-03

A thin, JSON-based document cache layered between repositories and the
Firestore SDK. Its single job is **fast cold start**: paint the user's
profile and couple state from disk before the network round-trip resolves.

This is the read-cache half of the sync architecture described in
`CLAUDE.md` — Firestore stays the source of truth, Hive is a faster local
view of the last value seen.

---

## Goals

- **Instant first paint** for screens that depend on User and Couple
  documents (Today, Settings, Insights).
- **Zero codegen.** Documents are small; JSON is forgiving across schema
  changes; `@HiveType` adapters add a build step we can avoid.
- **Repository-local.** Cubits and pages don't know caching exists. The
  cache is composed inside repository implementations.

Non-goals: caching cycle queries (multi-doc result sets), full offline
write queueing (the Firestore SDK already does that for writes), schema
migrations beyond best-effort drop-on-corrupt.

---

## What is cached

| Box name | Key | Value type |
|---|---|---|
| `users` | Firebase auth uid | JSON-encoded `User` document |
| `couples` | couple id | JSON-encoded `Couple` document |
| `cycles` | `coupleId:limit` | JSON-encoded `List<Cycle>` (recent cycles) |
| `meta` | varies | reserved for app-level metadata; unused in v1 |

The cycles cache key includes the request `limit` so different page sizes
don't overwrite each other (`couple-1:12` vs `couple-1:5`). The current
cycle is **not** cached separately — `watchCurrentCycle` still hits
Firestore directly. Today/Insights/Calendar all paint instantly from the
cycles list cache; the current cycle surface (Today) catches up on the
next snapshot.

---

## Storage format

Every box is `Box<String>` containing `jsonEncode`d values. The cache is
generic — `HiveDocCache<T>` accepts any type whose `toJson` returns a
JSON-encodable `Object` (a `Map`, `List`, or primitive). `DateTime`s are
stored as `millisecondsSinceEpoch` integers and rehydrated **with
`isUtc: true`** so date-only fields (e.g., `Cycle.startDate`) round-trip
without timezone drift. `Timestamp` does not survive `jsonEncode` and is
never used in cache JSON.

Serialization helpers live in `lib/core/hive/cache_serializers.dart`
(`CacheSerializers.userToJson`, `coupleToJson`, `cyclesListToJson`, plus
the matching `*FromJson` decoders that delegate to factory constructors
on the Firestore models — `UserModel.fromCacheJson`,
`CoupleModel.fromCacheJson`, `CycleModel.fromCacheJson`).

---

## Public surface

### `HiveDocCache<T>`

```dart
class HiveDocCache<T> {
  HiveDocCache({
    required Box<String> box,
    required Object Function(T) toJson,
    required T Function(Object) fromJson,
  });

  T?            read(String key);
  Future<void>  write(String key, T value);
  Future<void>  delete(String key);
  Stream<T?>    merge({required String key, required Stream<T?> remote});
}
```

`merge` is the canonical way a repository exposes a cached stream:

1. If the cache holds a value for `key`, yield it synchronously on subscribe.
2. Forward every event from `remote`, persisting each non-null event back
   into the cache. Null events delete the key.

Implemented with an explicit `StreamController` (rather than `async*`) so
subscription cancel is immediate — `async*` holds the awaited box
reference through one extra microtask, which trips test teardowns that
try to close the box right after `sub.cancel()`.

`read` is also defensive: corrupt JSON in the box is logged, the bad entry
deleted, and `null` returned. The repo then falls through to the live
Firestore stream.

### `initHive()` and `clearAllCaches()`

`lib/core/hive/hive_initializer.dart` exposes:

- `initHive()` — opens every box listed in `HiveBoxes.all`. Called from
  `main()` after `Firebase.initializeApp()`.
- `clearAllCaches()` — wipes every box. Wired into `AuthRepositoryImpl`'s
  sign-out flow so the next user never sees the previous user's state.

---

## Repository integration

### `AuthRepositoryImpl`

- Accepts an optional `HiveDocCache<User>` and an `onSignOut` callback
  (the DI wires `clearAllCaches`).
- `watchAuthState`:
  1. emits `AuthStateUnknown` (initial)
  2. when Firebase auth says "signed in", reads the cached user **first**
     — yields `AuthStateAuthenticated(cached)` so the splash can hand off
     to home immediately.
  3. then forwards the live Firestore stream, persisting each emission to
     the cache.
- `signOut`: calls the remote sign-out, then `onSignOut?.call()` to wipe
  every cache. The cache wipe is centralized in the auth flow because
  every other feature is downstream of auth.

### `CoupleRepositoryImpl`

- Accepts an optional `HiveDocCache<Couple>`.
- `watchCouple(coupleId)` returns `cache.merge(key: coupleId, remote: …)`.
- `leaveCouple` deletes the cached couple before returning.

### `CycleRepositoryImpl`

- Accepts an optional `HiveDocCache<List<Cycle>>` (the recent-cycles cache).
- `watchRecentCycles(coupleId, limit:)` builds the live Firestore stream,
  then routes it through `cache.merge` with key `"$coupleId:$limit"`. The
  cached list is yielded synchronously on subscribe; each remote emission
  overwrites the cache.
- `watchCurrentCycle` is intentionally **not** cached — the current cycle
  is small, the Firestore round-trip resolves quickly, and the recent
  cycles cache already covers cold-start paint for any UI that builds
  from the list.
- Mutating methods (`startNewCycle`, `setPeriodEnd`) do not touch the
  cache directly; the next Firestore snapshot drives the update through
  `merge`.

---

## Lifecycle

```
main()
  ├── Firebase.initializeApp()
  ├── initDependencies()
  │     ├── GoogleSignIn.initialize()
  │     ├── initHive()                ← opens users/couples/meta boxes
  │     ├── SharedPreferences.getInstance()
  │     ├── build HiveDocCache<User>, HiveDocCache<Couple>
  │     └── register repositories with caches
  ├── runApp(MyCycleApp)
  └── ...
```

Sign-out path (any caller — settings page, biometric force-out):

```
authCubit.signOut()
  → AuthRepositoryImpl.signOut()
      → remote.signOut()
      → onSignOut() = clearAllCaches()   // wipes users/couples/meta
```

---

## Edge cases

1. **Cold start, no cache, no network**: Firebase auth state is still
   restored from its own disk persistence; the cubit emits `Unauthenticated`
   or `Authenticated` as usual; the live Firestore read fails → user sees
   the splash for longer but no crash.
2. **Cold start, cache hit, network recovers**: cached value paints
   instantly; Firestore stream catches up with possibly-newer data; the
   cache absorbs the update.
3. **Cache corrupt** (manual edit, partial write, schema drift): the next
   `read` logs the error, deletes the key, and returns null. The repo
   falls through to the live read.
4. **Sign-in as a different user** while previous cache is warm: the
   sign-out path before sign-in clears caches; the new user's first
   `watchAuthState` sees an empty cache.
5. **Two devices write the same couple at the same time**: last-write-wins
   via Firestore server timestamp. Both devices receive the merged result
   on their next snapshot and overwrite their local cache.

---

## Test plan

`HiveDocCache` (unit, no Firestore):
- `read` returns null on empty cache.
- `write` then `read` round-trips.
- Corrupt JSON is dropped from the box and `read` returns null.
- `delete` removes the entry.

`CacheSerializers.cycles`:
- Empty list round-trips.
- Mixed open/closed cycles round-trip with all optional fields preserved.
- UTC date-only dates survive serialization (no timezone drift).

`CycleRepositoryImpl` integration with the cycles cache:
- Cached list is emitted synchronously before the first remote event.
- Each remote emission persists back into the box.
- Different `limit` values use distinct cache keys.

The cache parameter is optional on every repository, so default test
setups (no Hive boxes) continue to work without wiring the cache.

---

## Future work

- Cache `watchCurrentCycle` if cold-start paint of the Today screen ever
  feels slow despite the recent-cycles cache.
- Cache day logs (`Box<String>` keyed by `coupleId:date`, value = JSON
  `DayLog`). Today the logging sheet hits Firestore directly because it's
  only opened on tap.
- Hive-backed UI streams (`box.listenable()` instead of repository streams)
  for screens that re-render on cache updates without a live Firestore
  subscription.
- Schema versioning: a `meta` box entry tracking the cache schema version,
  with a migration step on `initHive()`.
