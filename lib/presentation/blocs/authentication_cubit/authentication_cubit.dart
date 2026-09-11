import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/repositories/user_repository.dart';
import '../theme_cubit/theme_cubit.dart';

part 'authentication_state.dart';
part 'authentication_cubit.freezed.dart';

/// The [AuthenticationCubit] is the "Security Guard" of the application.
/// It manages the global authentication session and user profile data.
class AuthenticationCubit extends Cubit<AuthenticationState> {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  final ThemeCubit _themeCubit;

  /// Holds the active connection to the Firebase Auth stream.
  /// Stored as a variable so we can safely cancel it when the Cubit is closed.
  StreamSubscription? _authSubscription;

  AuthenticationCubit(
    this._authRepository,
    this._userRepository,
    this._themeCubit,
  ) : super(const AuthenticationState.initial());

  /// Returns the current [UserEntity] if the state is [AuthenticationAuthenticated].
  /// Uses a Dart 'switch' expression for concise, type-safe pattern matching.
  UserEntity? get user => switch (state) {
        AuthenticationAuthenticated(user: final user) => user,
        _ => null
      };

  /// Initializes the application's global data (Theme and Auth session).
  Future<void> loadData() async {
    // 1. Load the user's preferred theme from local SharedPreferences.
    await _themeCubit.loadLocalTheme();

    // 2. Set up a reactive listener for Firebase Authentication status changes.
    // We cancel any existing subscription first to prevent duplicate listeners (memory leaks).
    _authSubscription?.cancel();
    _authSubscription = _authRepository.authStateChanges.listen((firebaseUser) async {
      if (firebaseUser == null) {
        // No user is signed in to Firebase.
        emit(const AuthenticationUnauthenticated());
      } else {
        // A user is signed in, now fetch their full profile from Firestore.
        await _fetchUserProfile(firebaseUser.uid);
      }
    });
  }

  /// Fetches the user's profile details from the database using their [uid].
  Future<void> _fetchUserProfile(String uid) async {
    try {
      final profile = await _userRepository.getUserProfile(uid);
      final data = profile.data();

      if (data != null) {
        // Successfully retrieved profile, emit the Authenticated state with user data.
        emit(AuthenticationAuthenticated(
          user: UserEntity(
            uid: uid,
            name: data['name'] ?? '',
            email: data['email'] ?? '',
          ),
        ));
      } else {
        // Profile document missing in Firestore.
        emit(const AuthenticationUnauthenticated());
      }
    } catch (e) {
      // Any error during fetch results in an unauthenticated state for safety.
      emit(const AuthenticationUnauthenticated());
    }
  }

  /// Manually updates the state to Authenticated.
  /// Typically called as a "Handshake" from AuthCubit after a successful login/register.
  void authenticateUser({required UserEntity user}) {
    emit(AuthenticationAuthenticated(user: user));
  }

  /// Signs the user out of the Firebase session.
  /// Note: We don't manually emit a state here because the [_authSubscription] 
  /// will detect the logout and emit [AuthenticationUnauthenticated] automatically.
  Future<void> logOut() async {
    await _authRepository.logout();
  }

  /// Clean-up method called when the Cubit is removed from memory.
  @override
  Future<void> close() {
    // CRITICAL: Permanently stop the Firebase listener to prevent memory leaks 
    // and "emit after close" crashes.
    _authSubscription?.cancel();
    return super.close();
  }
}
