import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mycycle/core/constants/app_constants.dart';
import 'package:mycycle/design_system/components/components.dart';
import 'package:mycycle/design_system/icons/bloom_icons.dart';
import 'package:mycycle/design_system/tokens/tokens.dart';
import 'package:mycycle/features/biometric/presentation/cubits/biometric_lock_cubit.dart';
import 'package:mycycle/gen/i18n/strings.g.dart';

class BiometricLockPage extends StatefulWidget {
  const BiometricLockPage({super.key});

  @override
  State<BiometricLockPage> createState() => _BiometricLockPageState();
}

class _BiometricLockPageState extends State<BiometricLockPage> {
  bool _autoTried = false;

  void _unlock() {
    final t = context.t;
    final reason = t.biometric.unlockReason(app: AppConstants.appName);
    unawaited(context.read<BiometricLockCubit>().unlock(reason));
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return BlocBuilder<BiometricLockCubit, BiometricLockState>(
      builder: (context, state) {
        if (state is BiometricLockLocked && !_autoTried) {
          _autoTried = true;
          WidgetsBinding.instance.addPostFrameCallback((_) => _unlock());
        }
        if (state is BiometricLockUnlocked) {
          return const SizedBox.shrink();
        }

        final remaining =
            state is BiometricLockLocked ? state.remainingAttempts : 0;

        return Scaffold(
          body: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  primary.withValues(alpha: 0.12),
                  theme.scaffoldBackgroundColor,
                ],
                stops: const <double>[0, 0.55],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: BloomSpacing.screenEdge,
                ),
                child: Column(
                  children: <Widget>[
                    const Spacer(flex: 2),
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: <Color>[
                            primary.withValues(alpha: 0.20),
                            primary.withValues(alpha: 0.10),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(BloomIcons.lock, size: 36, color: primary),
                    ),
                    const SizedBox(height: BloomSpacing.s32),
                    Text(
                      t.biometric.lockedTitle(app: AppConstants.appName),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: BloomSpacing.s12),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: BloomSpacing.s24,
                      ),
                      child: Text(
                        t.biometric.lockedBody,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const Spacer(flex: 3),
                    BloomPrimaryButton(
                      label: t.biometric.unlockButton,
                      icon: BloomIcons.fingerprint,
                      onPressed: _unlock,
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
                    const SizedBox(height: BloomSpacing.s24),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
