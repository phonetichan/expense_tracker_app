
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import 'auth_data_source.dart';

@LazySingleton(as: AuthDataSource)
class AuthDataSourceImpl implements AuthDataSource {
  final FirebaseAuth _firebaseAuth;

  AuthDataSourceImpl(this._firebaseAuth);

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  @override
  User? get currentUser => _firebaseAuth.currentUser;

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
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred during registration.');
    }
  }

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
      throw Exception('An unexpected error occurred during login.');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out correctly.');
    }
  }

  /// Maps technical Firebase errors to user-friendly messages
  /// following your provided style.
  Exception _mapFirebaseAuthException(FirebaseAuthException e) {
    if (e.code == 'network-request-failed') {
      return Exception('Please check your internet connection');
    }

    switch (e.code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return Exception('Wrong Email or Password');
      case 'email-already-in-use':
        return Exception('This email is already registered');
      case 'weak-password':
        return Exception('The password provided is too weak');
      default:
        return Exception(e.message ?? 'Authentication failed');
    }
  }
}