// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:cloud_firestore/cloud_firestore.dart' as _i974;
import 'package:expense_tracker_app/data/repositories/auth_repository_impl.dart'
    as _i1008;
import 'package:expense_tracker_app/data/repositories/category_repository_impl.dart'
    as _i862;
import 'package:expense_tracker_app/data/repositories/transaction_repository_impl.dart'
    as _i825;
import 'package:expense_tracker_app/data/repositories/user_repository_impl.dart'
    as _i1027;
import 'package:expense_tracker_app/di/modules/firebase.dart' as _i980;
import 'package:expense_tracker_app/domain/repositories/auth_repository.dart'
    as _i527;
import 'package:expense_tracker_app/domain/repositories/category_repository.dart'
    as _i965;
import 'package:expense_tracker_app/domain/repositories/transaction_repository.dart'
    as _i532;
import 'package:expense_tracker_app/domain/repositories/user_repository.dart'
    as _i807;
import 'package:expense_tracker_app/presentation/auth/cubit/auth_cubit.dart'
    as _i365;
import 'package:expense_tracker_app/presentation/blocs/authentication_cubit/authentication_cubit.dart'
    as _i40;
import 'package:expense_tracker_app/presentation/blocs/blocs.dart' as _i54;
import 'package:expense_tracker_app/presentation/blocs/theme_cubit/theme_cubit.dart'
    as _i1042;
import 'package:expense_tracker_app/presentation/category/cubit/category_cubit.dart'
    as _i975;
import 'package:expense_tracker_app/presentation/transaction/cubit/transaction_cubit.dart'
    as _i978;
import 'package:firebase_auth/firebase_auth.dart' as _i59;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final firebaseModule = _$FirebaseModule();
    gh.singleton<_i1042.ThemeCubit>(() => _i1042.ThemeCubit());
    gh.lazySingleton<_i59.FirebaseAuth>(() => firebaseModule.firebaseAuth);
    gh.lazySingleton<_i974.FirebaseFirestore>(
      () => firebaseModule.firebaseFireStore,
    );
    gh.lazySingleton<_i532.TransactionRepository>(
      () => _i825.TransactionRepositoryImpl(
        firestore: gh<_i974.FirebaseFirestore>(),
        auth: gh<_i59.FirebaseAuth>(),
      ),
    );
    gh.factory<_i978.TransactionCubit>(
      () => _i978.TransactionCubit(gh<_i532.TransactionRepository>()),
    );
    gh.lazySingleton<_i807.UserRepository>(
      () => _i1027.UserRepositoryImpl(gh<_i974.FirebaseFirestore>()),
    );
    gh.lazySingleton<_i527.AuthRepository>(
      () => _i1008.AuthRepositoryImpl(gh<_i59.FirebaseAuth>()),
    );
    gh.lazySingleton<_i965.CategoryRepository>(
      () => _i862.CategoryRepositoryImpl(
        firestore: gh<_i974.FirebaseFirestore>(),
      ),
    );
    gh.singleton<_i40.AuthenticationCubit>(
      () => _i40.AuthenticationCubit(
        gh<_i527.AuthRepository>(),
        gh<_i807.UserRepository>(),
        gh<_i54.ThemeCubit>(),
      ),
    );
    gh.factory<_i975.CategoryCubit>(
      () => _i975.CategoryCubit(gh<_i965.CategoryRepository>()),
    );
    gh.factory<_i365.AuthCubit>(
      () => _i365.AuthCubit(
        authRepository: gh<_i527.AuthRepository>(),
        userRepository: gh<_i807.UserRepository>(),
        categoryRepository: gh<_i965.CategoryRepository>(),
        authenticationCubit: gh<_i40.AuthenticationCubit>(),
      ),
    );
    return this;
  }
}

class _$FirebaseModule extends _i980.FirebaseModule {}
