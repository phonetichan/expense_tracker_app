import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/repositories/user_repository.dart';
import '../theme_cubit/theme_cubit.dart';

part 'authentication_state.dart';
part 'authentication_cubit.freezed.dart';

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

  UserEntity? get user => switch (state) {
        AuthenticationAuthenticated(user: final user) => user,
        _ => null
      };

  Future<void> loadData() async {
    // 1. Load Theme (From local storage)
    await _themeCubit.loadLocalTheme();

    // 2. Listen to Firebase for the User session
    _authSubscription?.cancel();
    _authSubscription = _authRepository.authStateChanges.listen((firebaseUser) async {
      if (firebaseUser == null) {
        emit(const AuthenticationState.unauthenticated());
      } else {
        await _fetchUserProfile(firebaseUser.uid);
      }
    });
  }

  Future<void> _fetchUserProfile(String uid) async {
    try {
      final profile = await _userRepository.getUserProfile(uid);
      final data = profile.data();

      if (data != null) {
        emit(AuthenticationState.authenticated(
          user: UserEntity(
            uid: uid,
            name: data['name'] ?? '',
            email: data['email'] ?? '',
          ),
        ));
      } else {
        emit(const AuthenticationState.unauthenticated());
      }
    } catch (e) {
      emit(const AuthenticationState.unauthenticated());
    }
  }

  void authenticateUser({required UserEntity user}) {
    emit(AuthenticationState.authenticated(user: user));
  }

  Future<void> logOut() async {
    await _authRepository.logout();
    // No emit needed, the stream listener handles it
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
