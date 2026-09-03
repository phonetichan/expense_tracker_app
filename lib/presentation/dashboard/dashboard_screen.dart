import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../core/utils/category_icon_utils.dart';
import '../../data/model/category_model.dart';
import '../../data/model/transaction_model.dart';
import '../category/cubit/category_cubit.dart';
import '../category/cubit/category_state.dart';
import '../profile/profile_screen.dart';
import '../transcation/add_transaction_screen.dart';
import '../transcation/cubit/transcation_cubit.dart';
import '../transcation/cubit/transcation_state.dart';
import '../transcation/transaction_detail_screen.dart';
import '../transcation/transcation_history_screen.dart';

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

  List<TransactionModel> _getMonthlyTransactions(
    List<TransactionModel> transactions,
  ) {
    return transactions.where((transaction) {
      return transaction.date.year == _selectedMonth.year &&
          transaction.date.month == _selectedMonth.month;
    }).toList();
  }

  Future<void> _showMonthPicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _selectedMonth = DateTime(picked.year, picked.month);
      });
    }
  }

  String _formatAmount(double amount) {
    String formatted;
    if (amount >= 1000000) {
      final value = amount / 1000000;
      formatted =
          '${value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1)}M';
    } else if (amount >= 1000) {
      final value = amount / 1000;
      formatted =
          '${value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1)}K';
    } else {
      formatted = amount.toStringAsFixed(0);
    }
    return 'Ks $formatted';
  }

  CategoryModel? _findCategory(
    List<CategoryModel> categories,
    String? categoryId,
  ) {
    if (categoryId == null) return null;
    try {
      return categories.firstWhere((category) => category.id == categoryId);
    } catch (_) {
      return null;
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
                List<TransactionModel> transactions = [];
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

                List<CategoryModel> categories = [];
                bool isCategoryLoading = false;

                if (categoryState is CategoryLoading) {
                  isCategoryLoading = true;
                } else if (categoryState is CategoryLoaded) {
                  categories = categoryState.categories;
                }

                final monthlyTransactions = _getMonthlyTransactions(
                  transactions,
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
                            _buildMonthFilter(isDark),
                            const SizedBox(height: 20),
                            _buildBalanceCard(
                              totalBalance,
                              totalIncome,
                              totalExpense,
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
                                  final category = _findCategory(
                                    categories,
                                    transaction.categoryId,
                                  );
                                  return _buildTransactionItem(
                                    context,
                                    transaction,
                                    category,
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

  Widget _buildBalanceCard(double total, double income, double expense) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.deepPurple, Color(0xFF9575CD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Total Balance',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            _formatAmount(total),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBalanceInfo(
                Icons.arrow_upward,
                'Income',
                income,
                Colors.greenAccent,
              ),
              Container(width: 1, height: 40, color: Colors.white24),
              _buildBalanceInfo(
                Icons.arrow_downward,
                'Expenses',
                expense,
                Colors.redAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceInfo(
    IconData icon,
    String label,
    double amount,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            Text(
              _formatAmount(amount),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTransactionItem(
    BuildContext context,
    TransactionModel transaction,
    CategoryModel? category,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isIncome = transaction.type == TransactionType.income;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TransactionDetailScreen(transaction: transaction),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
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
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (isIncome ? Colors.green : Colors.redAccent)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  getCategoryIcon(category?.icon ?? 'category'),
                  color: isIncome ? Colors.green : Colors.redAccent,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            category?.name ?? 'Unknown',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          '•',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          DateFormat('MMM dd, yyyy').format(transaction.date),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${isIncome ? '+ ' : '- '}${_formatAmount(transaction.amount)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isIncome ? Colors.green : Colors.redAccent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthFilter(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                _selectedMonth = DateTime(
                  _selectedMonth.year,
                  _selectedMonth.month - 1,
                );
              });
            },
            icon: const Icon(Icons.chevron_left, color: Colors.deepPurple),
          ),
          Expanded(
            child: GestureDetector(
              onTap: _showMonthPicker,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.calendar_month_rounded,
                    color: Colors.deepPurple,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('MMMM yyyy').format(_selectedMonth),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.deepPurple,
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _selectedMonth = DateTime(
                  _selectedMonth.year,
                  _selectedMonth.month + 1,
                );
              });
            },
            icon: const Icon(Icons.chevron_right, color: Colors.deepPurple),
          ),
        ],
      ),
    );
  }
}
