import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mycycle/core/entities/couple.dart';
import 'package:mycycle/core/errors/result.dart';
import 'package:mycycle/features/pairing/domain/failures/pairing_failure.dart';
import 'package:mycycle/features/pairing/domain/repositories/couple_repository.dart';
import 'package:mycycle/features/pairing/presentation/cubits/partner_pairing_cubit.dart';

import '../../../../harness/factories/couple_factory.dart';

class _MockCoupleRepository extends Mock implements CoupleRepository {}

void main() {
  late _MockCoupleRepository repository;

  setUp(() {
    repository = _MockCoupleRepository();
  });

  PartnerPairingCubit buildCubit() {
    return PartnerPairingCubit(
      coupleRepository: repository,
      partnerId: 'partner-uid',
    );
  }

  test('starts at Idle', () {
    final cubit = buildCubit();
    expect(cubit.state, isA<PartnerPairingIdle>());
  });

  blocTest<PartnerPairingCubit, PartnerPairingState>(
    'redeem emits Redeeming → Success on Ok',
    setUp: () {
      when(
        () => repository.redeemInviteCode(
          partnerId: any(named: 'partnerId'),
          code: any(named: 'code'),
        ),
      ).thenAnswer((_) async => Ok<Couple>(CoupleFactory.paired()));
    },
    build: buildCubit,
    act: (cubit) => cubit.redeem('abc234'),
    expect: () => [
      isA<PartnerPairingRedeeming>(),
      isA<PartnerPairingSuccess>(),
    ],
    verify: (_) {
      verify(
        () => repository.redeemInviteCode(
          partnerId: 'partner-uid',
          code: 'ABC234',
        ),
      ).called(1);
    },
  );

  blocTest<PartnerPairingCubit, PartnerPairingState>(
    'redeem emits Redeeming → Failure(Invalid) on Err',
    setUp: () {
      when(
        () => repository.redeemInviteCode(
          partnerId: any(named: 'partnerId'),
          code: any(named: 'code'),
        ),
      ).thenAnswer((_) async => const Err<Couple>(InvalidInviteCode()));
    },
    build: buildCubit,
    act: (cubit) => cubit.redeem('XYZ234'),
    expect: () => [
      isA<PartnerPairingRedeeming>(),
      isA<PartnerPairingFailureState>(),
    ],
  );

  blocTest<PartnerPairingCubit, PartnerPairingState>(
    'reset() returns to Idle from Failure state',
    setUp: () {
      when(
        () => repository.redeemInviteCode(
          partnerId: any(named: 'partnerId'),
          code: any(named: 'code'),
        ),
      ).thenAnswer((_) async => const Err<Couple>(ExpiredInviteCode()));
    },
    build: buildCubit,
    act: (cubit) async {
      await cubit.redeem('XYZ234');
      cubit.reset();
    },
    expect: () => [
      isA<PartnerPairingRedeeming>(),
      isA<PartnerPairingFailureState>(),
      isA<PartnerPairingIdle>(),
    ],
  );
}
