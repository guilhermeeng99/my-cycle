/// Bloom spacing tokens.
///
/// Base unit is 4. Tokens follow an 8-friendly progression with 4-step
/// fine-grain available for tight rows.
abstract final class BloomSpacing {
  static const double s4 = 4;
  static const double s8 = 8;
  static const double s12 = 12;
  static const double s16 = 16;
  static const double s20 = 20;
  static const double s24 = 24;
  static const double s32 = 32;
  static const double s40 = 40;
  static const double s48 = 48;
  static const double s64 = 64;
  static const double s80 = 80;
  static const double s96 = 96;

  /// Default padding from the screen edge to content.
  static const double screenEdge = s20;

  /// Default internal padding for cards.
  static const double cardPadding = s20;

  /// Vertical rhythm between major sections within a screen.
  static const double sectionGap = s32;

  /// Larger vertical rhythm between top-level groupings.
  static const double largeSectionGap = s48;
}
