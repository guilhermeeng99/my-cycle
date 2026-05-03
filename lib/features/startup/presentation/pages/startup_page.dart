import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mycycle/core/constants/app_constants.dart';
import 'package:mycycle/design_system/icons/bloom_icons.dart';
import 'package:mycycle/design_system/tokens/tokens.dart';
import 'package:mycycle/features/startup/presentation/cubits/startup_cubit.dart';

class StartupPage extends StatefulWidget {
  const StartupPage({super.key});

  @override
  State<StartupPage> createState() => _StartupPageState();
}

class _StartupPageState extends State<StartupPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(context.read<StartupCubit>().initialize());
    });
  }

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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: BloomSpacing.screenEdge,
            ),
            child: Column(
              children: <Widget>[
                const Spacer(flex: 3),
                Container(
                  width: 88,
                  height: 88,
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
                  child: Icon(BloomIcons.heart, color: primary, size: 34),
                ),
                const SizedBox(height: BloomSpacing.s24),
                Text(
                  AppConstants.appName,
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(flex: 2),
                BlocBuilder<StartupCubit, StartupState>(
                  builder: (context, state) {
                    final progress = state is StartupLoading
                        ? state.progress
                        : null;
                    return SizedBox(
                      width: 96,
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(BloomRadii.pill),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 3,
                          backgroundColor: theme.colorScheme.outline
                              .withValues(alpha: 0.3),
                          valueColor: AlwaysStoppedAnimation<Color>(primary),
                        ),
                      ),
                    );
                  },
                ),
                const Spacer(flex: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
