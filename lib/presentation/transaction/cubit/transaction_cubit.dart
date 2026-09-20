import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/entities/transaction_entity.dart';
import '../../../domain/repositories/transaction_repository.dart';
import 'transaction_state.dart';

@injectable
class TransactionCubit extends Cubit<TransactionState> {
  final TransactionRepository repository;

  List<TransactionEntity> currentTransactions = [];

  TransactionCubit(this.repository) : super(TransactionInitial());

  Future<void> addTransaction(TransactionEntity transaction) async {
    try {
      await repository.addTransaction(transaction);

      currentTransactions = [transaction, ...currentTransactions];

      emit(TransactionLoaded(List.from(currentTransactions)));
    } catch (e) {
      emit(TransactionError('Database Error: ${e.toString()}'));
      rethrow;
    }
  }

  Future<void> loadTransactions() async {

    try {
      final transactions = await repository.getTransactions();
      if (isClosed) return;
      currentTransactions = transactions;

      emit(TransactionLoaded(List.from(currentTransactions)));
    } catch (e) {
      emit(TransactionError('Failed to load transactions.'));
      rethrow;
    }
  }

  Future<void> updateTransaction(TransactionEntity transaction) async {
    try {
      await repository.updateTransaction(transaction);

      final index = currentTransactions.indexWhere(
        (t) => t.id == transaction.id,
      );

      if (index != -1) {
        currentTransactions[index] = transaction;
      }

      emit(TransactionLoaded(List.from(currentTransactions)));
    } catch (e) {
      emit(TransactionError('Database Error: ${e.toString()}'));
      rethrow;
    }
  }

  Future<bool> deleteTransaction(String id) async {
    try {
      await repository.deleteTransaction(id);

      // Keep internal list synchronized
      currentTransactions.removeWhere((transaction) => transaction.id == id);

      emit(TransactionLoaded(List.from(currentTransactions)));
      return true;
    } catch (e) {
      emit(TransactionError('Failed to delete transaction.'));
      return false;
    }
  }
}
