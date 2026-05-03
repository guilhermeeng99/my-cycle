import 'package:flutter/material.dart';
import 'package:mycycle/design_system/tokens/colors.dart';

/// Material 3 [ColorScheme]s built from Bloom raw color tokens.
///
/// Widgets should consume `Theme.of(context).colorScheme.*` — these schemes
/// are the single integration point between Bloom tokens and Material.
abstract final class AppColors {
  static const ColorScheme light = ColorScheme(
    brightness: Brightness.light,
    primary: BloomColors.rose,
    onPrimary: BloomColors.petalMist,
    primaryContainer: BloomColors.petalSoft,
    onPrimaryContainer: BloomColors.roseDeep,
    secondary: BloomColors.plum,
    onSecondary: BloomColors.petalMist,
    secondaryContainer: BloomColors.petalSoft,
    onSecondaryContainer: BloomColors.plum,
    tertiary: BloomColors.sage,
    onTertiary: BloomColors.ink,
    error: BloomColors.error,
    onError: BloomColors.petalMist,
    surface: BloomColors.petalMist,
    onSurface: BloomColors.ink,
    onSurfaceVariant: BloomColors.inkSoft,
    surfaceContainerLowest: BloomColors.petalMist,
    surfaceContainerLow: BloomColors.cream,
    surfaceContainer: BloomColors.cream,
    surfaceContainerHigh: BloomColors.petalSoft,
    surfaceContainerHighest: BloomColors.petalSoft,
    outline: BloomColors.pearlEdge,
    outlineVariant: BloomColors.pearlEdge,
    shadow: BloomColors.ink,
    inverseSurface: BloomColors.ink,
    onInverseSurface: BloomColors.cream,
  );

  static const ColorScheme dark = ColorScheme(
    brightness: Brightness.dark,
    primary: BloomColors.roseDark,
    onPrimary: BloomColors.nightBg,
    primaryContainer: BloomColors.nightSurfaceAlt,
    onPrimaryContainer: BloomColors.roseDark,
    secondary: BloomColors.plum,
    onSecondary: BloomColors.inkDark,
    secondaryContainer: BloomColors.nightSurfaceAlt,
    onSecondaryContainer: BloomColors.inkDark,
    tertiary: BloomColors.sage,
    onTertiary: BloomColors.nightBg,
    error: BloomColors.error,
    onError: BloomColors.inkDark,
    surface: BloomColors.nightSurface,
    onSurface: BloomColors.inkDark,
    onSurfaceVariant: BloomColors.inkDarkSoft,
    surfaceContainerLowest: BloomColors.nightBg,
    surfaceContainerLow: BloomColors.nightSurface,
    surfaceContainer: BloomColors.nightSurface,
    surfaceContainerHigh: BloomColors.nightSurfaceAlt,
    surfaceContainerHighest: BloomColors.nightSurfaceAlt,
    outline: BloomColors.nightBorder,
    outlineVariant: BloomColors.nightBorder,
    shadow: BloomColors.nightBg,
    inverseSurface: BloomColors.inkDark,
    onInverseSurface: BloomColors.nightBg,
  );

  static Color scaffoldBackground(Brightness brightness) =>
      brightness == Brightness.light ? BloomColors.cream : BloomColors.nightBg;
}
