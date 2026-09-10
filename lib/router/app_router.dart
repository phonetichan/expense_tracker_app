import 'package:expense_tracker_app/presentation/presentation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../presentation/blocs/authentication_cubit/authentication_cubit.dart';

final appRouter = GoRouter(
  initialLocation: '/login',

  redirect: (context, state) {
    final authState = context.read<AuthenticationCubit>().state;

    final isAuthenticated = authState is AuthenticationAuthenticated;

    final isGoingToLogin = state.uri.path == '/login';

    if (!isAuthenticated && !isGoingToLogin) {
      return '/login';
    }

    if (isAuthenticated && isGoingToLogin) {
      return '/main';
    }

    return null;
  },

  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) {
        return const LoginScreen();
      },
    ),

    GoRoute(
      path: '/main',
      builder: (context, state) {
        return const MainScreen();
      },
    ),

    GoRoute(
      path: '/dashboard',
      builder: (context, state) {
        return const DashboardScreen();
      },

    ),

    GoRoute(
      path: '/analysis',
      builder: (context, state) {
        return const AnalysisScreen();
      },

    ),

    GoRoute(
      path: '/profile',
      builder: (context, state) {
        return const ProfileScreen();
      },

    ),
  ],
);
