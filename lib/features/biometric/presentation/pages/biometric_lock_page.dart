import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mycycle/design_system/icons/bloom_icons.dart';
import 'package:mycycle/design_system/tokens/tokens.dart';
import 'package:mycycle/features/biometric/presentation/cubits/biometric_lock_cubit.dart';
import 'package:mycycle/gen/i18n/strings.g.dart';

/// Full-screen lock surface. Triggers the biometric prompt automatically
/// on first build; the user can retry via the unlock button.
class BiometricLockPage extends StatefulWidget {
  const BiometricLockPage({super.key});

  @override
  State<BiometricLockPage> createState() => _BiometricLockPageState();
}

class _BiometricLockPageState extends State<BiometricLockPage> {
  bool _autoTried = false;

  void _unlock() {
    final t = context.t;
    unawaited(
      context.read<BiometricLockCubit>().unlock(t.biometric.unlockReason),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);

    return BlocBuilder<BiometricLockCubit, BiometricLockState>(
      builder: (context, state) {
        if (state is BiometricLockLocked && !_autoTried) {
          _autoTried = true;
          WidgetsBinding.instance.addPostFrameCallback((_) => _unlock());
        }
        if (state is BiometricLockUnlocked) {
          // Router redirect handles navigation; render an empty placeholder.
          return const SizedBox.shrink();
        }

        final remaining =
            state is BiometricLockLocked ? state.remainingAttempts : 0;

        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(BloomSpacing.screenEdge),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Icon(
                    BloomIcons.heart,
                    size: 56,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: BloomSpacing.s24),
                  Text(
                    t.biometric.lockedTitle,
                    style: theme.textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: BloomSpacing.s12),
                  Text(
                    t.biometric.lockedBody,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: BloomSpacing.s32),
                  ElevatedButton(
                    onPressed: _unlock,
                    child: Text(t.biometric.unlockButton),
                  ),
                  if (remaining > 0 && remaining < 3) ...<Widget>[
                    const SizedBox(height: BloomSpacing.s16),
                    Text(
                      t.biometric.failedAttempts(n: remaining.toString()),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
