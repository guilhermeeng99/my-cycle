import 'package:flutter/material.dart';

import 'package:mycycle/design_system/tokens/tokens.dart';

/// A cream-surface rounded card with an internal title row and a body slot.
///
/// The atomic content unit FocusPomo uses for everything from "Send
/// Feedback" to "About FocusPomo": a soft surface above the bege scaffold,
/// optional icon + title at the top, and arbitrary children below.
///
/// Pass [trailing] for a per-card action (e.g. an edit chevron, a status
/// pill). Pass [onTap] to make the whole card tappable.
///
/// Example:
/// ```dart
/// BloomSectionCard(
///   title: t.today.todaysFocus,
///   icon: BloomIcons.bloom,
///   children: [PhaseNarrative(...), const SizedBox(height: 12), Notes(...)],
/// );
/// ```
class BloomSectionCard extends StatelessWidget {
  const BloomSectionCard({
    required this.children,
    this.title,
    this.icon,
    this.iconTint,
    this.trailing,
    this.onTap,
    this.padding = const EdgeInsets.all(BloomSpacing.cardPadding),
    super.key,
  });

  final List<Widget> children;
  final String? title;
  final IconData? icon;
  final Color? iconTint;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final card = Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BloomRadii.card,
      ),
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (title != null) ...<Widget>[
            _Header(
              title: title!,
              icon: icon,
              iconTint: iconTint ?? theme.colorScheme.primary,
              trailing: trailing,
            ),
            const SizedBox(height: BloomSpacing.s16),
          ],
          ...children,
        ],
      ),
    );

    if (onTap == null) return card;
    return Material(
      color: Colors.transparent,
      borderRadius: BloomRadii.card,
      clipBehavior: Clip.antiAlias,
      child: InkWell(onTap: onTap, child: card),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.icon,
    required this.iconTint,
    required this.trailing,
  });

  final String title;
  final IconData? icon;
  final Color iconTint;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: <Widget>[
        if (icon != null) ...<Widget>[
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconTint.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: iconTint),
          ),
          const SizedBox(width: BloomSpacing.s12),
        ],
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        ?trailing,
      ],
    );
  }
}
