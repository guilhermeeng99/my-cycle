import 'package:flutter/material.dart';

import 'package:mycycle/design_system/tokens/tokens.dart';

/// Section title that sits ABOVE a [BloomGroupedList] — uppercase, muted,
/// FocusPomo-style "SUPPORT US" / "PAYMENT" / "MORE" pattern.
///
/// Example:
/// ```dart
/// BloomGroupHeader(t.settings.preferences);
/// BloomGroupedList(children: [...]);
/// ```
class BloomGroupHeader extends StatelessWidget {
  const BloomGroupHeader(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        BloomSpacing.s12,
        0,
        BloomSpacing.s12,
        BloomSpacing.s12,
      ),
      child: Text(
        label.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Vertical list of tiles wrapped in a single rounded card.
///
/// FocusPomo settings model: each section is a cream-surface rounded
/// rectangle that floats over the bege scaffold. Tiles inside are separated
/// by a hairline indented past the icon column.
///
/// Example:
/// ```dart
/// BloomGroupedList(
///   children: [
///     BloomSettingsTile(icon: ..., title: ..., onTap: ...),
///     BloomSettingsTile(icon: ..., title: ..., onTap: ...),
///   ],
/// );
/// ```
class BloomGroupedList extends StatelessWidget {
  const BloomGroupedList({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BloomRadii.card,
      ),
      child: ClipRRect(
        borderRadius: BloomRadii.card,
        child: Column(children: _interleave(theme)),
      ),
    );
  }

  List<Widget> _interleave(ThemeData theme) {
    final out = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      out.add(children[i]);
      if (i != children.length - 1) {
        out.add(_Hairline(color: theme.colorScheme.outline));
      }
    }
    return out;
  }
}

class _Hairline extends StatelessWidget {
  const _Hairline({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    // Indented past the 40px icon badge + 16px gutter + 16px tile padding
    // so the divider lines up with the tile title baseline (FocusPomo style).
    return Padding(
      padding: const EdgeInsets.only(left: 72),
      child: Container(height: 0.5, color: color.withValues(alpha: 0.5)),
    );
  }
}
