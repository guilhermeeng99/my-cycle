import 'package:flutter/material.dart';

/// Bloom raw color tokens — FocusPomo-inspired warm palette.
///
/// Direction: warm beige surfaces, terracotta accent, sage/honey supporting
/// tones. Tokens keep historical names (rose, plum, sage, cream...) so
/// downstream consumers don't break, but values were re-tuned to match
/// the FocusPomo aesthetic. New `terracotta*`, `bege*`, `pebble*` aliases
/// are also exposed for new code that wants intent-revealing names.
///
/// Light-only by design — see `specs/redesign_focuspomo.md` (Decision B1).
/// The mapping into Material 3 [ColorScheme] lives in
/// `app/theme/app_colors.dart`. Direct usage in widgets is discouraged —
/// prefer `Theme.of(context).colorScheme.*`.
abstract final class BloomColors {
  // ── Brand accent (terracotta / coral) ──────────────────────────────────
  /// Primary brand accent. Used for CTAs and the selected-day pill.
  static const Color rose = Color(0xFFD9634F);
  static const Color terracotta = rose;

  /// Pressed / deep variant of the primary accent.
  static const Color roseDeep = Color(0xFFB84A38);
  static const Color terracottaDeep = roseDeep;

  /// Soft container tint used as `primaryContainer`.
  static const Color petalSoft = Color(0xFFF5DDD2);
  static const Color terracottaSoft = petalSoft;

  // ── Supporting tones ───────────────────────────────────────────────────
  /// Secondary accent. Warm cocoa brown.
  static const Color plum = Color(0xFF8C5A45);

  /// Honey / amber — used as warning tone and medium-confidence label.
  static const Color honey = Color(0xFFE5C97D);

  /// Sage green — tertiary tone, ovulation phase, high-confidence label.
  static const Color sage = Color(0xFF7BC57E);

  // ── Surfaces (light-only) ──────────────────────────────────────────────
  /// Outer scaffold background — the warm bege.
  static const Color cream = Color(0xFFF0E6D9);
  static const Color bege = cream;

  /// Card / surface — the slightly lighter inner cream.
  static const Color petalMist = Color(0xFFFAF1E6);
  static const Color surface = petalMist;

  /// Hairline edges and subtle dividers.
  static const Color pearlEdge = Color(0xFFDCD0BE);
  static const Color pebbleEdge = pearlEdge;

  /// Pebble — used for unselected pills, low-emphasis chips, neutral
  /// section backgrounds. Slightly darker than the inner cream.
  static const Color pebble = Color(0xFFE8DECF);

  // ── Ink (text) ─────────────────────────────────────────────────────────
  /// Primary text color — warm deep brown, never pure black.
  static const Color ink = Color(0xFF3C332C);

  /// Secondary text color.
  static const Color inkSoft = Color(0xFF8C7F73);

  /// Tertiary / label / placeholder text.
  static const Color whisperGray = Color(0xFFA89E94);

  // ── Cycle phases ───────────────────────────────────────────────────────
  /// Period / menstrual phase — unified with the brand terracotta.
  static const Color phaseMenstrual = Color(0xFFD9634F);

  /// Follicular phase — warm orange.
  static const Color phaseFollicular = Color(0xFFE68A4A);

  /// Ovulation / fertile window — sage green (matches FocusPomo "Focus").
  static const Color phaseOvulation = Color(0xFF7BC57E);

  /// Luteal phase — warm muted yellow (matches FocusPomo "Fitness").
  static const Color phaseLuteal = Color(0xFFE5C97D);

  // ── Semantic ───────────────────────────────────────────────────────────
  static const Color success = Color(0xFF7BC57E);
  static const Color warning = Color(0xFFE5C97D);
  static const Color error = Color(0xFFC5566B);
  static const Color info = Color(0xFF8FA1B8);
}
