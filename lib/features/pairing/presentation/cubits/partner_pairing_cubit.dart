import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mycycle/core/errors/result.dart';
import 'package:mycycle/features/pairing/domain/failures/pairing_failure.dart';
import 'package:mycycle/features/pairing/domain/repositories/couple_repository.dart';

sealed class PartnerPairingState extends Equatable {
  const PartnerPairingState();

  @override
  List<Object?> get props => [];
}

final class PartnerPairingIdle extends PartnerPairingState {
  const PartnerPairingIdle();
}

final class PartnerPairingRedeeming extends PartnerPairingState {
  const PartnerPairingRedeeming();
}

final class PartnerPairingSuccess extends PartnerPairingState {
  const PartnerPairingSuccess();
}

final class PartnerPairingFailureState extends PartnerPairingState {
  const PartnerPairingFailureState(this.failure);
  final PairingFailure failure;

  @override
  List<Object?> get props => [failure];
}

class PartnerPairingCubit extends Cubit<PartnerPairingState> {
  PartnerPairingCubit({
    required CoupleRepository coupleRepository,
    required this.partnerId,
  })  : _coupleRepo = coupleRepository,
        super(const PartnerPairingIdle());

  final CoupleRepository _coupleRepo;
  final String partnerId;

  Future<void> redeem(String code) async {
    final trimmed = code.trim().toUpperCase();
    emit(const PartnerPairingRedeeming());
    final result = await _coupleRepo.redeemInviteCode(
      partnerId: partnerId,
      code: trimmed,
    );
    if (isClosed) return;
    switch (result) {
      case Ok():
        emit(const PartnerPairingSuccess());
      case Err(:final error):
        emit(PartnerPairingFailureState(error as PairingFailure));
    }
  }

  void reset() {
    if (state is PartnerPairingFailureState) {
      emit(const PartnerPairingIdle());
    }
  }
}
