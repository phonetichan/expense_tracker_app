import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_state.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = AuthInitial;
  const factory AuthState.loading() = AuthLoading;
  const factory AuthState.success() = AuthSuccess;
  const factory AuthState.error(String message) = AuthError;
  
  // These are for session state, though AuthenticationCubit handles this now.
  const factory AuthState.authenticated({required String email}) = AuthAuthenticated;
  const factory AuthState.unauthenticated() = AuthUnauthenticated;
}
