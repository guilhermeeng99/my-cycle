import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Bloom typography tokens — FocusPomo-inspired rounded sans.
///
/// All tiers use Nunito for the soft, friendly, slightly-rounded character
/// of the FocusPomo aesthetic. Display tiers use heavier weights (700)
/// instead of an editorial serif. Body tiers favour readability at smaller
/// sizes.
///
/// Letter-spacing is left at 0 by default — Nunito reads well without
/// the negative tracking that an editorial serif required.
abstract final class BloomTypography {
  // Display tier
  static TextStyle get display => GoogleFonts.nunito(
        fontSize: 40,
        height: 48 / 40,
        fontWeight: FontWeight.w700,
      );

  static TextStyle get h1 => GoogleFonts.nunito(
        fontSize: 32,
        height: 40 / 32,
        fontWeight: FontWeight.w700,
      );

  static TextStyle get h2 => GoogleFonts.nunito(
        fontSize: 26,
        height: 34 / 26,
        fontWeight: FontWeight.w700,
      );

  // Title / body
  static TextStyle get h3 => GoogleFonts.nunito(
        fontSize: 22,
        height: 30 / 22,
        fontWeight: FontWeight.w700,
      );

  static TextStyle get h4 => GoogleFonts.nunito(
        fontSize: 18,
        height: 26 / 18,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get bodyLg => GoogleFonts.nunito(
        fontSize: 17,
        height: 26 / 17,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get body => GoogleFonts.nunito(
        fontSize: 15,
        height: 22 / 15,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get bodySm => GoogleFonts.nunito(
        fontSize: 13,
        height: 18 / 13,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get caption => GoogleFonts.nunito(
        fontSize: 12,
        height: 16 / 12,
        letterSpacing: 0.4,
        fontWeight: FontWeight.w600,
      );
}
