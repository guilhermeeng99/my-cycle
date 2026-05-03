import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mycycle/app/theme/app_theme.dart';
import 'package:mycycle/features/auth/domain/auth_state.dart';
import 'package:mycycle/features/auth/domain/repositories/auth_repository.dart';
import 'package:mycycle/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:mycycle/features/auth/presentation/pages/sign_in_page.dart';
import 'package:mycycle/gen/i18n/strings.g.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    LocaleSettings.setLocaleSync(AppLocale.en);
  });

  testWidgets('SignInPage renders Bloom branding and continue button',
      (tester) async {
    final repository = _MockAuthRepository();
    when(repository.watchAuthState)
        .thenAnswer((_) => const Stream<AuthState>.empty());

    await tester.pumpWidget(
      TranslationProvider(
        child: BlocProvider<AuthCubit>(
          create: (_) => AuthCubit(repository: repository),
          child: MaterialApp(
            theme: AppTheme.light(),
            home: const SignInPage(),
          ),
        ),
      ),
    );

    expect(find.text('MyCycle'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
