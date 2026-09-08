part of 'theme_cubit.dart';

@freezed
class ThemeState with _$ThemeState {
  const factory ThemeState({
    @Default(ThemeMode.system) ThemeMode themeMode,
  }) = _ThemeState;

  const ThemeState._();

  @override
  // TODO: implement themeMode
  ThemeMode get themeMode => throw UnimplementedError();
}
