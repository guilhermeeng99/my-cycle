import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mycycle/core/constants/app_constants.dart';
import 'package:mycycle/core/errors/result.dart';
import 'package:mycycle/design_system/components/components.dart';
import 'package:mycycle/design_system/icons/bloom_icons.dart';
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
        break;
      case Err(error: GoogleSignInCancelled()):
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Spacer(flex: 3),
                _Hero(appName: AppConstants.appName, tagline: t.signIn.tagline),
                const Spacer(flex: 4),
                BloomPrimaryButton(
                  label: t.signIn.continueWithGoogle,
                  loading: _signingIn,
                  icon: FontAwesomeIcons.google,
                  onPressed: _signIn,
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.appName, required this.tagline});

  final String appName;
  final String tagline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return Column(
      children: <Widget>[
        Container(
          width: 92,
          height: 92,
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
          child: Icon(BloomIcons.heart, color: primary, size: 36),
        ),
        const SizedBox(height: BloomSpacing.s24),
        Text(
          appName,
          style: theme.textTheme.displayMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: BloomSpacing.s12),
        Text(
          tagline,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
