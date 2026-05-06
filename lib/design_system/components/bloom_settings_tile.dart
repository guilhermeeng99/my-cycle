import 'package:flutter/material.dart';

import 'package:mycycle/design_system/icons/bloom_icons.dart';
import 'package:mycycle/design_system/tokens/tokens.dart';

/// Single row inside a `BloomGroupedList` — circular icon badge on the
/// left, title (+ optional subtitle), value/chevron/trailing on the right.
/// Optional `bottom` slot embeds a control (e.g. a `BloomSegmented`).
///
/// FocusPomo-tuned: icon badges are circular and 40×40 (matches the email /
/// Instagram tiles in the FocusPomo settings page). Tap targets are sized
/// for thumb interaction (~56pt min height).
///
/// When [solidIcon] is true the badge fills with the tint color and the
/// icon renders in `onPrimary` (white-on-color, like Email/Instagram in
/// FocusPomo). When false (default), the badge uses a soft tinted bg with
/// the icon in the tint color — calmer, the right call for most rows.
///
/// Example:
/// ```dart
/// BloomSettingsTile(
///   icon: BloomIcons.bell,
///   title: t.settings.notificationsTitle,
///   subtitle: t.settings.notificationsBody,
///   trailing: Switch(value: enabled, onChanged: cubit.setNotifications),
/// )
/// ```
class BloomSettingsTile extends StatelessWidget {
  const BloomSettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.bottom,
    this.value,
    this.onTap,
    this.iconTint,
    this.solidIcon = false,
    this.destructive = false,
    super.key,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget? bottom;
  final String? value;
  final VoidCallback? onTap;
  final Color? iconTint;
  final bool solidIcon;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleColor = destructive
        ? theme.colorScheme.error
        : theme.colorScheme.onSurface;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: BloomSpacing.s16,
            vertical: BloomSpacing.s16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  _IconBadge(
                    icon: icon,
                    tint: iconTint ?? theme.colorScheme.primary,
                    solid: solidIcon,
                    onTint: theme.colorScheme.onPrimary,
                  ),
                  const SizedBox(width: BloomSpacing.s16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          title,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: titleColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (subtitle != null) ...<Widget>[
                          const SizedBox(height: BloomSpacing.s4),
                          Text(
                            subtitle!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: BloomSpacing.s12),
                  _Trailing(
                    value: value,
                    trailing: trailing,
                    hasOnTap: onTap != null,
                  ),
                ],
              ),
              if (bottom != null) ...<Widget>[
                const SizedBox(height: BloomSpacing.s12),
                Padding(
                  padding: const EdgeInsets.only(left: 56),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: bottom,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({
    required this.icon,
    required this.tint,
    required this.solid,
    required this.onTint,
  });

  final IconData icon;
  final Color tint;
  final bool solid;
  final Color onTint;

  @override
  Widget build(BuildContext context) {
    final bg = solid ? tint : tint.withValues(alpha: 0.16);
    final fg = solid ? onTint : tint;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 18, color: fg),
    );
  }
}

class _Trailing extends StatelessWidget {
  const _Trailing({
    required this.value,
    required this.trailing,
    required this.hasOnTap,
  });
  final String? value;
  final Widget? trailing;
  final bool hasOnTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final children = <Widget>[];

    if (value != null) {
      children.add(
        Text(
          value!,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
    if (trailing != null) children.add(trailing!);
    if (hasOnTap && trailing == null) {
      if (children.isNotEmpty) {
        children.add(const SizedBox(width: BloomSpacing.s8));
      }
      children.add(
        Icon(
          BloomIcons.chevronRight,
          size: 14,
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
        ),
      );
    }

    if (children.isEmpty) return const SizedBox.shrink();
    return Row(mainAxisSize: MainAxisSize.min, children: children);
  }
}
