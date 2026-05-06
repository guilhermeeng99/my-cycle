import 'package:flutter/material.dart';

/// Bloom radius tokens — FocusPomo-tuned.
///
/// Cards round at 16 (FocusPomo's content blocks land closer to 16 than 20),
/// timeline blocks at 14, primary buttons fully pill-shaped, inputs at 12.
abstract final class BloomRadii {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double block = 14;
  static const double lg = 16;
  static const double xl = 20;
  static const double pill = 999;

  static const BorderRadius input = BorderRadius.all(Radius.circular(md));
  static const BorderRadius card = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius blockShape =
      BorderRadius.all(Radius.circular(block));
  static const BorderRadius button = BorderRadius.all(Radius.circular(pill));
  static const BorderRadius pillShape = BorderRadius.all(Radius.circular(pill));
  static const BorderRadius bottomSheet = BorderRadius.vertical(
    top: Radius.circular(xl),
  );
}
