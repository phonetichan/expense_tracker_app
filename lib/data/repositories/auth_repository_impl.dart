import 'package:expense_tracker_app/data/datasource/datasource.dart';
import 'package:expense_tracker_app/domain/entities/user_entity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import '../../domain/repositories/auth_repository.dart';

class DatabaseException implements Exception {
  final String message;
  DatabaseException(this.message);
  @override
  String toString() => message;
}

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource _userDataSource;
  AuthRepositoryImpl(this._userDataSource);

  @override
  User? get currentUser => _userDataSource.currentUser;

  @override
  Stream<User?> get authStateChanges => _userDataSource.authStateChanges;

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

      return UserEntity(
        uid: user.uid,
        name: user.displayName ?? '',
        email: user.email ?? '',
      );
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

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

  @override
  Future<void> logout() async {
    try {
      await _userDataSource.logout();
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

}
