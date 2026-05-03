import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'package:mycycle/core/clock/clock.dart';
import 'package:mycycle/core/entities/user.dart';
import 'package:mycycle/core/errors/result.dart';
import 'package:mycycle/core/utils/dates.dart';
import 'package:mycycle/features/onboarding/domain/failures/onboarding_failure.dart';
import 'package:mycycle/features/onboarding/domain/repositories/onboarding_repository.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  OnboardingRepositoryImpl({
    required FirebaseFirestore firestore,
    required Clock clock,
  })  : _firestore = firestore,
        _clock = clock;

  final FirebaseFirestore _firestore;
  final Clock _clock;

  /// Writes user + couple + first cycle as **sequential** writes (not a
  /// transaction). Order matters for security rules: couple → user → cycle.
  ///
  /// **Why not `runTransaction`?** Firestore security rules evaluate each
  /// write independently against the **committed** DB state — they do not see
  /// in-flight transactional writes via `get()`. Our cycle rule calls
  /// `isCoupleOwner(coupleId)` which `get()`s the parent couple. Inside a
  /// transaction the couple write is buffered, so the cycle rule sees no
  /// parent and denies the write, aborting the transaction.
  ///
  /// Sequential writes commit each step before the next begins, so by the
  /// time the cycle rule runs, the couple is in DB. Trade-off: not atomic.
  /// If a later step fails we may leave an orphan couple/user — the user can
  /// safely retry, and we accept a small data-inconsistency window.
  @override
  Future<Result<void>> completeOwnerOnboarding({
    required String userId,
    required String name,
    required String email,
    required DateTime lastPeriodStart,
    required int defaultCycleLength,
    required bool notificationsEnabled,
    required AppLanguage language,
    String? photoUrl,
  }) async {
    final validation = _validate(
      lastPeriodStart: lastPeriodStart,
      defaultCycleLength: defaultCycleLength,
    );
    if (validation != null) return Err<void>(validation);

    try {
      final userRef = _firestore.collection('users').doc(userId);
      final coupleRef = _firestore.collection('couples').doc();
      final cycleRef = coupleRef.collection('cycles').doc();
      final now = _clock.now();
      final nowTs = Timestamp.fromDate(now);

      // 1. Couple — must exist before the cycle rule check passes.
      await coupleRef.set(<String, dynamic>{
        'ownerId': userId,
        'partnerId': null,
        'inviteCode': null,
        'inviteExpiresAt': null,
        'defaultCycleLength': defaultCycleLength,
        'defaultLutealLength': 14,
        'createdAt': nowTs,
        'updatedAt': nowTs,
      });

      // 2. User doc with coupleId. Reactive AuthCubit picks this up and the
      // router redirects /pairing-choice → /home.
      await userRef.set(<String, dynamic>{
        'name': name,
        'email': email,
        'photoUrl': photoUrl,
        'coupleId': coupleRef.id,
        'role': 'owner',
        'language': language.name,
        'biometricEnabled': false,
        'notificationsEnabled': notificationsEnabled,
        'createdAt': nowTs,
        'updatedAt': nowTs,
      });

      // 3. First cycle. Parent couple is now in DB; rule check passes.
      await cycleRef.set(<String, dynamic>{
        'startDate': formatIsoDate(lastPeriodStart),
        'periodEndDate': null,
        'totalLengthDays': null,
        'predictedNextStart': null,
        'predictedNextStartRangeEnd': null,
        'predictedOvulation': null,
        'predictionConfidence': null,
        'createdAt': nowTs,
        'updatedAt': nowTs,
      });

      return const Ok<void>(null);
    } on FirebaseException catch (e, stack) {
      debugPrint(
        'Onboarding write failed: [${e.code}] ${e.message}\n$stack',
      );
      if (e.code == 'unavailable' || e.code == 'deadline-exceeded') {
        return const Err<void>(OnboardingNetworkFailure());
      }
      return Err<void>(OnboardingStorageFailure(e.code, e.message ?? ''));
    } on Object catch (e, stack) {
      debugPrint('Onboarding unexpected failure: $e\n$stack');
      return Err<void>(UnknownOnboardingFailure(e));
    }
  }

  OnboardingFailure? _validate({
    required DateTime lastPeriodStart,
    required int defaultCycleLength,
  }) {
    if (lastPeriodStart.isAfter(_clock.now())) {
      return const OnboardingValidationFailure(
        'lastPeriodStart',
        'Future dates are not allowed',
      );
    }
    if (defaultCycleLength < 21 || defaultCycleLength > 45) {
      return const OnboardingValidationFailure(
        'defaultCycleLength',
        'Cycle length must be between 21 and 45 days',
      );
    }
    return null;
  }
}
