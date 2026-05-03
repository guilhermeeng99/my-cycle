import 'package:flutter/material.dart';

import 'package:mycycle/design_system/icons/bloom_icons.dart';
import 'package:mycycle/design_system/tokens/tokens.dart';
import 'package:mycycle/gen/i18n/strings.g.dart';

class TodayLateBanner extends StatelessWidget {
  const TodayLateBanner({required this.daysLate, super.key});

  final int daysLate;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    const tint = BloomColors.honey;

    return Container(
      padding: const EdgeInsets.all(BloomSpacing.s16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            tint.withValues(alpha: 0.14),
            tint.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BloomRadii.card,
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(BloomIcons.clock, size: 16, color: tint),
          ),
          const SizedBox(width: BloomSpacing.s12),
          Expanded(
            child: Text(
              t.today.lateBanner(days: daysLate),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
