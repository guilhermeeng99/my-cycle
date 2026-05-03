import 'package:flutter/material.dart';

import 'package:mycycle/design_system/icons/bloom_icons.dart';
import 'package:mycycle/design_system/tokens/tokens.dart';

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
            vertical: BloomSpacing.s12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  _IconChip(
                    icon: icon,
                    tint: iconTint ?? theme.colorScheme.primary,
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
                            fontWeight: FontWeight.w500,
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
                  padding: const EdgeInsets.only(left: 52),
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

class _IconChip extends StatelessWidget {
  const _IconChip({required this.icon, required this.tint});
  final IconData icon;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(BloomRadii.md),
      ),
      child: Icon(icon, size: 16, color: tint),
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
