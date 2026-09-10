import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import 'auth_data_source.dart';

/// Custom exception for Auth data source errors to avoid "Exception: " prefix.
class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => message;
}

/// Concrete implementation of [AuthDataSource] using the Firebase Authentication SDK.
/// This class serves as the low-level data source that interacts directly with the network.
@LazySingleton(as: AuthDataSource)
class AuthDataSourceImpl implements AuthDataSource {
  final FirebaseAuth _firebaseAuth;

  AuthDataSourceImpl(this._firebaseAuth);

  /// Streams real-time authentication state changes (Logged in, Logged out, etc.)
  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Synchronously returns the current Firebase user profile if one exists.
  @override
  User? get currentUser => _firebaseAuth.currentUser;

  /// Attempts to create a new user account in Firebase.
  /// Throws a translated [Exception] if registration fails.
  @override
  Future<UserCredential> register({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      // Catch specific Firebase errors and map them to readable messages.
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      // Catch generic errors (e.g., parsing or logic errors).
      throw AuthException('An unexpected error occurred during registration.');
    }
  }

  /// Attempts to sign in an existing user via Firebase.
  /// Throws a translated [AuthException] if login fails.
  @override
  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      throw AuthException('An unexpected error occurred during login.');
    }
  }

  /// Triggers the Firebase signOut process.
  @override
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw AuthException('Failed to sign out correctly.');
    }
  }

  /// A private helper that translates technical [FirebaseAuthException] codes
  /// into user-friendly error messages.
  AuthException _mapFirebaseAuthException(FirebaseAuthException e) {
    // Handle network connectivity issues first.
    if (e.code == 'network-request-failed') {
      return AuthException('Please check your internet connection');
    }

    // Map common authentication error codes.
    switch (e.code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return AuthException('Wrong Email or Password');
      case 'email-already-in-use':
        return AuthException('This email is already registered');
      case 'weak-password':
        return AuthException('The password provided is too weak');
      default:
        // Fallback for any other Firebase-specific errors.
        return AuthException(e.message ?? 'Authentication failed');
    }
  }
}
