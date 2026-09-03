import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker_app/core/utils/snackbar_utils.dart';
import '../../core/utils/category_icon_utils.dart';
import '../../data/model/category_model.dart';
import '../../data/model/transaction_model.dart';
import '../category/cubit/category_cubit.dart';
import '../category/cubit/category_state.dart';
import 'add_transaction_screen.dart';
import 'cubit/transcation_cubit.dart';

class TransactionDetailScreen extends StatefulWidget {
  final TransactionModel transaction;

  const TransactionDetailScreen({super.key, required this.transaction});

  @override
  State<TransactionDetailScreen> createState() => _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      context.read<CategoryCubit>().loadAllCategories(uid: uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isIncome = widget.transaction.type == TransactionType.income;

    return BlocBuilder<CategoryCubit, CategoryState>(
      builder: (context, state) {
        List<CategoryModel> categories = [];
        if (state is CategoryLoaded) {
          categories = state.categories;
        }

        final category = categories.firstWhere(
          (c) => c.id == widget.transaction.categoryId,
          orElse: () => CategoryModel(
            id: widget.transaction.categoryId ?? 'other',
            name: 'Unknown',
            icon: 'category',
            type: widget.transaction.type.name,
          ),
        );

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF7F7FB),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: Text(
              'Transaction Details',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () => _showDeleteConfirmation(context),
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Hero Amount Card
                Container(
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
                        widget.transaction.title,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${isIncome ? '+ ' : '- '} Ks ${widget.transaction.amount.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: isIncome ? Colors.green : Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Details List
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
                      value: DateFormat('EEEE, MMM dd, yyyy').format(widget.transaction.date),
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

                if (widget.transaction.note != null && widget.transaction.note!.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _buildDetailSection(
                    context,
                    children: [
                      _buildDetailItem(
                        context,
                        icon: Icons.notes_rounded,
                        label: 'Note',
                        value: widget.transaction.note!,
                        maxLines: 3,
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 40),

                // Edit Button
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.deepPurple, Color(0xFF9575CD)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () => _editTransaction(context),
                      icon: const Icon(Icons.edit, color: Colors.white),
                      label: const Text(
                        'Edit Transaction',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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

  void _editTransaction(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddTransactionScreen(transaction: widget.transaction),
      ),
    ).then((_) {
      if (context.mounted) Navigator.pop(context);
    });
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text(
          'Are you sure you want to delete this transaction? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              Navigator.pop(context);

              await context.read<TransactionCubit>().deleteTransaction(
                    widget.transaction.id,
                  );

              if (context.mounted) {
                SnackBarUtils.showSuccess(context, 'Transaction deleted');
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
