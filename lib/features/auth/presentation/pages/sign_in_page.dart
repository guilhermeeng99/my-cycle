import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mycycle/core/constants/app_constants.dart';
import 'package:mycycle/core/errors/result.dart';
import 'package:mycycle/design_system/components/components.dart';
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

    return Scaffold(
      body: SafeArea(
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
    return Column(
      children: <Widget>[
        Image.asset(
          'lib/app/assets/images/logo.png',
          width: 128,
          height: 128,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: BloomSpacing.s24),
        Text(
          appName,
          style: theme.textTheme.displayMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: BloomSpacing.s12),
        Text(
          tagline,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.45,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
