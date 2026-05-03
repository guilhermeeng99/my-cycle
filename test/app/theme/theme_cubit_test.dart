import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mycycle/app/theme/theme_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _key = 'theme_mode';

Future<SharedPreferences> _prefsWith(Map<String, Object> initial) async {
  SharedPreferences.setMockInitialValues(initial);
  return SharedPreferences.getInstance();
}

void main() {
  group('ThemeCubit — hydration', () {
    test('defaults to ThemeMode.system when no value is stored', () async {
      final prefs = await _prefsWith(<String, Object>{});

      final cubit = ThemeCubit(prefs: prefs);

      expect(cubit.state, ThemeMode.system);
    });

    test('hydrates from stored value', () async {
      final prefs = await _prefsWith(<String, Object>{_key: 'dark'});

      final cubit = ThemeCubit(prefs: prefs);

      expect(cubit.state, ThemeMode.dark);
    });

    test('falls back to system when stored value is unrecognized', () async {
      final prefs = await _prefsWith(<String, Object>{_key: 'not-a-mode'});

      final cubit = ThemeCubit(prefs: prefs);

      expect(cubit.state, ThemeMode.system);
    });
  });

  group('ThemeCubit — setThemeMode', () {
    test('emits the new mode and persists it', () async {
      final prefs = await _prefsWith(<String, Object>{});
      final cubit = ThemeCubit(prefs: prefs);
      final emitted = <ThemeMode>[];
      final sub = cubit.stream.listen(emitted.add);

      await cubit.setThemeMode(ThemeMode.dark);

      expect(cubit.state, ThemeMode.dark);
      expect(emitted, <ThemeMode>[ThemeMode.dark]);
      expect(prefs.getString(_key), 'dark');
      await sub.cancel();
    });

    test('is a no-op when called with the current mode', () async {
      final prefs = await _prefsWith(<String, Object>{});
      final cubit = ThemeCubit(prefs: prefs);
      final emitted = <ThemeMode>[];
      final sub = cubit.stream.listen(emitted.add);

      await cubit.setThemeMode(ThemeMode.system);

      expect(emitted, isEmpty);
      expect(prefs.getString(_key), isNull);
      await sub.cancel();
    });
  });

  group('ThemeCubit — toggleLightDark', () {
    test('from light emits dark', () async {
      final prefs = await _prefsWith(<String, Object>{_key: 'light'});
      final cubit = ThemeCubit(prefs: prefs);

      await cubit.toggleLightDark();

      expect(cubit.state, ThemeMode.dark);
    });

    test('from dark emits light', () async {
      final prefs = await _prefsWith(<String, Object>{_key: 'dark'});
      final cubit = ThemeCubit(prefs: prefs);

      await cubit.toggleLightDark();

      expect(cubit.state, ThemeMode.light);
    });

    test('from system emits dark', () async {
      final prefs = await _prefsWith(<String, Object>{});
      final cubit = ThemeCubit(prefs: prefs);

      await cubit.toggleLightDark();

      expect(cubit.state, ThemeMode.dark);
    });
  });
}
