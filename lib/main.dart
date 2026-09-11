import 'package:expense_tracker_app/di/injector.dart';
import 'package:expense_tracker_app/firebase_options.dart';
import 'package:expense_tracker_app/presentation/blocs/blocs.dart';
import 'package:expense_tracker_app/presentation/presentation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 1. Initialize Dependency Injection
  await configureDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => inject<AuthenticationCubit>()),
        BlocProvider(create: (_) => inject<AuthCubit>()),
        BlocProvider(create: (_) => inject<TransactionCubit>()),
        BlocProvider(create: (_) => inject<CategoryCubit>()),
        BlocProvider(create: (_) => inject<ThemeCubit>()),
      ],
      child: const AppView(),
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    //rebuild in the user's preferred theme (Dark or Light) even
    // after they kill and restart the app.
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final themeMode = themeState.themeMode;

        // work logout for register and login
        return BlocListener<AuthenticationCubit, AuthenticationState>(
          listener: (context, state) {
            state.maybeWhen(
              authenticated: (_) {
                context.read<TransactionCubit>().clear();
                context.read<CategoryCubit>().clear();
                navigatorKey.currentState?.pushNamedAndRemoveUntil(
                  '/main',
                  (route) => false,
                );
              },
              unauthenticated: () {
                context.read<TransactionCubit>().clear();
                context.read<CategoryCubit>().clear();
                navigatorKey.currentState?.pushNamedAndRemoveUntil(
                  '/login',
                  (route) => false,
                );
              },
              orElse: () {},
            );
          },
          child: BlocBuilder<AuthenticationCubit, AuthenticationState>(
            builder: (context, authState) {
              return MaterialApp(
                navigatorKey: navigatorKey,
                debugShowCheckedModeBanner: false,
                title: 'Expense Tracker',
                theme: _buildTheme(Brightness.light),
                darkTheme: _buildTheme(Brightness.dark),
                themeMode: themeMode,
                // The "Switchboard": Decides the entry screen based on global session
                home: authState.maybeWhen(
                  authenticated: (_) => const MainScreen(),
                  orElse: () => const LoginScreen(),
                ),
                routes: {
                  '/login': (_) => const LoginScreen(),
                  '/main': (_) => const MainScreen(),
                },
              );
            },
          ),
        );
      },
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepPurple,
        brightness: brightness,
      ),
      useMaterial3: true,
    );
  }
}
