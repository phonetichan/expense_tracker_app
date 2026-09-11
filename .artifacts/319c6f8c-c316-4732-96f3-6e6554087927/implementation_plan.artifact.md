# Dependency Injection Plan with GetIt and Injectable

This plan outlines the migration to a modern, code-generated dependency injection setup using `get_it` and `injectable`.

## User Review Required

> [!IMPORTANT]
> We will be using `injectable` to automatically generate the `get_it` registration code. This requires running `build_runner` to generate the boilerplate.

## Proposed Changes

### Configuration

#### [MODIFY] [pubspec.yaml](file:///home/thet-mon/Flutter_Project/expense_tracker_app/pubspec.yaml)
- Add `dependencies`:
    - `get_it: ^8.0.2`
    - `injectable: ^2.5.0`
- Add `dev_dependencies`:
    - `injectable_generator: ^2.6.2`
    - `build_runner: ^2.4.13`

---

### Core Infrastructure

#### [NEW] `lib/core/di/injection_container.dart`
- Initialize `GetIt` and configure `injectable`.
- Create a `configureDependencies()` function.

#### [NEW] `lib/core/di/modules/external_module.dart`
- Define an `@module` class to provide third-party dependencies:
    - `FirebaseFirestore`
    - `FirebaseAuth`
    - `SharedPreferences` (Pre-resolved)

---

### Refactoring Repositories & Cubits

#### [MODIFY] Repositories
- Annotate `AuthRepository`, `UserRepository`, `TransactionRepositoryImpl`, and `CategoryRepository` with `@LazySingleton(as: ...)` or `@lazySingleton`.

#### [MODIFY] Cubits
- Annotate `AuthCubit`, `TransactionCubit`, `CategoryCubit`, and `ThemeCubit` with `@injectable`.

---

### Application Entry Point

#### [MODIFY] [main.dart](file:///home/thet-mon/Flutter_Project/expense_tracker_app/lib/main.dart)
- Call `configureDependencies()` in `main()`.
- Access instances via `getIt<T>()` instead of manual constructor calls.

## Verification Plan

### Automated Tests
- Run `flutter pub run build_runner build --delete-conflicting-outputs`.
- Verify that `injection_container.config.dart` is generated correctly.

### Manual Verification
- Verify app launches and navigates as expected.
- Check that all data loads correctly on all screens.
