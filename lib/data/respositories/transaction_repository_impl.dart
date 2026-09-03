import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import '../../domain/transaction_repository.dart';
import '../model/transaction_model.dart';

@LazySingleton(as: TransactionRepository)
class TransactionRepositoryImpl implements TransactionRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  TransactionRepositoryImpl({
    required this.firestore,
    required this.auth,
  });

  CollectionReference<Map<String, dynamic>> get _transactionCollection {
    final user = auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }
  //security
    return firestore
        .collection('users')      // 1. Go to the "users" folder
        .doc(user.uid)            // 2. Find the folder for THIS specific user
        .collection('transactions'); // 3. Open the "transactions" drawer inside their folder
  }

  @override
  Future<void> addTransaction(TransactionModel transaction) async {
    try {
      print('========== ADD TRANSACTION ==========');
      print('User ID: ${auth.currentUser?.uid}');
      print('Transaction: ${transaction.toMap()}');

      await _transactionCollection
          .doc(transaction.id)
          .set(transaction.toMap());

      print('========== TRANSACTION SAVED ==========');
    } catch (e) {
      print('========== TRANSACTION ERROR ==========');
      print(e);
      rethrow;
    }
  }

  @override
  Future<List<TransactionModel>> getTransactions() async {
    final snapshot = await _transactionCollection
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => TransactionModel.fromMap(doc.data()))
        .toList();
  }

  @override
  Future<void> updateTransaction(TransactionModel transaction) async {
    // FIX: Use _transactionCollection to access user-specific data
    await _transactionCollection
        .doc(transaction.id)
        .update(transaction.toMap());
  }

  @override
  Future<void> deleteTransaction(String id) async {
    // FIX: Use _transactionCollection to access user-specific data
    await _transactionCollection
        .doc(id)
        .delete();
  }
}
