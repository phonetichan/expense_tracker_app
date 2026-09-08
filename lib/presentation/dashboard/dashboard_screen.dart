import 'package:expense_tracker_app/core/utils/category_utils.dart';
import 'package:expense_tracker_app/core/utils/currency_utils.dart';
import 'package:expense_tracker_app/core/utils/transaction_utils.dart';
import 'package:expense_tracker_app/domain/entities/category_entity.dart';
import 'package:expense_tracker_app/domain/entities/transaction_entity.dart';
import 'package:expense_tracker_app/presentation/dashboard/widgets/dashboard_balance_card.dart';
import 'package:expense_tracker_app/presentation/dashboard/widgets/dashboard_month_filter.dart';
import 'package:expense_tracker_app/presentation/dashboard/widgets/dashboard_transaction_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../category/cubit/category_cubit.dart';
import '../category/cubit/category_state.dart';
import '../profile/profile_screen.dart';
import '../transaction/add_transaction_screen.dart';
import '../transaction/cubit/transaction_cubit.dart';
import '../transaction/cubit/transaction_state.dart';
import '../transaction/transaction_history_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();

    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid != null) {
      context.read<TransactionCubit>().loadTransactions();
      context.read<CategoryCubit>().loadAllCategories(uid: uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF7F7FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Expense Tracker',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
            icon: Icon(
              Icons.person_outline,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<CategoryCubit, CategoryState>(
            listener: (context, state) {
              if (state is CategoryError) {
                debugPrint('Category error: ${state.message}');
              }
            },
          ),
        ],
        child: BlocBuilder<CategoryCubit, CategoryState>(
          builder: (context, categoryState) {
            return BlocBuilder<TransactionCubit, TransactionState>(
              builder: (context, transactionState) {
                List<TransactionEntity> transactions = [];
                bool isTransactionLoading = false;

                if (transactionState is TransactionLoading) {
                  transactions = transactionState.transactions;
                  isTransactionLoading = true;
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
                bool isCategoryLoading = false;

                if (categoryState is CategoryLoading) {
                  isCategoryLoading = true;
                } else if (categoryState is CategoryLoaded) {
                  categories = categoryState.categories;
                }

                final monthlyTransactions = TransactionUtils.filterByMonth(
                  transactions,
                  _selectedMonth,
                );

                double totalIncome = 0;
                double totalExpense = 0;

                for (final transaction in monthlyTransactions) {
                  if (transaction.type == TransactionType.income) {
                    totalIncome += transaction.amount;
                  } else {
                    totalExpense += transaction.amount;
                  }
                }

                final totalBalance = totalIncome - totalExpense;

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
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DashboardMonthFilter(
                              selectedMonth: _selectedMonth,
                              onMonthPickerTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: _selectedMonth,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2100),
                                );

                                if (picked != null) {
                                  setState(() {
                                    _selectedMonth =
                                        DateTime(picked.year, picked.month);
                                  });
                                }
                              },
                              onPreviousMonth: () {
                                setState(() {
                                  _selectedMonth = DateTime(
                                    _selectedMonth.year,
                                    _selectedMonth.month - 1,
                                  );
                                });
                              },
                              onNextMonth: () {
                                setState(() {
                                  _selectedMonth = DateTime(
                                    _selectedMonth.year,
                                    _selectedMonth.month + 1,
                                  );
                                });
                              },
                            ),
                            const SizedBox(height: 20),
                            DashboardBalanceCard(
                              totalBalance: totalBalance,
                              totalIncome: totalIncome,
                              totalExpense: totalExpense,
                              formatAmount: CurrencyUtils.formatAmount,
                            ),
                            const SizedBox(height: 30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Recent Transactions',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => TransactionHistoryScreen(
                                          selectedMonth: _selectedMonth,
                                        ),
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.deepPurple.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'See All',
                                          style: TextStyle(
                                            color: Colors.deepPurple,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          size: 12,
                                          color: Colors.deepPurple,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            if (isCategoryLoading && transactions.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.deepPurple,
                                  ),
                                ),
                              )
                            else if (monthlyTransactions.isEmpty &&
                                !isTransactionLoading)
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.only(top: 50),
                                  child: Text(
                                    'No transactions yet',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              )
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: monthlyTransactions.length > 5
                                    ? 5
                                    : monthlyTransactions.length,
                                itemBuilder: (context, index) {
                                  final transaction =
                                      monthlyTransactions[index];
                                  final category = CategoryUtils.findCategoryById(
                                    categories,
                                    transaction.categoryId,
                                  );
                                  return DashboardTransactionItem(
                                    transaction: transaction,
                                    category: category,
                                    formatAmount: CurrencyUtils.formatAmount,
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (isTransactionLoading)
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
          );
        },
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
