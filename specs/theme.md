# Theme — Specification

> Status: draft v1 · Owner: @guiga · Last updated: 2026-05-03

Owns app-wide light/dark/system theme mode. Persists the user's choice across cold starts.

---

## Why a dedicated cubit

Theme mode is a UI-only preference that:

- Must apply globally — every screen reads it via `MaterialApp.themeMode`.
- Must persist across cold starts independent of the Firebase user (a user might pick a theme before signing in).
- Must NOT live in the user's Firestore doc — different devices may want different themes for the same user.

`SettingsCubit` is account-state-scoped (per-user, per-couple) and clears on sign-out. Theme is local-device state, so it gets its own cubit and its own storage.

---

## State machine — `ThemeCubit`

`ThemeCubit` is a `Cubit<ThemeMode>`. The state IS the mode — no wrapper class.

```
[ThemeMode.system]  (default)
       │
       ▼
[loaded from SharedPreferences if any saved value]
       │
       ▼
[setThemeMode(next)]
       └── persist to SharedPreferences (key 'theme_mode')
       └── emit(next)
```

Hydration happens **synchronously in the constructor** — `SharedPreferences.getInstance()` is awaited once during DI init, and the cubit reads from the resolved instance. No `Loading` state, no async splash dependency.

---

## Public API

```dart
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit({required SharedPreferences prefs});

  Future<void> setThemeMode(ThemeMode mode);   // no-op when already in [mode]
  Future<void> toggleLightDark();              // light <-> dark; from system, goes dark
}
```

Registered as a DI singleton. Provided at the root via `MultiBlocProvider`. Wrapped by `BlocBuilder<ThemeCubit, ThemeMode>` which feeds `MaterialApp.themeMode`.

---

## Storage contract

| Key | Type | Values |
|---|---|---|
| `theme_mode` | `String` | `"system"` / `"light"` / `"dark"` (one of `ThemeMode.values.map((m) => m.name)`) |

Unknown / corrupt values fall back to `ThemeMode.system`.

---

## UI

Settings → **Appearance** section. Three radio options bound to a `BlocBuilder<ThemeCubit, ThemeMode>`:

- Match system → `ThemeMode.system`
- Light → `ThemeMode.light`
- Dark → `ThemeMode.dark`

Selection calls `context.read<ThemeCubit>().setThemeMode(value)`. The whole app rebuilds on emit.

---

## Edge cases

1. **First run ever** — no saved value; default to `ThemeMode.system`.
2. **Saved value is unrecognized** (e.g., key exists but doesn't map to any `ThemeMode.name`) — fall back to `ThemeMode.system`. Do not crash.
3. **`setThemeMode(current)`** — short-circuits, no emit, no write.
4. **Sign-out** — theme mode is preserved (not user-scoped).
5. **App reinstall** — `SharedPreferences` is wiped; default returns to `ThemeMode.system`.

---

## Test plan

- Constructor with no saved value → state is `ThemeMode.system`.
- Constructor with saved `"dark"` → state is `ThemeMode.dark`.
- Constructor with saved `"garbage"` → state is `ThemeMode.system`.
- `setThemeMode(dark)` emits `ThemeMode.dark` and writes `"dark"` to prefs.
- `setThemeMode(state)` is a no-op (no emit, no write).
- `toggleLightDark()` from `light` emits `dark`; from `dark` emits `light`; from `system` emits `dark`.
