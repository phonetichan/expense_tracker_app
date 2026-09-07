enum TransactionType {
  income,
  expense,
}

class TransactionEntity {
  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final String? categoryId;
  final DateTime date;
  final String? note;

  TransactionEntity({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    this.categoryId,
    required this.date,
    this.note,
  });
}

abstract class TransactionRepository {
  Future<void> addTransaction(TransactionEntity transaction);

  Future<List<TransactionEntity>> getTransactions();

  Future<void> updateTransaction(TransactionEntity transaction);

  Future<void> deleteTransaction(String transactionId);
}
