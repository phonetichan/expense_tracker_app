import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_state.dart';
part 'theme_cubit.freezed.dart';

@singleton
class ThemeCubit extends Cubit<ThemeState> {
  static const String _themeKey = 'theme_mode';

  ThemeCubit() : super(const ThemeState());

  /// Loads the theme from local SharedPreferences only.
  Future<void> loadLocalTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localTheme = prefs.getString(_themeKey);

      final themeMode = localTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;

      emit(state.copyWith(themeMode: themeMode));
    } catch (e) {
      // Default to system if read fails
      emit(state.copyWith(themeMode: ThemeMode.system));
    }
  }

  /// Toggles the theme and saves it ONLY to local storage.
  Future<void> toggleTheme() async {
    final newMode =
        state.themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;

    final themeStr = newMode == ThemeMode.dark ? 'dark' : 'light';

    // Update UI immediately
    emit(state.copyWith(themeMode: newMode));

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, themeStr);
    } catch (e) {
      // Log error if needed
      print('Failed to save theme: $e');
    }
  }
}
