import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/respository/user_respository.dart';

@lazySingleton
class ThemeCubit extends Cubit<ThemeMode> {
  final UserRepository userRepository;
  static const String _themeKey = 'theme_mode';

  ThemeCubit({
    required this.userRepository,
  }) : super(ThemeMode.light);

  /// 1. Load Local Theme (Always call this at main() startup)
  Future<void> loadLocalTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final localTheme = prefs.getString(_themeKey);
    
    if (localTheme == 'dark') {
      emit(ThemeMode.dark);
    } else {
      emit(ThemeMode.light);
    }
  }

  /// 2. Sync with Firestore (Call this on Login or AuthAuthenticated)
  Future<void> syncWithFirestore(String uid) async {
    try {
      final snapshot = await userRepository.getUserProfile(uid);
      
      if (snapshot.exists) {
        final firestoreTheme = snapshot.data()?['themeMode'];
        
        if (firestoreTheme != null) {
          final mode = firestoreTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;
          
          // Emit firestore theme and update local storage
          emit(mode);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_themeKey, firestoreTheme);
          
          print('Theme synced from Firestore: $firestoreTheme');
        }
      }
    } catch (e) {
      print('Error syncing theme: $e');
    }
  }

  Future<void> toggleTheme(String? uid) async {
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    final themeStr = newMode == ThemeMode.dark ? 'dark' : 'light';

    // Update UI immediately
    emit(newMode);

    try {
      // Save locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, themeStr);

      // Save to Firestore if logged in
      if (uid != null) {
        await userRepository.updateTheme(
          uid: uid,
          themeMode: themeStr,
        );
      }
      
      print('Theme saved: $themeStr');
    } catch (e) {
      print('Error saving theme: $e');
    }
  }
}
