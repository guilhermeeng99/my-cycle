import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:mycycle/app/router/routes.dart';
import 'package:mycycle/core/constants/app_constants.dart';
import 'package:mycycle/design_system/components/components.dart';
import 'package:mycycle/design_system/icons/bloom_icons.dart';
import 'package:mycycle/design_system/tokens/tokens.dart';
import 'package:mycycle/gen/i18n/strings.g.dart';

class PairingChoicePage extends StatelessWidget {
  const PairingChoicePage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.t;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: BloomSpacing.screenEdge,
          ),
          children: <Widget>[
            const SizedBox(height: BloomSpacing.s40),
            BloomLargeHeader(
              title: t.pairingChoice.title(app: AppConstants.appName),
              subtitle: t.pairingChoice.subtitle,
            ),
            _ChoiceCard(
              icon: BloomIcons.heart,
              title: t.pairingChoice.imOwner,
              body: t.pairingChoice.imOwnerBody,
              onTap: () => context.go(AppRoutes.ownerOnboarding),
              accent: true,
            ),
            const SizedBox(height: BloomSpacing.s12),
            _ChoiceCard(
              icon: BloomIcons.link,
              title: t.pairingChoice.imPartner,
              body: t.pairingChoice.imPartnerBody,
              onTap: () => context.go(AppRoutes.partnerPairing),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.onTap,
    this.accent = false,
  });

  final IconData icon;
  final String title;
  final String body;
  final VoidCallback onTap;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tint = theme.colorScheme.primary;
    return Material(
      color: Colors.transparent,
      borderRadius: BloomRadii.card,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            gradient: accent
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      tint.withValues(alpha: 0.12),
                      tint.withValues(alpha: 0.04),
                    ],
                  )
                : null,
            color: accent ? null : theme.colorScheme.surface,
            borderRadius: BloomRadii.card,
          ),
          padding: const EdgeInsets.all(BloomSpacing.s20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: tint.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 18, color: tint),
              ),
              const SizedBox(width: BloomSpacing.s16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: BloomSpacing.s4),
                    Text(
                      body,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: BloomSpacing.s8),
              Icon(
                BloomIcons.chevronRight,
                size: 14,
                color: theme.colorScheme.onSurfaceVariant
                    .withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
