import 'package:flutter/material.dart';

import 'package:mycycle/design_system/icons/bloom_icons.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              primary.withValues(alpha: 0.10),
              theme.scaffoldBackgroundColor,
            ],
            stops: const <double>[0, 0.55],
          ),
        ),
        child: Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  primary.withValues(alpha: 0.18),
                  primary.withValues(alpha: 0.08),
                ],
              ),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(BloomIcons.heart, color: primary, size: 32),
          ),
        ),
      ),
    );
  }
}
