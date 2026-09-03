import 'package:expense_tracker_app/presentation/transcation/cubit/transcation_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../data/model/transaction_model.dart';
import '../../../domain/transaction_repository.dart';

@injectable
class TransactionCubit extends Cubit<TransactionState> {
  final TransactionRepository repository;

  List<TransactionModel> currentTransactions = [];

  TransactionCubit(this.repository) : super(TransactionInitial());

  Future<void> addTransaction(TransactionModel transaction) async {
    emit(TransactionLoading(currentTransactions));

    try {
      await repository.addTransaction(transaction);
      await loadTransactions();
    } catch (e) {
      emit(
        TransactionError(
          'Failed to add transaction.',
        ),
      );
    }
  }

  Future<void> loadTransactions() async {
    emit(TransactionLoading(currentTransactions));

    try {
      final transactions = await repository.getTransactions();

      currentTransactions = transactions;

      emit(
        TransactionLoaded(currentTransactions),
      );
    } catch (e) {
      emit(
        TransactionError(
          'Failed to load transactions.',
        ),
      );
    }
  }

  Future<void> updateTransaction(
    TransactionModel transaction,
  ) async {
    emit(TransactionLoading(currentTransactions));

    try {
      await repository.updateTransaction(transaction);
      await loadTransactions();
    } catch (e) {
      emit(
        TransactionError(
          'Failed to update transaction.',
        ),
      );
    }
  }

  Future<void> deleteTransaction(String id) async {
    emit(TransactionLoading(currentTransactions));

    try {
      await repository.deleteTransaction(id);
      await loadTransactions();
    } catch (e) {
      emit(
        TransactionError(
          'Failed to delete transaction.',
        ),
      );
    }
  }
}
