import 'package:flutter/material.dart';

import 'package:mycycle/design_system/tokens/colors.dart';

/// Bloom elevation tokens.
///
/// Soft, blurred shadows — divergence from Material's solid offset. Reads as
/// more refined and modern; better fit for a calm, intimate journal feel.
abstract final class BloomElevation {
  static const Color _shadowColor = BloomColors.ink;

  static List<BoxShadow> get level1 => [
        BoxShadow(
          color: _shadowColor.withValues(alpha: 0.06),
          offset: const Offset(0, 1),
          blurRadius: 2,
        ),
      ];

  static List<BoxShadow> get level2 => [
        BoxShadow(
          color: _shadowColor.withValues(alpha: 0.06),
          offset: const Offset(0, 4),
          blurRadius: 12,
        ),
      ];

  static List<BoxShadow> get level3 => [
        BoxShadow(
          color: _shadowColor.withValues(alpha: 0.08),
          offset: const Offset(0, 8),
          blurRadius: 24,
        ),
      ];

  /// Soft glow used for hero moments — e.g. period-start log confirmation.
  static List<BoxShadow> get glowRose => [
        BoxShadow(
          color: BloomColors.rose.withValues(alpha: 0.18),
          blurRadius: 24,
        ),
      ];
}
