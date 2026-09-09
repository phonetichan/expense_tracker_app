import 'package:firebase_auth/firebase_auth.dart';

abstract interface class AuthDataSource {
  /// Stream that emits whenever the user's authentication state changes.
  Stream<User?> get authStateChanges;

  /// Returns the current Firebase User, if any.
  User? get currentUser;

  /// Registers a new user with email and password.
  Future<UserCredential> register({
    required String email,
    required String password,
  });

  /// Logs in an existing user with email and password.
  Future<UserCredential> login({
    required String email,
    required String password,
  });

  /// Logs out the current user.
  Future<void> logout();
}

