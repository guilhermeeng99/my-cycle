import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:mycycle/app/router/routes.dart';
import 'package:mycycle/design_system/tokens/tokens.dart';
import 'package:mycycle/gen/i18n/strings.g.dart';

class PairingChoicePage extends StatelessWidget {
  const PairingChoicePage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(BloomSpacing.screenEdge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Spacer(flex: 2),
              Text(
                t.pairingChoice.title,
                style: theme.textTheme.displayMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: BloomSpacing.s16),
              Text(
                t.pairingChoice.subtitle,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 3),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.ownerOnboarding),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: BloomSpacing.s4,
                  ),
                  child: Text(t.pairingChoice.imOwner),
                ),
              ),
              const SizedBox(height: BloomSpacing.s12),
              OutlinedButton(
                onPressed: () => context.go(AppRoutes.partnerPairing),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: BloomSpacing.s4,
                  ),
                  child: Text(t.pairingChoice.imPartner),
                ),
              ),
              const SizedBox(height: BloomSpacing.s32),
            ],
          ),
        ),
      ),
    );
  }
}
