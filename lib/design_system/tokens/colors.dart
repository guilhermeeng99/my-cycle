import 'package:flutter/material.dart';

/// Bloom raw color tokens.
///
/// Light/dark surface and ink tokens are split with `night*` and `*Dark`
/// suffixes; the mapping into Material 3 [ColorScheme] lives in
/// `app/theme/app_theme.dart`. Direct usage in widgets is discouraged —
/// prefer `Theme.of(context).colorScheme.*`.
abstract final class BloomColors {
  // Brand
  static const Color rose = Color(0xFFC9637E);
  static const Color roseDeep = Color(0xFFA14B63);
  static const Color roseDark = Color(0xFFD87E94);
  static const Color plum = Color(0xFF6B4E6F);
  static const Color honey = Color(0xFFD9A86C);
  static const Color sage = Color(0xFF8FA88E);

  // Surfaces — light
  static const Color cream = Color(0xFFFAF5F2);
  static const Color petalMist = Color(0xFFFFFFFF);
  static const Color petalSoft = Color(0xFFF4E5E1);
  static const Color pearlEdge = Color(0xFFEFE4DF);

  // Surfaces — dark
  static const Color nightBg = Color(0xFF1A1416);
  static const Color nightSurface = Color(0xFF241D1F);
  static const Color nightSurfaceAlt = Color(0xFF2E2528);
  static const Color nightBorder = Color(0xFF3A3033);

  // Text — light
  static const Color ink = Color(0xFF3D2E2C);
  static const Color inkSoft = Color(0xFF6B5856);
  static const Color whisperGray = Color(0xFF998B89);

  // Text — dark
  static const Color inkDark = Color(0xFFF2E8E5);
  static const Color inkDarkSoft = Color(0xFFC2B5B2);

  // Cycle phases (designed to read on both light and dark surfaces)
  static const Color phaseMenstrual = Color(0xFFB8485A);
  static const Color phaseFollicular = Color(0xFFE8A87C);
  static const Color phaseOvulation = Color(0xFF8FA88E);
  static const Color phaseLuteal = Color(0xFFA89BBF);

  // Semantic
  static const Color success = Color(0xFF7BA87B);
  static const Color warning = Color(0xFFD9A86C);
  static const Color error = Color(0xFFC5566B);
  static const Color info = Color(0xFF8FA1B8);
}
