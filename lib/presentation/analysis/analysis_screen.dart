import 'package:expense_tracker_app/domain/entities/category_entity.dart';
import 'package:expense_tracker_app/domain/entities/transaction_entity.dart';
import 'package:expense_tracker_app/presentation/analysis/widgets/expenses_by_category_chart.dart';
import 'package:expense_tracker_app/presentation/analysis/widgets/income_vs_expense_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../category/cubit/category_cubit.dart';
import '../category/cubit/category_state.dart';
import '../transaction/cubit/transaction_cubit.dart';
import '../transaction/cubit/transaction_state.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      context.read<TransactionCubit>().loadTransactions();
      context.read<CategoryCubit>().loadAllCategories(uid: uid);
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF121212)
          : const Color(0xFFF7F7FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Analysis',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<CategoryCubit, CategoryState>(
        builder: (context, categoryState) {
          return BlocBuilder<TransactionCubit, TransactionState>(
            builder: (context, transactionState) {
              List<TransactionEntity> transactions = [];
              bool isLoading = false;

              if (transactionState is TransactionLoading) {
                transactions = transactionState.transactions;
                isLoading = true;
              } else if (transactionState is TransactionLoaded) {
                transactions = transactionState.transactions;
              } else if (transactionState is TransactionError) {
                return Center(child: Text(transactionState.message));
              } else {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.deepPurple),
                );
              }

              List<CategoryEntity> categories = [];
              if (categoryState is CategoryLoaded) {
                categories = categoryState.categories;
              }

              if (transactions.isEmpty) {
                if (isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.deepPurple),
                  );
                }
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.analytics_outlined,
                        size: 80,
                        color: Colors.grey.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No transactions to analyze',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return Stack(
                children: [
                  RefreshIndicator(
                    onRefresh: () async {
                      final uid = FirebaseAuth.instance.currentUser?.uid;
                      if (uid != null) {
                        await Future.wait([
                          context.read<TransactionCubit>().loadTransactions(),
                          context.read<CategoryCubit>().loadAllCategories(
                            uid: uid,
                          ),
                        ]);
                      }
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IncomeVsExpenseChart(transactions: transactions),
                          const SizedBox(height: 24),
                          ExpensesByCategoryChart(
                            transactions: transactions,
                            categories: categories,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (isLoading)
                    const Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: LinearProgressIndicator(
                        color: Colors.deepPurple,
                        backgroundColor: Colors.transparent,
                        minHeight: 2,
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
