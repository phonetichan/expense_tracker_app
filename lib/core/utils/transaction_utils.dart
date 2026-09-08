import '../../domain/entities/transaction_entity.dart';

class TransactionUtils {
  /// Filters the transaction list to only include transactions from the specific year and month.
  static List<TransactionEntity> filterByMonth(
    List<TransactionEntity> transactions,
    DateTime month,
  ) {
    return transactions.where((transaction) {
      return transaction.date.year == month.year &&
          transaction.date.month == month.month;
    }).toList();
  }
}
