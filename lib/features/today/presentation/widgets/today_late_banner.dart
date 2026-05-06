import 'package:flutter/material.dart';

import 'package:mycycle/design_system/icons/bloom_icons.dart';
import 'package:mycycle/design_system/tokens/tokens.dart';
import 'package:mycycle/gen/i18n/strings.g.dart';

/// Honey-toned banner shown when the period is overdue by 3+ days.
///
/// FocusPomo-tuned: soft honey fill (no gradient), circular icon badge,
/// brown ink copy. Reads as informational, never alarming.
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
        color: tint.withValues(alpha: 0.16),
        borderRadius: BloomRadii.card,
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: tint,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              BloomIcons.clock,
              size: 18,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: BloomSpacing.s12),
          Expanded(
            child: Text(
              t.today.lateBanner(days: daysLate),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
