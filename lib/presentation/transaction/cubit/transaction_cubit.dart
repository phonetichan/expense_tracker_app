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
    emit(TransactionLoading(currentTransactions));

    try {
      await repository.addTransaction(transaction);
      await loadTransactions();
    } catch (e) {
      emit(TransactionError('Failed to add transaction.'));
    }
  }

  Future<void> loadTransactions() async {
    emit(TransactionLoading(currentTransactions));

    try {
      final transactions = await repository.getTransactions();
      currentTransactions = transactions;
      emit(TransactionLoaded(currentTransactions));
    } catch (e) {
      emit(TransactionError('Failed to load transactions.'));
    }
  }

  Future<void> updateTransaction(TransactionEntity transaction) async {
    emit(TransactionLoading(currentTransactions));

    try {
      await repository.updateTransaction(transaction);
      await loadTransactions();
    } catch (e) {
      emit(TransactionError('Failed to update transaction.'));
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
