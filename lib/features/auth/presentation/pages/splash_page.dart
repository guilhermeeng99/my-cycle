import 'package:flutter/material.dart';

import 'package:mycycle/design_system/icons/bloom_icons.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      body: Center(
        child: Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: primary.withValues(alpha: 0.16),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(BloomIcons.heart, color: primary, size: 36),
        ),
      ),
    );
  }
}
