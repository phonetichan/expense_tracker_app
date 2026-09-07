// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:cloud_firestore/cloud_firestore.dart' as _i974;
import 'package:expense_tracker_app/data/respository/category_repository.dart'
    as _i907;
import 'package:expense_tracker_app/data/respository/transaction_repository.dart'
    as _i472;
import 'package:expense_tracker_app/data/respository/auth_respository.dart'
    as _i721;
import 'package:expense_tracker_app/data/respository/user_respository.dart'
    as _i13;
import 'package:expense_tracker_app/di/modules/firebase.dart' as _i980;
import 'package:expense_tracker_app/domain/transaction.dart'
    as _i277;
import 'package:expense_tracker_app/presentation/auth/cubit/auth_cubit.dart'
    as _i365;
import 'package:expense_tracker_app/presentation/blocs/authentication_cubit/authentication_cubit.dart'
    as _i40;
import 'package:expense_tracker_app/presentation/blocs/theme_cubit/theme_cubit.dart'
    as _i1042;
import 'package:expense_tracker_app/presentation/category/cubit/category_cubit.dart'
    as _i975;
import 'package:expense_tracker_app/presentation/transcation/cubit/transcation_cubit.dart'
    as _i131;
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
    gh.lazySingleton<_i59.FirebaseAuth>(() => firebaseModule.firebaseAuth);
    gh.lazySingleton<_i974.FirebaseFirestore>(
      () => firebaseModule.firebaseFireStore,
    );
    gh.lazySingleton<_i277.TransactionRepository>(
      () => _i472.TransactionRepositoryImpl(
        firestore: gh<_i974.FirebaseFirestore>(),
        auth: gh<_i59.FirebaseAuth>(),
      ),
    );
    gh.factory<_i131.TransactionCubit>(
      () => _i131.TransactionCubit(gh<_i277.TransactionRepository>()),
    );
    gh.lazySingleton<_i907.CategoryRepository>(
      () => _i907.CategoryRepository(firestore: gh<_i974.FirebaseFirestore>()),
    );
    gh.factory<_i975.CategoryCubit>(
      () => _i975.CategoryCubit(gh<_i907.CategoryRepository>()),
    );
    gh.lazySingleton<_i13.UserRepository>(
      () => _i13.UserRepository(gh<_i974.FirebaseFirestore>()),
    );
    gh.lazySingleton<_i721.AuthRepository>(
      () => _i721.AuthRepository(gh<_i59.FirebaseAuth>()),
    );
    gh.singleton<_i1042.ThemeCubit>(
      () => _i1042.ThemeCubit(userRepository: gh<_i13.UserRepository>()),
    );
    gh.singleton<_i40.AuthenticationCubit>(
      () => _i40.AuthenticationCubit(
        gh<_i721.AuthRepository>(),
        gh<_i13.UserRepository>(),
      ),
    );
    gh.factory<_i365.AuthCubit>(
      () => _i365.AuthCubit(
        authRepository: gh<_i721.AuthRepository>(),
        userRepository: gh<_i13.UserRepository>(),
        authenticationCubit: gh<_i40.AuthenticationCubit>(),
      ),
    );
    return this;
  }
}

class _$FirebaseModule extends _i980.FirebaseModule {}
