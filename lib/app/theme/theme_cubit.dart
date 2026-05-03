import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Owns the global theme mode and persists the user's choice across
/// cold starts. Initial value is [ThemeMode.system]; the saved preference
/// (if any) is hydrated synchronously in the constructor.
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
        ThemeMode.system;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (state == mode) return;
    emit(mode);
    await _prefs.setString(_key, mode.name);
  }

  Future<void> toggleLightDark() {
    final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    return setThemeMode(next);
  }
}
