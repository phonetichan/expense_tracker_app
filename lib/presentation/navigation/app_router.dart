import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';

import '../../di/injector.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../blocs/authentication_cubit/authentication_cubit.dart';
import '../presentation.dart';

@lazySingleton
class AppRouter {
  final AuthenticationCubit _authCubit;
  late final GoRouter router;

  AppRouter(this._authCubit) {
    router = GoRouter(
      initialLocation: '/main',
      redirect: (context, state) {
        final authState = _authCubit.state;
        final isGoingToLogin = state.uri.path == '/login';
        final isGoingToRegister = state.uri.path == '/register';

        // User login ဝင်ထားရင် Login/Register page သွားရင် Dashboard ကို ပြန်ပို့
        if (authState is AuthenticationAuthenticated) {
          return (isGoingToLogin || isGoingToRegister) ? '/main' : null;
        }

        // User login မဝင်ထားရင် Login/Register မဟုတ်တဲ့ page သွားရင် Login ကို ပို့
        if (authState is AuthenticationUnauthenticated) {
          return (isGoingToLogin || isGoingToRegister) ? null : '/login';
        }

        return null;
      },
      routes: [
        GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(path: '/main', builder: (context, state) => const MainScreen()),
        GoRoute(
          path: '/transaction-history',
          builder: (context, state) {
            final selectedMonth = state.extra as DateTime?;
            return TransactionHistoryScreen(selectedMonth: selectedMonth);
          },
        ),
        GoRoute(
          path: '/add-transaction',
          builder: (context, state) {
            final transaction = state.extra as TransactionEntity?;
            return AddTransactionScreen(transaction: transaction);
          },
        ),
        GoRoute(
          path: '/transaction-detail',
          builder: (context, state) {
            final transaction = state.extra as TransactionEntity;
            return TransactionDetailScreen(transaction: transaction);
          },
        ),
        GoRoute(
          path: '/category-screen',
          builder: (context, state) => const CategoryScreen(),
        ),
        GoRoute(
          path: '/category-form',
          builder: (context, state) {
            final category = state.extra as CategoryEntity?;
            return CategoryFormScreen(category: category);
          },
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    );
  }
}

// Global alias for compatibility
GoRouter get appRouter => inject<AppRouter>().router;
