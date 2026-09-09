import 'package:firebase_auth/firebase_auth.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  User? get currentUser;
  Stream<User?> get authStateChanges;
  Future<UserEntity> register({required String email, required String password});
  Future<UserEntity> login({required String email, required String password});
  Future<void> logout();
}
