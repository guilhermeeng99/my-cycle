import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mycycle/core/entities/couple.dart';
import 'package:mycycle/core/entities/user.dart';
import 'package:mycycle/core/errors/result.dart';
import 'package:mycycle/core/notifications/notifications_repository.dart';
import 'package:mycycle/features/auth/domain/repositories/auth_repository.dart';
import 'package:mycycle/features/pairing/domain/entities/invite_code.dart';
import 'package:mycycle/features/pairing/domain/repositories/couple_repository.dart';
import 'package:mycycle/features/settings/domain/repositories/settings_repository.dart';

sealed class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

final class SettingsLoading extends SettingsState {
  const SettingsLoading();
}

final class SettingsLoaded extends SettingsState {
  const SettingsLoaded({
    required this.user,
    this.couple,
    this.activeInviteCode,
    this.isGeneratingInvite = false,
    this.isLeavingCouple = false,
    this.isSigningOut = false,
    this.isDeletingAllData = false,
  });

  final User user;
  final Couple? couple;
  final InviteCode? activeInviteCode;
  final bool isGeneratingInvite;
  final bool isLeavingCouple;
  final bool isSigningOut;
  final bool isDeletingAllData;

  SettingsLoaded copyWith({
    User? user,
    Couple? couple,
    InviteCode? activeInviteCode,
    bool? isGeneratingInvite,
    bool? isLeavingCouple,
    bool? isSigningOut,
    bool? isDeletingAllData,
  }) {
    return SettingsLoaded(
      user: user ?? this.user,
      couple: couple ?? this.couple,
      activeInviteCode: activeInviteCode ?? this.activeInviteCode,
      isGeneratingInvite: isGeneratingInvite ?? this.isGeneratingInvite,
      isLeavingCouple: isLeavingCouple ?? this.isLeavingCouple,
      isSigningOut: isSigningOut ?? this.isSigningOut,
      isDeletingAllData: isDeletingAllData ?? this.isDeletingAllData,
    );
  }

