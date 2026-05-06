import 'package:flutter/material.dart';
import 'package:mycycle/design_system/tokens/colors.dart';

/// Material 3 [ColorScheme] built from Bloom raw color tokens.
///
/// Light-only — see `specs/redesign_focuspomo.md` (Decision B1: dark mode
/// dropped). Widgets should consume `Theme.of(context).colorScheme.*` —
/// this scheme is the single integration point between Bloom tokens and
/// Material.
abstract final class AppColors {
  static const ColorScheme light = ColorScheme(
    brightness: Brightness.light,

    // Primary — terracotta CTA
    primary: BloomColors.rose,
    onPrimary: BloomColors.petalMist,
    primaryContainer: BloomColors.petalSoft,
    onPrimaryContainer: BloomColors.roseDeep,

    // Secondary — warm cocoa
    secondary: BloomColors.plum,
    onSecondary: BloomColors.petalMist,
    secondaryContainer: BloomColors.petalSoft,
    onSecondaryContainer: BloomColors.plum,

    // Tertiary — sage
    tertiary: BloomColors.sage,
    onTertiary: BloomColors.ink,

    error: BloomColors.error,
    onError: BloomColors.petalMist,

    // Surfaces
    // surface = card / elevated content (lighter inner cream)
    // surfaceContainerLowest = scaffold (warm bege outer)
    // surfaceContainer / Low = neutral fills (pebble)
    surface: BloomColors.petalMist,
    onSurface: BloomColors.ink,
    onSurfaceVariant: BloomColors.inkSoft,
    surfaceContainerLowest: BloomColors.cream,
    surfaceContainerLow: BloomColors.cream,
    surfaceContainer: BloomColors.pebble,
    surfaceContainerHigh: BloomColors.petalSoft,
    surfaceContainerHighest: BloomColors.petalSoft,

    outline: BloomColors.pearlEdge,
    outlineVariant: BloomColors.pearlEdge,
    shadow: BloomColors.ink,
    inverseSurface: BloomColors.ink,
    onInverseSurface: BloomColors.cream,
  );

  /// Scaffold background — the warm bege "outer" tone.
  /// Kept as a function so widget tests can read it without a [BuildContext].
  static Color scaffoldBackground([Brightness? _]) => BloomColors.cream;
}
