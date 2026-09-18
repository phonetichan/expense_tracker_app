import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'dart:async';

import 'package:flutter/material.dart';

import '../../di/injector.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../blocs/authentication_cubit/authentication_cubit.dart';
import '../presentation.dart';

// Helper class to convert any Stream into a Listenable for GoRouter
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final appRouter = GoRouter(
  initialLocation: '/main',
  refreshListenable: GoRouterRefreshStream(
    inject<AuthenticationCubit>().stream,
  ),
  redirect: (context, state) {
    final authState = context.read<AuthenticationCubit>().state;

    if (authState is AuthenticationInitial) {
      return null;
    }

    final isAuthenticated = authState is AuthenticationAuthenticated;
    final isGoingToLogin = state.uri.path == '/login';
    final isGoingToRegister = state.uri.path == '/register';

    if (!isAuthenticated && !isGoingToLogin && !isGoingToRegister) {
      return '/login';
    }

    if (isAuthenticated && (isGoingToLogin || isGoingToRegister)) {
      return '/main';
    }

    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (context, state) => LoginScreen()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/main',
      builder: (context, state) {
        final uid = FirebaseAuth.instance.currentUser!.uid;

        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) =>
              inject<TransactionCubit>()..loadTransactions(),
            ),
            BlocProvider(
              create: (context) =>
              inject<CategoryCubit>()..loadAllCategories(uid: uid),
            ),
          ],
          child: const MainScreen(),
        );
      },
    ),
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
