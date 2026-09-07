import '../../../domain/transaction.dart';

abstract class TransactionState {}

class TransactionInitial extends TransactionState {}

class TransactionLoading extends TransactionState {
  final List<TransactionEntity> transactions;

  TransactionLoading(this.transactions);
}

class TransactionLoaded extends TransactionState {
  final List<TransactionEntity> transactions;

  TransactionLoaded(this.transactions);
}

class TransactionError extends TransactionState {
  final String message;

  TransactionError(this.message);
}
