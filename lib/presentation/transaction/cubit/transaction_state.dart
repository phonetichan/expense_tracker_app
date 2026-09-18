import '../../../domain/entities/transaction_entity.dart';

abstract class TransactionState {
  const TransactionState();
}

class TransactionInitial extends TransactionState {
  const TransactionInitial();
}

class TransactionLoading extends TransactionState {
  final List<TransactionEntity> transactions;

  const TransactionLoading(this.transactions);
}

class TransactionLoaded extends TransactionState {
  final List<TransactionEntity> transactions;

  const TransactionLoaded(this.transactions);
}

class TransactionError extends TransactionState {
  final String message;

  const TransactionError(this.message);
}
