import 'package:flutter/material.dart';

import 'package:mycycle/core/entities/user.dart';
import 'package:mycycle/design_system/tokens/tokens.dart';

/// Identity card for the Settings screen.
///
/// Renders the signed-in user as the first row. When [partner] is provided
/// (couple is paired), a second row appears below a hairline divider so
/// both members of the couple are visible "side by side" — matching the
/// FocusPomo "Family Sharing" pattern but adapted for two profiles.
class IdentityCard extends StatelessWidget {
  const IdentityCard({required this.user, this.partner, super.key});

  final User user;
  final User? partner;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(BloomSpacing.cardPadding),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BloomRadii.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _PersonRow(user: user),
          if (partner != null) ...<Widget>[
            const SizedBox(height: BloomSpacing.s16),
            Divider(
              height: 1,
              thickness: 0.5,
              color: theme.colorScheme.outline.withValues(alpha: 0.5),
            ),
            const SizedBox(height: BloomSpacing.s16),
            _PersonRow(user: partner!),
          ],
        ],
      ),
    );
  }
}

class _PersonRow extends StatelessWidget {
  const _PersonRow({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initials = _initials(user.name);
    return Row(
      children: <Widget>[
        _Avatar(photoUrl: user.photoUrl, initials: initials),
        const SizedBox(width: BloomSpacing.s16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                user.name.isEmpty ? '—' : user.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (user.email.isNotEmpty) ...<Widget>[
                const SizedBox(height: BloomSpacing.s4),
                Text(
                  user.email,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
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
        color: theme.colorScheme.primary.withValues(alpha: 0.16),
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
