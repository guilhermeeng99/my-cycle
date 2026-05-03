import 'package:flutter/material.dart';

import 'package:mycycle/core/entities/user.dart';
import 'package:mycycle/design_system/tokens/tokens.dart';

class IdentityCard extends StatelessWidget {
  const IdentityCard({required this.user, super.key});

  final User user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initials = _initials(user.name);

    return Container(
      padding: const EdgeInsets.all(BloomSpacing.cardPadding),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BloomRadii.card,
      ),
      child: Row(
        children: <Widget>[
          _Avatar(photoUrl: user.photoUrl, initials: initials),
          const SizedBox(width: BloomSpacing.s16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  user.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: BloomSpacing.s4),
                Text(
                  user.email,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.photoUrl, required this.initials});
  final String? photoUrl;
  final String initials;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.14),
        shape: BoxShape.circle,
        image: photoUrl != null
            ? DecorationImage(
                image: NetworkImage(photoUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      alignment: Alignment.center,
      child: photoUrl == null
          ? Text(
              initials,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            )
          : null,
    );
  }
}
