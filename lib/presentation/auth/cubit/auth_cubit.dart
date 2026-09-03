import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker_app/data/respositories/category_repository_impl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker_app/data/respository/auth_respository.dart';
import 'package:expense_tracker_app/data/respository/user_respository.dart';
import 'package:expense_tracker_app/presentation/auth/cubit/auth_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;
  final UserRepository userRepository;

  AuthCubit({required this.authRepository, required this.userRepository})
    : super(AuthInitial());

  void checkAuthStatus() {
    final user = authRepository.currentUser;

    if (user != null) {
      emit(AuthAuthenticated(email: user.email ?? '',));
    } else {
      emit(AuthUnauthenticated());
    }
  }
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String themeMode,
  }) async {
    emit(AuthLoading());

    try {
      print('🔵 Registration started');
      print('📧 Email: $email');

      // 1. Create Firebase Auth user
      final credential = await authRepository.register(
        email: email,
        password: password,
      );

      final user = credential.user;

      if (user == null) {
        print('❌ Firebase user is null');
        emit(AuthError('Registration failed.'));
        return;
      }

      print('✅ Firebase Auth user created');
      print('👤 UID: ${user.uid}');

      // 2. Create user profile
      print('🟡 Creating user profile...');

      await userRepository.createUserProfile(
        uid: user.uid,
        name: name,
        email: email,
        themeMode: themeMode,
      );

      print('✅ User profile created successfully');

      // 3. Create default categories
      print('🟡 Creating default categories...');

      final categoryRepository = CategoryRepository(
        firestore: FirebaseFirestore.instance,
      );

      await categoryRepository.createDefaultCategories(user.uid);

      print('✅ Default categories created successfully');
      print('📂 Categories path: users/${user.uid}/categories');

      // 4. Registration complete
      print('🎉 Registration completed successfully');

      emit(AuthAuthenticated(email: email));
    } on FirebaseAuthException catch (e) {
      print('❌ Firebase Auth Error');
      print('Code: ${e.code}');
      print('Message: ${e.message}');

      final message = _getAuthErrorMessage(e);
      emit(AuthError(message));
    } catch (e, stackTrace) {
      print('❌ Registration Error: $e');
      print('📍 StackTrace: $stackTrace');

      emit(AuthError('Registration failed. Please try again.'));
    }
  }

  Future<void> login({required String email, required String password}) async {
    emit(AuthLoading());

    try {
      await authRepository.login(email: email, password: password);

      emit(AuthAuthenticated(email: email));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential' ||
          e.code == 'wrong-password' ||
          e.code == 'user-not-found') {
        emit(AuthError('Invalid email or password'));
      } else if (e.code == 'invalid-email') {
        emit(AuthError('Please enter a valid email'));
      } else {
        emit(AuthError(e.message ?? 'Login failed. Please try again.'));
      }
    } catch (e) {
      emit(AuthError('Login failed. Please try again.'));
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());

    try {
      await authRepository.logout();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError('Logout failed.'));
    }
  }

  String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return e.message ?? 'Authentication failed.';
    }
  }
}
