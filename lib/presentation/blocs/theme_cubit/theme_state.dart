part of 'theme_cubit.dart';

@freezed
class ThemeState with _$ThemeState {
  const factory ThemeState.initial() = _Initial;

  const factory ThemeState.loading() = _Loading;

  const factory ThemeState.loaded(
      ThemeMode themeMode,
      ) = _Loaded;

  const factory ThemeState.error(
      String message,
      ) = _Error;
}