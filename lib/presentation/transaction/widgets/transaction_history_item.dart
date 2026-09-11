import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../../utils/category_icon_utils.dart';
import '../../utils/currency_utils.dart';
import '../transaction_detail_screen.dart';

class TransactionHistoryItem extends StatelessWidget {
  final TransactionEntity transaction;
  final CategoryEntity category;

  const TransactionHistoryItem({
    super.key,
    required this.transaction,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isIncome = transaction.type == TransactionType.income;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TransactionDetailScreen(transaction: transaction),
            ),
          );
        },
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (isIncome ? Colors.green : Colors.redAccent).withOpacity(
              0.1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            getCategoryIcon(category.icon),
            color: isIncome ? Colors.green : Colors.redAccent,
            size: 24,
          ),
        ),
        title: Text(
          transaction.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        subtitle: Text(
          '${category.name} • ${DateFormat('MMM dd, yyyy').format(transaction.date)}',
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        trailing: Text(
          CurrencyUtils.formatAmount(transaction.amount, showPrefix: true, isIncome: isIncome),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: isIncome ? Colors.green : Colors.redAccent,
          ),
        ),
      ),
    );
  }
}
