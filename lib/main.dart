import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker_app/presentation/main/main_screen.dart';
import 'package:expense_tracker_app/presentation/transcation/cubit/transcation_cubit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:expense_tracker_app/core/theme/theme_cubit.dart';
import 'package:expense_tracker_app/data/respositories/transaction_repository_impl.dart';
import 'package:expense_tracker_app/data/respository/auth_respository.dart';
import 'package:expense_tracker_app/data/respository/user_respository.dart';
import 'package:expense_tracker_app/firebase_options.dart';
import 'package:expense_tracker_app/presentation/auth/login_screen.dart';
import 'package:expense_tracker_app/presentation/auth/cubit/auth_cubit.dart';
import 'package:expense_tracker_app/presentation/auth/cubit/auth_state.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final authRepository = AuthRepository();
  final userRepository = UserRepository();
  final themeCubit = ThemeCubit(userRepository: userRepository);

  // 1. Load local theme immediately for fastest UI startup
  await themeCubit.loadLocalTheme();

  // 2. If user is already logged in, sync with Firestore in background
  final user = authRepository.currentUser;
  if (user != null) {
    themeCubit.syncWithFirestore(user.uid);
  }

  runApp(
    MyApp(
      authRepository: authRepository,
      userRepository: userRepository,
      themeCubit: themeCubit,
    ),
  );
}

class MyApp extends StatelessWidget {
  final AuthRepository authRepository;
  final UserRepository userRepository;
  final ThemeCubit themeCubit;

  const MyApp({
    super.key,
    required this.authRepository,
    required this.userRepository,
    required this.themeCubit,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthCubit(
            authRepository: authRepository,
            userRepository: userRepository,
          )..checkAuthStatus(),
        ),
        BlocProvider(
          create: (_) => TransactionCubit(
            TransactionRepositoryImpl(
              firestore: FirebaseFirestore.instance,
              auth: FirebaseAuth.instance,
            ),
          ),
        ),
        BlocProvider.value(value: themeCubit),
      ],
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            navigatorKey.currentState?.pushNamedAndRemoveUntil(
              '/login',
              (route) => false,
            );
          }
        },
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            final user = authRepository.currentUser;

            return MaterialApp(
              navigatorKey: navigatorKey,
              debugShowCheckedModeBanner: false,
              title: 'Expense Tracker',
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.deepPurple,
                  brightness: Brightness.light,
                ),
                useMaterial3: true,
              ),
              darkTheme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.deepPurple,
                  brightness: Brightness.dark,
                ),
                useMaterial3: true,
              ),
              themeMode: themeMode,
              // Determine initial screen based on login status
              home: user != null ? const MainScreen() : const LoginScreen(),
              routes: {
                '/login': (context) => const LoginScreen(),
                '/main': (context) => const MainScreen(),
              },
            );
          },
        ),
      ),
    );
  }
}
