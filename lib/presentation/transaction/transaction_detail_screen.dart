import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/category_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../category/cubit/category_cubit.dart';
import '../category/cubit/category_state.dart';
import '../utils/snackbar_utils.dart';
import 'cubit/transaction_cubit.dart';
import 'widgets/transaction_detail_amount_card.dart';
import 'widgets/transaction_detail_info_list.dart';

class TransactionDetailScreen extends StatelessWidget {
  final TransactionEntity transaction;

  const TransactionDetailScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<CategoryCubit, CategoryState>(
      builder: (context, state) {
        List<CategoryEntity> categories = [];
        if (state is CategoryLoaded) {
          categories = state.categories;
        }

        // Find matching category or fallback to 'Unknown'
        final category = categories.firstWhere(
          (c) => c.id == transaction.categoryId,
          orElse: () => CategoryEntity(
            id: transaction.categoryId ?? 'other',
            name: 'Unknown',
            icon: 'category',
            type: transaction.type.name,
          ),
        );

        return Scaffold(
          backgroundColor: isDark
              ? const Color(0xFF121212)
              : const Color(0xFFF7F7FB),
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
                TransactionDetailAmountCard(
                  transaction: transaction,
                  category: category,
                ),
                const SizedBox(height: 30),

                // Details List
                TransactionDetailInfoList(
                  transaction: transaction,
                  category: category,
                ),

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
                        'Update Transaction',
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

  void _editTransaction(BuildContext context) async {
    final result = await context.push<bool>(
      '/add-transaction',
      extra: transaction,
    );

    if (context.mounted && result == true) {
      context.pop(true);
    }
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
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              context.pop(); // Close dialog

              await context.read<TransactionCubit>().deleteTransaction(
                transaction.id,
              );

              if (!context.mounted) return;

              SnackBarUtils.showSuccess(
                context,
                'Transaction deleted successfully',
              );
              context.pop(true);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
