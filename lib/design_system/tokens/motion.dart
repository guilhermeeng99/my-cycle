import 'package:flutter/animation.dart';

/// Bloom motion tokens.
///
/// `instant` is also the target value when reduce-motion is active —
/// most animations should collapse to ~100ms or fade-only.
abstract final class BloomMotion {
  static const Duration instant = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration base = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);

  static const Curve standard = Cubic(0.4, 0, 0.2, 1);
  static const Curve emphasized = Cubic(0.2, 0, 0, 1);
}
