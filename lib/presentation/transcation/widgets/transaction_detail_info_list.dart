import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/model/category_model.dart';
import '../../../domain/transaction.dart';

class TransactionDetailInfoList extends StatelessWidget {
  final TransactionEntity transaction;
  final CategoryModel category;

  const TransactionDetailInfoList({
    super.key,
    required this.transaction,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;

    return Column(
      children: [
        _buildDetailSection(
          context,
          children: [
            _buildDetailItem(
              context,
              icon: Icons.category_outlined,
              label: 'Category',
              value: category.name,
            ),
            _buildDetailItem(
              context,
              icon: Icons.calendar_today_outlined,
              label: 'Date',
              value: DateFormat('EEEE, MMM dd, yyyy').format(transaction.date),
            ),
            _buildDetailItem(
              context,
              icon: Icons.swap_horiz_rounded,
              label: 'Type',
              value: isIncome ? 'Income' : 'Expense',
              valueColor: isIncome ? Colors.green : Colors.redAccent,
            ),
          ],
        ),
        if (transaction.note != null && transaction.note!.isNotEmpty) ...[
          const SizedBox(height: 20),
          _buildDetailSection(
            context,
            children: [
              _buildDetailItem(
                context,
                icon: Icons.notes_rounded,
                label: 'Note',
                value: transaction.note!,
                maxLines: 3,
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildDetailSection(
    BuildContext context, {
    required List<Widget> children,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDetailItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    int maxLines = 1,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepPurple, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? (isDark ? Colors.white : Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
