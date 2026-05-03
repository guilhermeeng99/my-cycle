import 'package:flutter/material.dart';
import 'package:mycycle/design_system/tokens/typography.dart';

/// Maps Bloom typography tokens onto Material's [TextTheme].
///
/// Display/headline tiers use Fraunces (serif, editorial); title/body/label
/// tiers use Inter (screen legibility).
abstract final class AppTypography {
  static TextTheme themeFor(Color onSurface) {
    return TextTheme(
      displayLarge: BloomTypography.display.copyWith(color: onSurface),
      displayMedium: BloomTypography.h1.copyWith(color: onSurface),
      displaySmall: BloomTypography.h2.copyWith(color: onSurface),
      headlineLarge: BloomTypography.h2.copyWith(color: onSurface),
      headlineMedium: BloomTypography.h3.copyWith(color: onSurface),
      headlineSmall: BloomTypography.h4.copyWith(color: onSurface),
      titleLarge: BloomTypography.h4.copyWith(color: onSurface),
      titleMedium: BloomTypography.bodyLg.copyWith(
        color: onSurface,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: BloomTypography.body.copyWith(
        color: onSurface,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: BloomTypography.bodyLg.copyWith(color: onSurface),
      bodyMedium: BloomTypography.body.copyWith(color: onSurface),
      bodySmall: BloomTypography.bodySm.copyWith(color: onSurface),
      labelLarge: BloomTypography.body.copyWith(
        color: onSurface,
        fontWeight: FontWeight.w500,
      ),
      labelMedium: BloomTypography.bodySm.copyWith(
        color: onSurface,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: BloomTypography.caption.copyWith(color: onSurface),
    );
  }
}
