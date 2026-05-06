# MyCycle — Project Conventions

A menstrual cycle tracker built with Flutter.
Personal use, Android-only deployment, portfolio-grade engineering.

---

## Product Principles (read first — these resolve ties)

1. **Privacy is the default.** Cycle data lives in the user's Firebase project; no analytics on cycle content. Biometric lock is layered on top of auth.
2. **The app should feel like a journal, not a dashboard.** Calm typography, soft color, no engagement-bait notifications, no streaks.
3. **5-second daily interaction.** Logging today's state should take one tap from the Today screen. Friction on the daily path needs justification.
4. **Predictions are honest.** Confidence labels are always visible. Predictions ship as date ranges, never single dates.

---

## Architecture

Clean Architecture, feature-first, design system as a peer module.

```
lib/
├── app/                  # App shell: DI, routing, theme, root widget, assets
├── core/                 # Cross-cutting: clock, entities, errors, hive, sync
├── design_system/        # Bloom: tokens, components, motion, haptics, icons
├── features/             # auth, pairing, onboarding, cycle, today, calendar, ...
└── gen/                  # Generated code (slang i18n, hive_ce adapters)
```

Each feature: `domain/` (entities, contracts, use cases) → `data/` (models, datasources, repositories) → `presentation/` (cubits/blocs, pages, widgets).

Cross-feature entities (e.g. `User`) live in `core/entities/`. Failure types live next to the feature that owns them.

---

## Code Style

* Cohesion over line count. Extract when a function does more than one thing or when a name would meaningfully help a reader. Don't extract for the sake of a number.
* Files: aim under 400 lines. If a widget grows past that, the widget itself is probably doing too much.
* SRP per module. KISS over cleverness. DRY only when the duplication actually represents the same concept.
* Early returns. Max 2 levels of indentation in business logic.

### Naming

* Intention-revealing, searchable, unique within the codebase.
* Banned generic names: `data`, `manager`, `handler`, `service` (without a domain prefix), `helper`, `utils` (as a class).

---

## Comments

* Default to no comment. The name should carry the intent.
* Write a comment when the **WHY** is non-obvious: a workaround, a subtle invariant, a deliberate trade-off.
* Public API doc comments must include intent, parameters, and a short usage example.

---

## Key Technologies

| Aspect | Choice |
|---|---|
| State management | flutter_bloc (Cubit for simple state, Bloc for event-driven) |
| DI | get_it (`lib/app/di/injection_container.dart`) |
| Routing | go_router with auth-aware redirect |
| Local cache | Hive CE — fast cold-start cache (no manual outbox; Firestore SDK queues writes) |
| Sync source of truth | Cloud Firestore |
| Auth | Firebase Auth + Google Sign-In |
| Error handling | Sealed `Result<T>` types + Dart 3 pattern matching |
| Linting | very_good_analysis (zero warnings policy) |
| i18n | slang (en, pt-BR) |
| Theme | Bloom design system, light + dark Material 3 |
| Notifications | flutter_local_notifications (no FCM) |
| Date math | package:intl + custom `CycleCalendar` utility |
| File share | share_plus (data export) |

> **Why no dartz?** Dart 3 sealed classes give exhaustive pattern matching without the functional-programming tax. Optimizes for readability for someone scanning the codebase fresh.

---

## Privacy & Security

1. Cycle data is owned by the user's Firebase project. Firestore security rules scope reads/writes to couple members only.
2. Biometric (Face ID / fingerprint) gate is opt-in, layered on top of auth.
3. No third-party analytics on cycle content. If we ever add crash reporting, payloads are redacted.
4. Export-my-data and delete-my-data flows must work offline (read from Hive cache) and produce a verifiable JSON file.
5. The wife is "owner" with full read/write on cycle data. The husband is "partner" with read access + write access only to `partnerNote` fields. Enforced both client-side and in Firestore rules.

---

## Accessibility

* All interactive elements have semantic labels.
* Contrast ratios meet WCAG AA (4.5:1 body text, 3:1 large text).
* Dynamic Type respected — no hardcoded font sizes in widgets, only design tokens.
* Reduce-motion honored: animations shorten to 100ms or fade-only.
* Tap targets ≥ 44 × 44 logical pixels.

---

## Build & Run

```bash
flutter run                          # Run on emulator/device
flutter test                         # All tests
flutter test test/features/auth/     # Feature tests
flutter analyze                      # Must be zero issues
dart run slang                       # Regenerate i18n strings (reads slang.yaml)
dart run build_runner build          # Regenerate Hive type adapters (and other build_runner outputs)
flutter build apk --debug            # Outputs build/app/outputs/flutter-apk/app-debug.apk
firebase deploy --only firestore     # Deploy security rules + indexes
```

