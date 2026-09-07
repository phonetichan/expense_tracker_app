import 'package:flutter/material.dart';
import '../../../core/utils/category_icon_utils.dart';
import '../../../data/model/category_model.dart';
import '../../../domain/transaction.dart';

class TransactionDetailAmountCard extends StatelessWidget {
  final TransactionEntity transaction;
  final CategoryModel category;

  const TransactionDetailAmountCard({
    super.key,
    required this.transaction,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isIncome = transaction.type == TransactionType.income;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (isIncome ? Colors.green : Colors.redAccent).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              getCategoryIcon(category.icon),
              color: isIncome ? Colors.green : Colors.redAccent,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            transaction.title,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${isIncome ? '+ ' : '- '} Ks ${transaction.amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: isIncome ? Colors.green : Colors.redAccent,
            ),
          ),
        ],
      ),
    );
  }
}
