import 'package:expense_tracker_app/presentation/transcation/widgets/transaction_detail_amount_card.dart';
import 'package:expense_tracker_app/presentation/transcation/widgets/transaction_detail_info_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker_app/core/utils/snackbar_utils.dart';
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
                TransactionDetailAmountCard(
                  transaction: widget.transaction,
                  category: category,
                ),
                const SizedBox(height: 30),

                // Details List
                TransactionDetailInfoList(
                  transaction: widget.transaction,
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
