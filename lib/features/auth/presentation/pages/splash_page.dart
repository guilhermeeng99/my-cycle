import 'package:flutter/material.dart';

/// Shown while the auth state hasn't resolved yet — i.e., before the first
/// Firebase auth check completes. Once the router learns where to send the
/// user (sign-in vs. authenticated home), this page is replaced.
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
