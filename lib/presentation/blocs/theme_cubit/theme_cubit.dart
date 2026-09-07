import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/respository/user_respository.dart';

part 'theme_state.dart';
part 'theme_cubit.freezed.dart';

@singleton
class ThemeCubit extends Cubit<ThemeState> {
  final UserRepository userRepository;

  static const String _themeKey = 'theme_mode';

  ThemeCubit({
    required this.userRepository,
  }) : super(const ThemeState.initial());

  Future<void> loadLocalTheme() async {
    emit(const ThemeState.loading());

    try {
      //fetch data form the phone's memory
      // convert it to a usable format
      // update the UI
      final prefs = await SharedPreferences.getInstance();
      final localTheme = prefs.getString(_themeKey);

      final themeMode =
      localTheme == 'dark'
          ? ThemeMode.dark
          : ThemeMode.light;

      emit(ThemeState.loaded(themeMode));
    } catch (e) {
      emit(ThemeState.error(e.toString()));
    }
  }

  // check firestore ui and store it in
  Future<void> syncWithFirestore(String uid) async {
    try {
      final snapshot =
      await userRepository.getUserProfile(uid);

      if (snapshot.exists) {
        final firestoreTheme =
        snapshot.data()?['themeMode'];

        if (firestoreTheme != null) {
          final themeMode =
          firestoreTheme == 'dark'
              ? ThemeMode.dark
              : ThemeMode.light;

          emit(ThemeState.loaded(themeMode));

          final prefs =
          await SharedPreferences.getInstance();

          await prefs.setString(
            _themeKey,
            firestoreTheme,
          );
        }
      }
    } catch (e) {
      emit(ThemeState.error(e.toString()));
    }
  }

  // check current state with freezed maybeWhen
  // Flip the mode (light to Dark)
  // Update UI immediately
  // Save in shared preference
  // Sync to cloud in syncWithFirestore
  Future<void> toggleTheme(String? uid) async {
    final currentTheme = state.maybeWhen(
      loaded: (themeMode) => themeMode,
      orElse: () => ThemeMode.light,
    );

    final newMode =
    currentTheme == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;

    final themeStr =
    newMode == ThemeMode.dark
        ? 'dark'
        : 'light';

    // Update UI immediately
    emit(ThemeState.loaded(newMode));

    try {
      final prefs =
      await SharedPreferences.getInstance();

      await prefs.setString(
        _themeKey,
        themeStr,
      );

      if (uid != null) {
        await userRepository.updateTheme(
          uid: uid,
          themeMode: themeStr,
        );
      }
    } catch (e) {
      emit(ThemeState.error(e.toString()));
    }
  }
}