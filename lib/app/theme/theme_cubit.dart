import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Owns the global theme mode and persists the user's choice across
/// cold starts.
///
/// Per `specs/redesign_focuspomo.md` (Decision B1), the app currently
/// ships light-only. The cubit is kept for storage compatibility and
/// for the future possibility of a "warm dark" variant; until then,
/// `MaterialApp.themeMode` is hard-pinned to [ThemeMode.light] in
/// `app_widget.dart` and the cubit's value is effectively ignored by
/// the runtime.
///
/// Initial value defaults to [ThemeMode.light]; saved values that are
/// not recognized fall back to [ThemeMode.light].
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit({required SharedPreferences prefs})
    : _prefs = prefs,
      super(_load(prefs));

  static const String _key = 'theme_mode';
  final SharedPreferences _prefs;

  static ThemeMode _load(SharedPreferences prefs) {
    final stored = prefs.getString(_key);
    return ThemeMode.values
            .where((m) => m.name == stored)
            .firstOrNull ??
        ThemeMode.light;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (state == mode) return;
    emit(mode);
    await _prefs.setString(_key, mode.name);
  }
}
