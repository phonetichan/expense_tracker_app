import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//DI & Config
import 'package:expense_tracker_app/firebase_options.dart';
import 'di/injector.dart';

//Core & Logic
import 'package:expense_tracker_app/core/theme/theme_cubit.dart';
import 'package:expense_tracker_app/data/respository/auth_respository.dart';

//Presentation
import 'package:expense_tracker_app/presentation/presentation.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 1. Initialize Dependency Injection (Builds the pantry)
  await configureDependencies();

  // 2. Grabs tools from DI instead of manual creation
  final themeCubit = inject<ThemeCubit>();
  await themeCubit.loadLocalTheme();

  final authRepo = inject<AuthRepository>();
  if (authRepo.currentUser != null) {
    themeCubit.syncWithFirestore(authRepo.currentUser!.uid);
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => inject<AuthCubit>()..checkAuthStatus(),
        ),
        BlocProvider(
          create: (_) => inject<TransactionCubit>(),
        ),
        BlocProvider(create: (_) => inject<CategoryCubit>(),),
        BlocProvider(
          create: (_) => inject<ThemeCubit>(),
        )
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
            final user = inject<AuthRepository>().currentUser;

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
