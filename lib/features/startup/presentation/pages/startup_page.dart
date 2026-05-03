import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mycycle/design_system/tokens/tokens.dart';
import 'package:mycycle/features/startup/presentation/cubits/startup_cubit.dart';
import 'package:mycycle/gen/i18n/strings.g.dart';

/// First screen rendered while [StartupCubit] resolves auth and runs any
/// initial work. Once it emits a terminal state, the router redirect takes
/// over and replaces this page.
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
    final t = context.t;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(BloomSpacing.screenEdge),
          child: Column(
            children: <Widget>[
              const Spacer(flex: 3),
              Text(
                t.appName,
                style: theme.textTheme.displayLarge?.copyWith(
                  color: theme.colorScheme.primary,
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
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 3,
                      backgroundColor: theme.colorScheme.surfaceContainerHigh,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary,
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
    );
  }
}
