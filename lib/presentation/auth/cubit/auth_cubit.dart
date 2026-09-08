import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker_app/presentation/auth/cubit/auth_state.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/repositories/category_repository.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../blocs/authentication_cubit/authentication_cubit.dart';

@injectable
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;
  final UserRepository userRepository;
  final CategoryRepository categoryRepository;
  final AuthenticationCubit _authenticationCubit;

  AuthCubit({
    required this.authRepository,
    required this.userRepository,
    required this.categoryRepository,
    required AuthenticationCubit authenticationCubit,
  }) : _authenticationCubit = authenticationCubit,
       super(const AuthState.initial());

  void checkAuthStatus() {
    final user = authRepository.currentUser;

    if (user != null) {
      emit(AuthState.authenticated(email: user.email ?? ''));
    } else {
      emit(const AuthState.unauthenticated());
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    // Step 2: AuthCubit emits AuthState.loading() -> UI shows spinner
    emit(const AuthState.loading());

    try {
      print('🔵 Registration started');
      print('📧 Email: $email');

      // Step 3: AuthCubit calls AuthRepository.register() -> Firebase Success!
      final credential = await authRepository.register(
        email: email,
        password: password,
      );

      final user = credential.user;

      if (user == null) {
        print('❌ Firebase user is null');
        emit(const AuthState.error('Registration failed.'));
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
      );

      print('✅ User profile created successfully');

      // 3. Create default categories
      print('🟡 Creating default categories...');

      await categoryRepository.createDefaultCategories(user.uid);

      print('✅ Default categories created successfully');
      
      // Step 4: THE HANDSHAKE -> AuthCubit calls global AuthenticationCubit
      // Step 5: AuthenticationCubit emits AuthenticationState.authenticated(user)
      _authenticationCubit.authenticateUser(
        user: UserEntity(
          uid: user.uid,
          name: name,
          email: email,
        ),
      );

      print('🎉 Registration completed successfully');
      // Step 6: AuthCubit emits AuthState.success()
      // Step 7: UI hears success and navigates to Dashboard
      emit(const AuthState.success());
    } on FirebaseAuthException catch (e) {
      final message = _getAuthErrorMessage(e);
      emit(AuthState.error(message));
    } catch (e) {
      emit(const AuthState.error('Registration failed. Please try again.'));
    }
  }

  Future<void> login({required String email, required String password}) async {
    // Step 2: AuthCubit emits AuthState.loading() -> UI shows spinner
    emit(const AuthState.loading());

    try {
      // Step 3: AuthCubit calls AuthRepository.login() -> Firebase Success!
      final credential = await authRepository.login(
        email: email,
        password: password,
      );
      final user = credential.user;

      if (user != null) {
        final profile = await userRepository.getUserProfile(user.uid);
        final data = profile.data();

        // Step 4: THE HANDSHAKE -> AuthCubit calls global AuthenticationCubit
        // Step 5: AuthenticationCubit emits AuthenticationState.authenticated(user)
        _authenticationCubit.authenticateUser(
          user: UserEntity(
            uid: user.uid,
            name: data?['name'] ?? '',
            email: user.email ?? '',
          ),
        );

        print('--- Injection & Repository Coordination Log ---');
        print('User-repository:');
        print('  uid: ${user.uid}');
        print('  name: ${data?['name']}');
        print('  email: ${user.email}');
        print('---------------------------------------------');
      }
      // Step 6: AuthCubit emits AuthState.success()
      // Step 7: UI hears success and navigates to Dashboard
      emit(const AuthState.success());
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential' ||
          e.code == 'wrong-password' ||
          e.code == 'user-not-found') {
        emit(const AuthState.error('Invalid email or password'));
      } else if (e.code == 'invalid-email') {
        emit(const AuthState.error('Please enter a valid email'));
      } else {
        emit(AuthState.error(e.message ?? 'Login failed. Please try again.'));
      }
    } catch (e) {
      emit(const AuthState.error('Login failed. Please try again.'));
    }
  }

  Future<void> logout() async {
    emit(const AuthState.loading());

    try {
      await authRepository.logout();
      _authenticationCubit.logOut();
      emit(const AuthState.unauthenticated());
    } catch (e) {
      emit(const AuthState.error('Logout failed.'));
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
