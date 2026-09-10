import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/repositories/category_repository.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../blocs/authentication_cubit/authentication_cubit.dart';
import '../../transaction/cubit/transaction_cubit.dart';
import '../../category/cubit/category_cubit.dart';
import '../../../di/injector.dart';
import 'auth_state.dart';

@injectable
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  final CategoryRepository _categoryRepository;
  final AuthenticationCubit _authenticationCubit;

  AuthCubit(
    this._authRepository,
    this._userRepository,
    this._categoryRepository,
    this._authenticationCubit,
  ) : super(const AuthState.initial());

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    emit(const AuthState.loading());

    try {
      final user = await _authRepository.register(
        email: email,
        password: password,
      );

      await _userRepository.createUserProfile(
        uid: user.uid,
        name: name,
        email: email,
      );

      await _categoryRepository.createDefaultCategories(user.uid);
      
      inject<TransactionCubit>().clear();
      inject<CategoryCubit>().clear();

      _authenticationCubit.authenticateUser(user: user);
      emit(const AuthState.success());
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(const AuthState.loading());

    try {
      final user = await _authRepository.login(
        email: email,
        password: password,
      );

      final profile = await _userRepository.getUserProfile(user.uid);
      final data = profile.data();

      final authenticatedUser = UserEntity(
        uid: user.uid,
        name: data?['name'] ?? user.name,
        email: user.email,
      );

      inject<TransactionCubit>().clear();
      inject<CategoryCubit>().clear();

      _authenticationCubit.authenticateUser(user: authenticatedUser);
      emit(const AuthState.success());
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }

  Future<void> logout() async {
    emit(const AuthState.loading());
    try {
      await _authRepository.logout();
      _authenticationCubit.logOut();
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }
}
