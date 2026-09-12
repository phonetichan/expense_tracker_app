import 'package:expense_tracker_app/di/injector.dart';
import 'package:expense_tracker_app/firebase_options.dart';
import 'package:expense_tracker_app/presentation/blocs/blocs.dart';
import 'package:expense_tracker_app/presentation/navigation/app_router.dart';
import 'package:expense_tracker_app/presentation/presentation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Xiaomi/MIUI ဖုန်းတွေအတွက် အောက်ခြေဘားကို ပျောက်စေမယ့် Code
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent, // Transparent ဖြစ်စေဖို့
      systemNavigationBarDividerColor: Colors.transparent, // ဘားနဲ့ App ကြားက မျဉ်းကို ဖျောက်ဖို့
      systemNavigationBarIconBrightness: Brightness.dark, // Button icon တွေကို မြင်ရအောင်လုပ်ဖို့
      statusBarColor: Colors.transparent,
    ),
  );

  // MIUI မှာ Edge-to-Edge ကို အတင်းအကျပ် (Enforce) လုပ်ခိုင်းခြင်း
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

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

        // Pass the configuration cleanly down to MaterialApp.router
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Expense Tracker',
          theme: _buildTheme(Brightness.light),
          darkTheme: _buildTheme(Brightness.dark),
          themeMode: themeMode,
          routerConfig: inject<AppRouter>().router,
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
