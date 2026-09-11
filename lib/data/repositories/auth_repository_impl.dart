import 'package:expense_tracker_app/data/datasource/datasource.dart';
import 'package:expense_tracker_app/domain/entities/user_entity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import '../../domain/repositories/auth_repository.dart';

/// Custom exception class to handle and identify errors originating from 
/// database or repository operations.
class DatabaseException implements Exception {
  final String message;
  DatabaseException(this.message);
  
  @override
  String toString() => message;
}

/// Implementation of [AuthRepository] that coordinates between the 
/// [AuthDataSource] (technical) and the Domain layer (entities).
@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource _userDataSource;

  AuthRepositoryImpl(this._userDataSource);

  /// Exposes the current Firebase User status from the data source.
  @override
  User? get currentUser => _userDataSource.currentUser;

  /// Exposes the reactive authentication stream from the data source.
  @override
  Stream<User?> get authStateChanges => _userDataSource.authStateChanges;

  /// Handles user registration. 
  /// It converts the technical [UserCredential] into a clean [UserEntity].
  @override
  Future<UserEntity> register({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _userDataSource.register(
        email: email,
        password: password,
      );
      
      final user = credential.user;
      if (user == null) throw DatabaseException('User registration failed');

      // Map the Firebase-specific User object to our Domain UserEntity.
      return UserEntity(
        uid: user.uid,
        name: user.displayName ?? '',
        email: user.email ?? '',
      );
    } catch (e) {
      // Catch the translated AuthException from the data source
      // and wrap it in DatabaseException for the Cubit.
      throw DatabaseException(e.toString());
    }
  }

  /// Handles user login and profile conversion.
  @override
  Future<UserEntity> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _userDataSource.login(
        email: email,
        password: password,
      );
      
      final user = credential.user;
      if (user == null) throw DatabaseException('User login failed');

      return UserEntity(
        uid: user.uid,
        name: user.displayName ?? '',
        email: user.email ?? '',
      );
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  /// Signs the user out via the data source.
  @override
  Future<void> logout() async {
    try {
      await _userDataSource.logout();
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }
}
