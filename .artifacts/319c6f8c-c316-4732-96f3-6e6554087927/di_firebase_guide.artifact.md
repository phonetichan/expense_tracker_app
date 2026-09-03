# Dependency Injection with GetIt & Injectable: Firebase CRUD Guide

This guide demonstrates how to structure your Firebase CRUD operations (Auth, Category, Transaction) using Dependency Injection (DI) with the `get_it` and `injectable` packages.

## 1. Registering External Dependencies (Firebase)

Since `FirebaseFirestore` and `FirebaseAuth` are third-party classes, we use an `@module` to provide them to the locator.

```dart
// lib/core/di/modules/external_module.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';

@module
abstract class ExternalModule {
  @lazySingleton
  FirebaseFirestore get firestore => FirebaseFirestore.instance;

  @lazySingleton
  FirebaseAuth get auth => FirebaseAuth.instance;
}
```

---

## 2. Repositories with DI

We annotate repositories with `@lazySingleton` or `@LazySingleton(as: ...)`. Notice how we inject `firestore` and `auth` via the constructor.

### Auth Repository
```dart
@lazySingleton
class AuthRepository {
  final FirebaseAuth _firebaseAuth;

  AuthRepository(this._firebaseAuth); // Injected by GetIt

  Future<UserCredential> login({required String email, required String password}) async {
    return await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
  }

  // ... register, logout methods
}
```

### Transaction Repository
```dart
@LazySingleton(as: TransactionRepository)
class TransactionRepositoryImpl implements TransactionRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  TransactionRepositoryImpl({required this.firestore, required this.auth});

  CollectionReference<Map<String, dynamic>> get _collection =>
      firestore.collection('users').doc(auth.currentUser?.uid).collection('transactions');

  @override
  Future<void> addTransaction(TransactionModel transaction) async {
    await _collection.doc(transaction.id).set(transaction.toMap());
  }

  // ... get, update, delete methods
}
```

---

## 3. Cubits/Blocs with DI

Cubits are registered as `@injectable` (factories). They automatically receive the correct repository from `get_it`.

```dart
@injectable
class TransactionCubit extends Cubit<TransactionState> {
  final TransactionRepository _repository;

  TransactionCubit(this._repository) : super(TransactionInitial());

  Future<void> addTransaction(TransactionModel transaction) async {
    emit(TransactionLoading(currentTransactions));
    try {
      await _repository.addTransaction(transaction);
      loadTransactions(); // Reload list
    } catch (e) {
      emit(TransactionError('Failed to add transaction.'));
    }
  }
}
```

---

## 4. Main Configuration

The configuration file ties everything together. After creating this, run `flutter pub run build_runner build`.

```dart
// lib/core/di/injection_container.dart
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'injection_container.config.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async => getIt.init();
```

---

## 5. Usage in UI

In your `main.dart`, initialize the locator once, then use `getIt<T>()` to access your providers.

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await configureDependencies(); // Initialize DI
  runApp(MyApp());
}

// In MyApp MultiBlocProvider
BlocProvider(
  create: (_) => getIt<TransactionCubit>(), // No manual repository instantiation needed!
),
```

## Summary of Benefits
1. **Zero Manual Wiring**: You don't have to pass `firestore` into `TransactionRepository` into `TransactionCubit` manually in `main.dart`.
2. **Clean Main**: `main.dart` stays small and readable.
3. **Easy Testing**: You can easily swap real Firebase with mock versions during unit tests by changing the injection configuration.