Codegen sources:

* **slang** input → `lib/app/assets/i18n/{en,pt-BR}.i18n.json`, output → `lib/gen/i18n/`. Configured via `slang.yaml`.
* **Hive type adapters** → `@HiveType`-annotated classes; output adjacent (`*.g.dart`), excluded from analyzer.

> **Important:** Use `dart run slang` for i18n regen, **not** `dart run build_runner build`. The build_runner builder for slang ignores `slang.yaml` and writes outputs adjacent to inputs (`lib/app/assets/i18n/strings*.g.dart`) — wrong location. The standalone `slang` CLI reads the config and writes to `lib/gen/i18n/`.

---

## Post-Change Checklist

1. `dart run slang` if `lib/app/assets/i18n/*.i18n.json` changed.
2. `dart run build_runner build` if `@HiveType`-annotated classes changed.
3. `flutter analyze` — zero issues. No `// ignore` without inline justification.
4. `flutter test` — green.
5. If you touched the design system, verify visual regression manually on the relevant screens (light + dark).
6. If you touched `firestore.rules`, deploy with `firebase deploy --only firestore:rules` and run rules-emulator tests.

---

## Spec-Driven Development

Every feature has a spec at `specs/<feature>.md` before any code or tests.

### Spec contents

* Entity contract (fields, types, invariants)
* Business rules (numbered, testable — `BR-N` referenced in test names)
* Repository contract (methods, parameters, return types)
* State machines (states + transitions)
* Edge cases (empty data, irregular cycles, missing logs, year boundaries, daylight saving, leap years)

### Workflow

1. Write or update the spec.
2. Write tests that reference its business rules.
3. Implement until the tests pass.
4. Update the spec when behavior changes.

---

## Testing

* Every use case has tests.
* Every bug fix ships with a regression test.
* F.I.R.S.T: fast, independent, repeatable, self-validating, timely.
* One test file per source file, mirroring `lib/`.
* Mock at boundaries: repositories for cubits, datasources for repositories.
* Use factories from `test/harness/factories/` — never hardcode entities.

### Date-sensitive tests

* Inject the `Clock` abstraction. Never call `DateTime.now()` directly in domain code.
* Tests pin time explicitly via `MockClock`.

### Widget tests

* In `setUpAll`: call `LocaleSettings.setLocaleSync(AppLocale.en)` and set `GoogleFonts.config.allowRuntimeFetching = false`.
* Use `BlocProvider(create:)`, not `.value` — avoids lifecycle hangs in pumpWidget.

---

## Harness Engineering

`test/harness/`:

* `mocks.dart` — centralized mocktail declarations.
* `factories/` — one factory per entity (`UserFactory`, `CycleFactory`, `DayLogFactory`, `CoupleFactory`).
* `helpers.dart` — shared setup, fake clock, in-memory Hive boxes.
* `pump_app.dart` — wraps a widget under test in real theme + DI overrides.

---

## Dependencies

* Depend on abstractions, not implementations.
* Inject via constructor or DI (`get_it`).
* Wrap external libraries behind project-owned interfaces — e.g. `AuthRemoteDataSource` hides `firebase_auth` + `google_sign_in` so the repository (and its tests) never imports those packages directly.
* Repository methods return `Future<Result<T>>` (sealed `Result<T>`).

---

## Code Conventions

* Entities: `Equatable` + `copyWith`.
* Failures: sealed classes per feature (`AuthFailure`, `PairingFailure`, `StorageFailure`, `BiometricFailure`, ...). No catch-all "ServerFailure."
* Use cases: single-method classes with `call()` operator.
* Models extend entities and own serialization (Firestore + Hive type adapter).
* Repository methods return `Future<Result<T>>` with sealed `Result<T>`.
* Package imports (`package:mycycle/...`).
* `const` everywhere it compiles.

---

## UI & Formatting

* Every user-facing string via slang. Never hardcoded.
* Never use raw colors / sizes / spacing in widgets — only tokens from `design_system/`.
* Date and number formatting via `intl` with locale awareness.
* Haptics: every primary action ships a haptic. See `design_system/haptics/`.

---

## State Management

* UI contains zero business logic.
* Cubits/Blocs orchestrate. Use cases execute. Repositories persist.
* State is immutable. Use `copyWith` or sealed states.
* One Cubit/Bloc per screen unless state is genuinely shared.

### Lifecycle

* Global blocs (Auth, theme, current cycle, biometric lock) → `registerLazySingleton`.
* Per-screen cubits → `registerFactory`.

---

## Routing

go_router with auth-aware `redirect`. Routes declared in `lib/app/router/app_router.dart`; route name constants in `lib/app/router/routes.dart`.

