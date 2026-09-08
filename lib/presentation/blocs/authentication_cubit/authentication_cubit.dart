import 'dart:async';
import 'package:expense_tracker_app/presentation/blocs/blocs.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/entities/user_entity.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/repositories/user_repository.dart';

part 'authentication_state.dart';
part 'authentication_cubit.freezed.dart';

@singleton
class AuthenticationCubit extends Cubit<AuthenticationState> {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  final ThemeCubit _themeCubit;
  StreamSubscription? _authSubscription;

  AuthenticationCubit(
    this._authRepository,
    this._userRepository,
    this._themeCubit,
  ) : super(const AuthenticationState.initial());

  /// Helper getter to access the user object when authenticated
  UserEntity? get user =>
      state.maybeWhen(authenticated: (user) => user, orElse: () => null);

  /// 1. Initialization: Setup listeners and load theme
  Future<void> loadData() async {
    // 1. Trigger theme loading from local storage
    await _themeCubit.loadLocalTheme();

    // 2. Monitor Firebase Auth state changes
    final Completer<void> firstCheckCompleter = Completer<void>();
    
    _authSubscription?.cancel();
    _authSubscription = _authRepository.authStateChanges.listen((firebaseUser) async {
      if (firebaseUser == null) {
        emit(const AuthenticationState.unauthenticated());
      } else {
        await _fetchUserProfile(firebaseUser);
      }
      
      // Mark the very first check as complete so the app can start
      if (!firstCheckCompleter.isCompleted) {
        firstCheckCompleter.complete();
      }
    });

    // Wait for the first response from Firebase before returning
    return firstCheckCompleter.future;
  }

  /// Internal helper to fetch user profile and emit state
  Future<void> _fetchUserProfile(User firebaseUser) async {
    try {
      final profile = await _userRepository.getUserProfile(firebaseUser.uid);
      final data = profile.data();

      if (data != null) {
        final userEntity = UserEntity(
          uid: firebaseUser.uid,
          name: data['name'] ?? '',
          email: firebaseUser.email ?? '',
        );
        emit(AuthenticationState.authenticated(user: userEntity));
      } else {
        // This might happen during registration before Firestore is updated
        // We can wait or retry, but for now, stay unauthenticated
        emit(const AuthenticationState.unauthenticated());
      }
    } catch (e) {
      emit(const AuthenticationState.unauthenticated());
    }
  }

  /// Manually trigger an update (Useful for Registration handshake)
  void authenticateUser({required UserEntity user}) {
    emit(AuthenticationState.authenticated(user: user));
  }

  /// Global Logout
  Future<void> logOut() async {
    await _authRepository.logout();
    // The authSubscription will automatically catch the null user and emit unauthenticated
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
