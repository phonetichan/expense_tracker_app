import 'package:injectable/injectable.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/repositories/user_repository.dart';
import '../theme_cubit/theme_cubit.dart';
import 'authentication_cubit.dart';

@module
abstract class AuthenticationCubitProvider {
  @preResolve
  @singleton
  Future<AuthenticationCubit> provide(
    AuthRepository authRepository,
    UserRepository userRepository,
    ThemeCubit themeCubit,
  ) async {
    final instance = AuthenticationCubit(
      authRepository,
      userRepository,
      themeCubit,
    );
    await instance.loadData();
    return instance;
  }
}
