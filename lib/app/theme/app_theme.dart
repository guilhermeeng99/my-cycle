import 'package:flutter/material.dart';

import 'package:mycycle/app/theme/app_colors.dart';
import 'package:mycycle/app/theme/app_typography.dart';
import 'package:mycycle/design_system/tokens/tokens.dart';

/// Bloom theme builder for MyCycle — light-only, FocusPomo-tuned.
///
/// Composes color, typography and component themes; each piece lives in a
/// dedicated file so changes stay focused. Widgets should consume
/// `Theme.of(context).colorScheme.*` and `Theme.of(context).textTheme.*`
/// rather than reaching for raw tokens.
///
/// Visual direction: warm beige scaffold + cream cards, terracotta accent
/// reserved for primary CTAs and the active state. Depth comes from
/// background tone contrast, not shadows — `cardTheme.elevation` is 0 by
/// default and primary buttons use solid fills (no gradients).
abstract final class AppTheme {
  static ThemeData light() => _build(AppColors.light);

  static ThemeData _build(ColorScheme scheme) {
    final scaffoldBg = AppColors.scaffoldBackground();
    final textTheme = AppTypography.themeFor(scheme.onSurface);

    return ThemeData(
      useMaterial3: true,
      brightness: scheme.brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffoldBg,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBg,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(borderRadius: BloomRadii.card),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          disabledBackgroundColor: scheme.primary.withValues(alpha: 0.4),
          disabledForegroundColor: scheme.onPrimary.withValues(alpha: 0.8),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          minimumSize: const Size.fromHeight(56),
          shape: const RoundedRectangleBorder(borderRadius: BloomRadii.button),
          elevation: 0,
          textStyle: BloomTypography.body.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.onSurface,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          minimumSize: const Size.fromHeight(56),
          side: BorderSide(color: scheme.outline),
          shape: const RoundedRectangleBorder(borderRadius: BloomRadii.button),
          textStyle: BloomTypography.body.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: const RoundedRectangleBorder(borderRadius: BloomRadii.button),
          textStyle: BloomTypography.body.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BloomRadii.input,
          borderSide: BorderSide(color: scheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BloomRadii.input,
          borderSide: BorderSide(color: scheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BloomRadii.input,
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BloomRadii.input,
          borderSide: BorderSide(color: scheme.error),
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onSurface.withValues(alpha: 0.7),
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onSurface.withValues(alpha: 0.5),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outline,
        thickness: 1,
        space: 1,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        modalBackgroundColor: scheme.surface,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BloomRadii.bottomSheet,
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
    );
  }
}
