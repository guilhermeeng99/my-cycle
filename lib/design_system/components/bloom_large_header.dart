import 'package:flutter/material.dart';

import 'package:mycycle/design_system/tokens/tokens.dart';

/// Page-level header — the primary screen title (e.g. "Today", "Settings").
///
/// FocusPomo-tuned: Nunito 700 in warm brown ink, no editorial letter-spacing.
/// Sits flush against the scaffold background with breathing room above
/// (matches the FocusPomo "Focus Session Timeline" heading weight).
///
/// Example:
/// ```dart
/// BloomLargeHeader(
///   title: t.today.title,
///   subtitle: t.today.subtitle,
/// );
/// ```
class BloomLargeHeader extends StatelessWidget {
  const BloomLargeHeader({
    required this.title,
    this.subtitle,
    this.trailing,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        BloomSpacing.screenEdge,
        BloomSpacing.s24,
        BloomSpacing.screenEdge,
        BloomSpacing.s20,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (subtitle != null) ...<Widget>[
                  const SizedBox(height: BloomSpacing.s8),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
