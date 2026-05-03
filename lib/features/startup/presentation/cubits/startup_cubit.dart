import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mycycle/features/auth/domain/auth_state.dart';
import 'package:mycycle/features/auth/presentation/cubits/auth_cubit.dart';

/// Sequences the startup flow: wait for the first auth resolution, run any
/// post-auth initialization (cache warmup, sync), then emit a terminal
/// state the router uses to decide where to send the user.
///
/// Today the only step is waiting for auth — the cubit exists so future
/// initialization (Hive box hydration, Firestore prefetch, biometric
/// gate) plugs in without changing the router or the splash UI.
class StartupCubit extends Cubit<StartupState> {
  StartupCubit({required AuthCubit authCubit})
    : _authCubit = authCubit,
      super(const StartupInitial());

  final AuthCubit _authCubit;

  Future<void> initialize() async {
    if (state is! StartupInitial) return;
    emit(const StartupLoading(progress: 0.2));

    final isAuthenticated = await _waitForAuth();
    emit(const StartupLoading(progress: 0.7));

    if (!isAuthenticated) {
      emit(const StartupUnauthenticated());
      return;
    }

    // Future hooks: warm Hive caches, prefetch current cycle, etc.
    emit(const StartupAuthenticated());
  }

  Future<bool> _waitForAuth() async {
    final current = _authCubit.state;
    if (current is AuthStateAuthenticated) return true;
    if (current is AuthStateUnauthenticated) return false;

    final completer = Completer<bool>();
    final sub = _authCubit.stream.listen((authState) {
      if (authState is AuthStateAuthenticated && !completer.isCompleted) {
        completer.complete(true);
      } else if (authState is AuthStateUnauthenticated &&
          !completer.isCompleted) {
        completer.complete(false);
      }
    });
    final result = await completer.future;
    await sub.cancel();
    return result;
  }
}

sealed class StartupState extends Equatable {
  const StartupState();

  @override
  List<Object?> get props => <Object?>[];
}

final class StartupInitial extends StartupState {
  const StartupInitial();
}

final class StartupLoading extends StartupState {
  const StartupLoading({required this.progress});

  final double progress;

  @override
  List<Object?> get props => <Object?>[progress];
}

final class StartupAuthenticated extends StartupState {
  const StartupAuthenticated();
}

final class StartupUnauthenticated extends StartupState {
  const StartupUnauthenticated();
}
