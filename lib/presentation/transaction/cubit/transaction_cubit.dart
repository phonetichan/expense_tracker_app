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

  void clear() {
    currentTransactions = [];
    emit(TransactionInitial());
  }

  Future<void> addTransaction(TransactionEntity transaction) async {
    try {
      // 1. Save to Database first
      await repository.addTransaction(transaction);
      
      // 2. Only if DB success, update local memory and emit loaded
      currentTransactions = [transaction, ...currentTransactions];
      emit(TransactionLoaded(List.from(currentTransactions)));
    } catch (e) {
      emit(TransactionError('Database Error: ${e.toString()}'));
      rethrow;
    }
  }

  Future<void> loadTransactions() async {
    emit(TransactionLoading(currentTransactions));
    try {
      final transactions = await repository.getTransactions();
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
      
      final index = currentTransactions.indexWhere((t) => t.id == transaction.id);
      if (index != -1) {
        currentTransactions[index] = transaction;
      }
      emit(TransactionLoaded(List.from(currentTransactions)));
    } catch (e) {
      emit(TransactionError('Database Error: ${e.toString()}'));
      rethrow;
    }
  }

  Future<void> deleteTransaction(String id) async {
    emit(TransactionLoading(currentTransactions));

    try {
      await repository.deleteTransaction(id);
      await loadTransactions();
    } catch (e) {
      emit(TransactionError('Failed to delete transaction.'));
    }
  }
}
