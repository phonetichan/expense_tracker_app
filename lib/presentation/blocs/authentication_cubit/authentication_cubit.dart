import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import '../../../data/respository/auth_respository.dart';
import '../../../data/respository/user_respository.dart';
import '../../../domain/user.dart';

part 'authentication_state.dart';
part 'authentication_cubit.freezed.dart';

@singleton
class AuthenticationCubit extends Cubit<AuthenticationState> {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  AuthenticationCubit(
    this._authRepository,
    this._userRepository,
  ) : super(const AuthenticationState.initial());

  /// Helper getter to access the user object when authenticated
  UserEntity? get user => state.maybeWhen(
        authenticated: (user) => user,
        orElse: () => null,
      );

  /// 1. Initialization: Check if a user is already logged in (e.g. at app start)
  Future<void> loadData() async {
    final firebaseUser = _authRepository.currentUser;

    if (firebaseUser != null) {
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
          // If Firestore profile is missing, we consider them unauthenticated
          emit(const AuthenticationState.unauthenticated());
        }
      } catch (e) {
        emit(const AuthenticationState.unauthenticated());
      }
    } else {
      emit(const AuthenticationState.unauthenticated());
    }
  }

  /// 2. Handshake: Update global auth state from Login/Register Cubits
  Future<void> authenticateUser({
    required UserEntity user,
  }) async {
    emit(AuthenticationState.authenticated(user: user));
  }

  /// 3. Global Logout
  Future<void> logOut() async {
    await _authRepository.logout();
    emit(const AuthenticationState.unauthenticated());
  }
}
