import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import '../../domain/transaction.dart';
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
    return firestore
        .collection('users')
        .doc(user.uid)
        .collection('transactions');
  }

  @override
  Future<void> addTransaction(TransactionEntity transaction) async {
    try {
      final model = TransactionModel.fromEntity(transaction);
      await _transactionCollection
          .doc(model.id)
          .set(model.toMap());
    } catch (e) {
      print('Error adding transaction: $e');
      rethrow;
    }
  }

  @override
  Future<List<TransactionEntity>> getTransactions() async {
    final snapshot = await _transactionCollection
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => TransactionModel.fromMap(doc.data()))
        .toList();
  }

  @override
  Future<void> updateTransaction(TransactionEntity transaction) async {
    final model = TransactionModel.fromEntity(transaction);
    await _transactionCollection
        .doc(model.id)
        .update(model.toMap());
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await _transactionCollection
        .doc(id)
        .delete();
  }
}
