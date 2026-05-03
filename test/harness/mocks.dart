import 'package:mocktail/mocktail.dart';

import 'package:mycycle/core/clock/clock.dart';
import 'package:mycycle/core/notifications/notifications_repository.dart';
import 'package:mycycle/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:mycycle/features/auth/domain/repositories/auth_repository.dart';
import 'package:mycycle/features/cycle/data/datasources/cycle_remote_datasource.dart';
import 'package:mycycle/features/cycle/domain/repositories/cycle_repository.dart';
import 'package:mycycle/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:mycycle/features/pairing/domain/repositories/couple_repository.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockOnboardingRepository extends Mock implements OnboardingRepository {}

class MockCycleRemoteDataSource extends Mock implements CycleRemoteDataSource {}

class MockCycleRepository extends Mock implements CycleRepository {}

class MockCoupleRepository extends Mock implements CoupleRepository {}

class MockClock extends Mock implements Clock {}

class MockNotificationsRepository extends Mock
    implements NotificationsRepository {}
