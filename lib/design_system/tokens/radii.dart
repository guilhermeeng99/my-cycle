import 'package:flutter/material.dart';

/// Bloom radius tokens.
///
/// Cards round at 20, primary buttons at 28 (softer than Material default),
/// inputs at 12, pills fully rounded.
abstract final class BloomRadii {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 20;
  static const double xl = 28;
  static const double pill = 999;

  static const BorderRadius input = BorderRadius.all(Radius.circular(md));
  static const BorderRadius card = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius button = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius pillShape = BorderRadius.all(Radius.circular(pill));
  static const BorderRadius bottomSheet = BorderRadius.vertical(
    top: Radius.circular(lg),
  );
}