  @override
  List<Object?> get props => [
        user,
        couple,
        activeInviteCode,
        isGeneratingInvite,
        isLeavingCouple,
        isSigningOut,
        isDeletingAllData,
      ];
}

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit({
    required User initialUser,
    required SettingsRepository settingsRepository,
    required CoupleRepository coupleRepository,
    required AuthRepository authRepository,
    required NotificationsRepository notificationsRepository,
  })  : _settingsRepo = settingsRepository,
        _coupleRepo = coupleRepository,
        _authRepo = authRepository,
        _notifRepo = notificationsRepository,
        super(SettingsLoaded(user: initialUser)) {
    final coupleId = initialUser.coupleId;
    if (coupleId != null) {
      _coupleSub = _coupleRepo.watchCouple(coupleId).listen((couple) {
        final s = state;
        if (s is SettingsLoaded) {
          emit(s.copyWith(couple: couple));
        }
      });
    }
  }

  final SettingsRepository _settingsRepo;
  final CoupleRepository _coupleRepo;
  final AuthRepository _authRepo;
  final NotificationsRepository _notifRepo;

  StreamSubscription<Couple?>? _coupleSub;

  Future<Result<void>> updateLanguage(AppLanguage language) async {
    final s = state;
    if (s is! SettingsLoaded) return const Ok<void>(null);
    final result = await _settingsRepo.updateLanguage(
      userId: s.user.id,
      language: language,
    );
    if (result is Ok<void>) {
      emit(s.copyWith(user: s.user.copyWith(language: language)));
    }
    return result;
  }

  Future<Result<InviteCode>> generateInviteCode() async {
    final s = state;
    if (s is! SettingsLoaded || s.couple == null) {
      return Ok<InviteCode>(
        InviteCode(code: '', expiresAt: DateTime.utc(1970)),
      );
    }
    emit(s.copyWith(isGeneratingInvite: true));
    final result = await _coupleRepo.generateInviteCode(s.couple!.id);
    final fresh = state;
    if (fresh is SettingsLoaded) {
      emit(
        fresh.copyWith(
          isGeneratingInvite: false,
          activeInviteCode: result is Ok<InviteCode> ? result.value : null,
        ),
      );
    }
    return result;
  }

  Future<Result<void>> leaveCouple() async {
    final s = state;
    if (s is! SettingsLoaded || s.couple == null) return const Ok<void>(null);
    emit(s.copyWith(isLeavingCouple: true));
    final result = await _coupleRepo.leaveCouple(
      coupleId: s.couple!.id,
      userId: s.user.id,
    );
    final fresh = state;
    if (fresh is SettingsLoaded) {
      emit(fresh.copyWith(isLeavingCouple: false));
    }
    return result;
  }

  /// Toggle the user's notifications preference. When enabling, request
  /// platform permission first; if denied the toggle stays off.
  Future<Result<void>> setNotificationsEnabled({required bool enabled}) async {
    final s = state;
    if (s is! SettingsLoaded) return const Ok<void>(null);

    if (enabled) {
      final granted = await _notifRepo.requestPermission();
      if (!granted) {
        return const Ok<void>(null); // user must grant in system settings
      }
    }

    final result = await _settingsRepo.updateNotificationsEnabled(
      userId: s.user.id,
      enabled: enabled,
    );
    if (result is Ok<void>) {
      emit(s.copyWith(user: s.user.copyWith(notificationsEnabled: enabled)));
    }
    return result;
  }

  Future<Result<void>> setBiometricEnabled({required bool enabled}) async {
    final s = state;
    if (s is! SettingsLoaded) return const Ok<void>(null);
    final result = await _settingsRepo.updateBiometricEnabled(
      userId: s.user.id,
      enabled: enabled,
    );
    if (result is Ok<void>) {
      emit(s.copyWith(user: s.user.copyWith(biometricEnabled: enabled)));
    }
    return result;
  }

  /// Updates the couple's default cycle/luteal length. Owner-only — UI
  /// must hide the controls when the user has [UserRole.partner].
  Future<Result<void>> updateCycleDefaults({
    int? defaultCycleLength,
    int? defaultLutealLength,
  }) async {
    final s = state;
    if (s is! SettingsLoaded || s.couple == null) return const Ok<void>(null);
    final result = await _settingsRepo.updateCycleDefaults(
      coupleId: s.couple!.id,
      defaultCycleLength: defaultCycleLength,
      defaultLutealLength: defaultLutealLength,
    );
    if (result is Ok<void>) {
      emit(
        s.copyWith(
          couple: s.couple!.copyWith(
            defaultCycleLength:
                defaultCycleLength ?? s.couple!.defaultCycleLength,
            defaultLutealLength:
                defaultLutealLength ?? s.couple!.defaultLutealLength,
          ),
        ),
      );
    }
    return result;
  }

  Future<Result<void>> signOut() async {
    final s = state;
    if (s is! SettingsLoaded) return const Ok<void>(null);
    emit(s.copyWith(isSigningOut: true));
    final result = await _authRepo.signOut();
    return result;
  }

  /// Owner-only. Cascades cycle/day data + couple doc, then deletes the
  /// owner's auth account. Sign-out hooks elsewhere clear the local Hive
  /// caches; the partner's stale `coupleId` is reconciled on their next
  /// session (see specs/auth.md BR-7).
  Future<Result<void>> deleteAllData() async {
    final s = state;
    if (s is! SettingsLoaded) return const Ok<void>(null);
    final coupleId = s.user.coupleId;
    if (coupleId == null) return const Ok<void>(null);

    emit(s.copyWith(isDeletingAllData: true));

    final cascade = await _coupleRepo.deleteCoupleData(coupleId);
    if (cascade is Err<void>) {
      final fresh = state;
      if (fresh is SettingsLoaded) {
        emit(fresh.copyWith(isDeletingAllData: false));
      }
      return cascade;
    }

    final accountDelete = await _authRepo.deleteAccount();
    if (accountDelete is Err<void>) {
      final fresh = state;
      if (fresh is SettingsLoaded) {
        emit(fresh.copyWith(isDeletingAllData: false));
      }
    }
    return accountDelete;
  }

  @override
  Future<void> close() async {
    await _coupleSub?.cancel();
    return super.close();
  }
}