| Auth state | Redirect target |
|---|---|
| `AuthStateUnknown` | `/splash` |
| `AuthStateUnauthenticated` | `/sign-in` |
| `AuthStateAuthenticated` (no `coupleId`) | `/pairing-choice` |
| `AuthStateAuthenticated` + paired | `/home` |

`GoRouterRefreshStream` bridges `AuthCubit.stream` → `Listenable` so the redirect re-evaluates on every auth state change.

Deep links and the four-tab bottom nav (Today / Calendar / Insights / Profile) will use `StatefulShellRoute` once those features ship.

---

## Sync — Firestore + Hive CE

* **Firestore is the source of truth.** All canonical data lives there; security rules and last-write-wins semantics are anchored to Firestore server timestamps.
* **Hive CE is a read cache, not a mirror.** Its only job is making cold-start render instant — the UI paints from Hive before `Firebase.initializeApp()` resolves.
* **Reads:** UI subscribes to a `Stream<T>` derived from `box.listenable()`. In parallel, a Firestore `snapshots()` listener writes incoming server data into the Hive box. The UI re-emits from the box; it never reads Firestore directly.
* **Writes:** optimistic — repository writes to Hive first (UI updates immediately), then `firestore.set(...)`. **No manual outbox.** Offline writes are queued by the Firestore SDK and replayed on reconnect. On hard write failure (not offline), revert the Hive value and return `Err`.
* **Conflict resolution:** last-write-wins by Firestore server timestamp. Loser device's Hive value is overwritten by the next snapshot.
* **Sign-out / delete-my-data:** clear all Hive boxes. Firestore is independent.

### Hive conventions

* Boxes are opened in `main()` after `Firebase.initializeApp()` and before `runApp()`.
* Box names are constants in `lib/core/hive/box_names.dart` — no string literals scattered across repositories.
* Type adapters are codegen-only (`@HiveType`); never hand-rolled.
* Boxes are typed (`Box<UserModel>`, not `Box<dynamic>`).
* Repositories are the only writers. UI never touches a box directly.

---

## Date & Time Handling

* Domain code never calls `DateTime.now()` — inject `Clock` and call `clock.now()`.
* Cycle dates are stored as **date-only** (`YYYY-MM-DD` strings, UTC interpretation only). Sidesteps DST, leap seconds, year boundaries.
* `createdAt` / `updatedAt` use Firestore `Timestamp` on the wire, mapped to `DateTime` in models.
* Display via `intl` with the user's selected locale (`AppLocale`).

---

## Performance

* Avoid unnecessary rebuilds: `const`, `BlocSelector`, granular widgets.
* Lists use lazy builders.
* Predictions and stats compute off the UI isolate when > 30ms.
* Calendar month build < 50ms target.
* Profile before optimizing — no premature work.

---

## Firestore Collections

```
users/{userId}
  → name, email, photoUrl?, coupleId?, role? (owner|partner),
    language (en|ptBr), biometricEnabled, createdAt, updatedAt

couples/{coupleId}
  → ownerId, partnerId?, inviteCode?, inviteExpiresAt?,
    defaultCycleLength, defaultLutealLength, createdAt, updatedAt

couples/{coupleId}/cycles/{cycleId}
  → startDate (YYYY-MM-DD), periodEndDate?, totalLengthDays?,
    predictedNextStart?, predictedNextStartRangeEnd?,
    predictedOvulation?, predictionConfidence? (low|medium|high),
    createdAt, updatedAt

couples/{coupleId}/days/{YYYY-MM-DD}
  → flow? (spotting|light|medium|heavy), symptoms[],
    mood? (happy|calm|irritable|sad|anxious),
    ownerNote?, partnerNote?, createdAt, updatedAt
```

### Query guidelines

* Always scope by `coupleId` (or `userId` for the user doc).
* No unbounded queries. `watchRecentCycles` caps at 24; day-log range queries are bounded by from/to.
* Composite indexes go in `firestore.indexes.json`. Single-field indexes are auto-managed by Firestore.
* Use batched writes for multi-document updates.

---

## Firestore Security Rules

Live in `firestore.rules`. Summary:

* `users/{uid}` — only the owner reads / writes their own doc.
* `couples/{id}` — both members read. Owner writes anything (cannot change `ownerId`). Partner can only:
  * leave (set `partnerId = null` while keeping all other fields)
  * claim an empty couple via valid `inviteCode` (transactional)
* `couples/{id}/cycles/{cycleId}` — both read; owner writes.
* `couples/{id}/days/{date}` — both read; owner writes anything; partner writes only `partnerNote` (and `updatedAt`).

Deploy with `firebase deploy --only firestore:rules`. Rules-emulator tests will live in `test/firestore_rules/` once added.
