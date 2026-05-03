import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mycycle/core/errors/result.dart';
import 'package:mycycle/design_system/tokens/tokens.dart';
import 'package:mycycle/features/auth/domain/failures/auth_failure.dart';
import 'package:mycycle/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:mycycle/gen/i18n/strings.g.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  bool _signingIn = false;

  Future<void> _signIn() async {
    if (_signingIn) return;
    setState(() => _signingIn = true);
    final result = await context.read<AuthCubit>().signInWithGoogle();
    if (!mounted) return;
    setState(() => _signingIn = false);

    final t = context.t;
    switch (result) {
      case Ok():
        // Navigation is driven by AuthCubit's stream → router redirect.
        break;
      case Err(error: GoogleSignInCancelled()):
        // Silent: deliberate user dismiss.
        break;
      case Err(error: AuthNetworkFailure()):
        _showError(t.signIn.networkError);
      case Err():
        _showError(t.signIn.genericError);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Spacer(flex: 2),
              Text(
                t.appName,
                style: theme.textTheme.displayLarge?.copyWith(
                  color: theme.colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: BloomSpacing.s16),
              Text(
                t.signIn.tagline,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 3),
              ElevatedButton(
                onPressed: _signingIn ? null : _signIn,
                child: _signingIn
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.onPrimary,
                          ),
                        ),
                      )
                    : Text(t.signIn.continueWithGoogle),
              ),
              const SizedBox(height: BloomSpacing.s24),
              Text(
                t.signIn.privacyHint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: BloomSpacing.s16),
            ],
          ),
        ),
      ),
    );
  }
}
