import 'package:flutter/material.dart';

import 'package:mycycle/design_system/tokens/tokens.dart';

class BloomGroupHeader extends StatelessWidget {
  const BloomGroupHeader(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        BloomSpacing.s8,
        0,
        BloomSpacing.s8,
        BloomSpacing.s12,
      ),
      child: Text(
        label.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          letterSpacing: 1.1,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class BloomGroupedList extends StatelessWidget {
  const BloomGroupedList({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BloomRadii.card,
      ),
      child: ClipRRect(
        borderRadius: BloomRadii.card,
        child: Column(
          children: _interleave(theme),
        ),
      ),
    );
  }

  List<Widget> _interleave(ThemeData theme) {
    final out = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      out.add(children[i]);
      if (i != children.length - 1) {
        out.add(_Hairline(color: theme.colorScheme.outline));
      }
    }
    return out;
  }
}

class _Hairline extends StatelessWidget {
  const _Hairline({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: BloomSpacing.s64),
      child: Container(height: 0.5, color: color.withValues(alpha: 0.4)),
    );
  }
}
