import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Bloom typography tokens.
///
/// Display sizes (display/h1/h2) use Fraunces — a soft, editorial serif that
/// gives the journal/diary character. Body sizes (h3 and below) use Inter for
/// best-in-class screen legibility.
///
/// Letter-spacing values are absolute pixels (Flutter convention), pre-computed
/// from the design-spec percentages.
abstract final class BloomTypography {
  // Fraunces (display)
  static TextStyle get display => GoogleFonts.fraunces(
        fontSize: 48,
        height: 56 / 48,
        letterSpacing: -0.72,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get h1 => GoogleFonts.fraunces(
        fontSize: 40,
        height: 48 / 40,
        letterSpacing: -0.4,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get h2 => GoogleFonts.fraunces(
        fontSize: 32,
        height: 40 / 32,
        letterSpacing: -0.16,
        fontWeight: FontWeight.w600,
      );

  // Inter (body and below)
  static TextStyle get h3 => GoogleFonts.inter(
        fontSize: 24,
        height: 32 / 24,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get h4 => GoogleFonts.inter(
        fontSize: 20,
        height: 28 / 20,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get bodyLg => GoogleFonts.inter(
        fontSize: 18,
        height: 28 / 18,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get body => GoogleFonts.inter(
        fontSize: 16,
        height: 24 / 16,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get bodySm => GoogleFonts.inter(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 12,
        height: 16 / 12,
        letterSpacing: 0.06,
        fontWeight: FontWeight.w500,
      );
}
