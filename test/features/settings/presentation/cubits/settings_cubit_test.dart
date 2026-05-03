import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mycycle/core/entities/user.dart';
import 'package:mycycle/core/errors/app_failure.dart';
import 'package:mycycle/core/errors/result.dart';
import 'package:mycycle/features/settings/presentation/cubits/settings_cubit.dart';

import '../../../../harness/factories/couple_factory.dart';
import '../../../../harness/factories/user_factory.dart';
import '../../../../harness/mocks.dart';

class _Fail extends AppFailure {
  const _Fail();
  @override
  String get debugMessage => 'fail';
}

void main() {
  setUpAll(() {
    registerFallbackValue(AppLanguage.ptBr);
  });

  late MockSettingsRepository settingsRepo;
  late MockCoupleRepository coupleRepo;
  late MockAuthRepository authRepo;
  late MockNotificationsRepository notifRepo;

  setUp(() {
    settingsRepo = MockSettingsRepository();
    coupleRepo = MockCoupleRepository();
    authRepo = MockAuthRepository();
    notifRepo = MockNotificationsRepository();
    when(
      () => coupleRepo.watchCouple(any<String>()),
    ).thenAnswer((_) => Stream<dynamic>.value(CoupleFactory.paired()).cast());
  });

  SettingsCubit build(User user) => SettingsCubit(
    initialUser: user,
    settingsRepository: settingsRepo,
    coupleRepository: coupleRepo,
    authRepository: authRepo,
    notificationsRepository: notifRepo,
  );

  group('updateLanguage', () {
    blocTest<SettingsCubit, SettingsState>(
      'persists then mutates the user state on Ok',
      build: () {
        when(
          () => settingsRepo.updateLanguage(
            userId: any(named: 'userId'),
            language: any(named: 'language'),
          ),
        ).thenAnswer((_) async => const Ok<void>(null));
        return build(UserFactory.owner());
      },
      act: (cubit) => cubit.updateLanguage(AppLanguage.en),
      verify: (cubit) {
        final state = cubit.state as SettingsLoaded;
        expect(state.user.language, AppLanguage.en);
        verify(
          () => settingsRepo.updateLanguage(
            userId: any(named: 'userId'),
            language: AppLanguage.en,
          ),
        ).called(1);
      },
    );

    test('does not mutate user state on Err', () async {
      when(
        () => settingsRepo.updateLanguage(
          userId: any(named: 'userId'),
          language: any(named: 'language'),
        ),
      ).thenAnswer((_) async => const Err<void>(_Fail()));

      final cubit = build(UserFactory.owner());
      final before = (cubit.state as SettingsLoaded).user.language;
      await cubit.updateLanguage(AppLanguage.en);
      expect((cubit.state as SettingsLoaded).user.language, before);
    });
  });

  group('setBiometricEnabled', () {
    test('mutates user.biometricEnabled on Ok', () async {
      when(
        () => settingsRepo.updateBiometricEnabled(
          userId: any(named: 'userId'),
          enabled: any(named: 'enabled'),
        ),
      ).thenAnswer((_) async => const Ok<void>(null));

      final cubit = build(UserFactory.owner());
      await cubit.setBiometricEnabled(enabled: true);
      expect((cubit.state as SettingsLoaded).user.biometricEnabled, isTrue);
    });
  });

  group('updateCycleDefaults', () {
    test('mutates couple defaults on Ok', () async {
      when(
        () => settingsRepo.updateCycleDefaults(
          coupleId: any(named: 'coupleId'),
          defaultCycleLength: any(named: 'defaultCycleLength'),
          defaultLutealLength: any(named: 'defaultLutealLength'),
        ),
      ).thenAnswer((_) async => const Ok<void>(null));

      final cubit = build(UserFactory.owner());
      // Wait for couple stream to emit.
      await cubit.stream.firstWhere(
        (s) => s is SettingsLoaded && s.couple != null,
      );

      await cubit.updateCycleDefaults(defaultCycleLength: 30);
      final state = cubit.state as SettingsLoaded;
      expect(state.couple?.defaultCycleLength, 30);
    });

    test('returns Ok-null when there is no couple yet', () async {
      when(() => coupleRepo.watchCouple(any())).thenAnswer(
        (_) => const Stream.empty(),
      );
      final cubit = build(UserFactory.unpaired());
      final result = await cubit.updateCycleDefaults(defaultCycleLength: 30);
      expect(result, isA<Ok<void>>());
    });
  });

  group('setNotificationsEnabled', () {
    test('skips repo write when permission is denied', () async {
      when(notifRepo.requestPermission).thenAnswer((_) async => false);
      final cubit = build(UserFactory.owner());

      await cubit.setNotificationsEnabled(enabled: true);

      verifyNever(
        () => settingsRepo.updateNotificationsEnabled(
          userId: any(named: 'userId'),
          enabled: any(named: 'enabled'),
        ),
      );
      expect(
        (cubit.state as SettingsLoaded).user.notificationsEnabled,
        isFalse,
      );
    });
  });
}
