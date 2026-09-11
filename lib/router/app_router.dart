import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/entities/category_entity.dart';
import '../domain/entities/transaction_entity.dart';
import '../presentation/blocs/authentication_cubit/authentication_cubit.dart';
import '../presentation/presentation.dart';

final appRouter = GoRouter(
  initialLocation: '/main',

  // Global Session Guards (Session Management)
  redirect: (context, state) {
    final authState = context.read<AuthenticationCubit>().state;
    final isAuthenticated = authState is AuthenticationAuthenticated;
    final isGoingToLogin = state.uri.path == '/login';
    final isGoingToRegister = state.uri.path == '/register';

    // Guard: Force unauthenticated sessions out to the login screen
    if (!isAuthenticated && !isGoingToLogin && !isGoingToRegister) {
      return '/login';
    }
    return null;
  },

  routes: [
    // --- AUTHENTICATION ENTRIES ---
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),

    // --- APPLICATION ROOT SHELL ENTRY ---
    GoRoute(
      path: '/main',
      builder: (context, state) => const MainScreen(),
    ),

    // --- TRANSACTION CRUD MANAGEMENT ENTRIES ---
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
        // Safe check for updates: if updating, a TransactionEntity is present, otherwise null.
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

    // --- CATEGORY CRUD MANAGEMENT ENTRIES ---
    GoRoute(
      path: '/category-screen',
      builder: (context, state) => const CategoryScreen(),
    ),
    GoRoute(
      path: '/category-form',
      builder: (context, state) {
        // Safe check for updates: if updating, a CategoryEntity is present, otherwise null.
        final category = state.extra as CategoryEntity?;
        return CategoryFormScreen(category: category);
      },
    ),

    // --- SYSTEM OPTIONS ---
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
  ],
);