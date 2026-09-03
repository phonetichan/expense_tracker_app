import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../core/utils/category_icon_utils.dart';
import '../../data/model/category_model.dart';
import '../../data/model/transaction_model.dart';
import '../category/cubit/category_cubit.dart';
import '../category/cubit/category_state.dart';
import 'cubit/transcation_cubit.dart';
import 'cubit/transcation_state.dart';
import 'transaction_detail_screen.dart';

class TransactionHistoryScreen extends StatefulWidget {
  final DateTime? selectedMonth;

  const TransactionHistoryScreen({super.key, this.selectedMonth});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';
  String _selectedFilter = 'All';
  final Set<DateTime> _selectedMonths = {};
  late List<DateTime> _months;
  late int _selectedYear;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedYear = widget.selectedMonth?.year ?? now.year;
    
    // Initially select the month passed from dashboard, or current month
    final initialMonth = widget.selectedMonth ??
        DateTime(_selectedYear, now.month);
    _selectedMonths.add(initialMonth);

    _generateMonths();

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      context.read<TransactionCubit>().loadTransactions();
      context.read<CategoryCubit>().loadAllCategories(uid: uid);
    }

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected(initialMonth));
  }

  void _generateMonths() {
    _months = [];
    for (int i = 1; i <= 12; i++) {
      _months.add(DateTime(_selectedYear, i));
    }
  }

  void _toggleMonth(DateTime month) {
    setState(() {
      DateTime? toRemove;
      for (var m in _selectedMonths) {
        if (m.year == month.year && m.month == month.month) {
          toRemove = m;
          break;
        }
      }

      if (toRemove != null) {
        _selectedMonths.remove(toRemove);
      } else {
        _selectedMonths.add(month);
      }
    });
  }

  Future<void> _showYearPicker() async {
    final now = DateTime.now();
    final picked = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Select Year"),
        content: SizedBox(
          width: 300,
          height: 300,
          child: YearPicker(
            firstDate: DateTime(now.year - 5),
            lastDate: DateTime(now.year + 5),
            selectedDate: DateTime(_selectedYear),
            onChanged: (DateTime dateTime) {
              Navigator.pop(context, dateTime.year);
            },
          ),
        ),
      ),
    );

    if (picked != null && picked != _selectedYear) {
      setState(() {
        _selectedYear = picked;
        _selectedMonths.clear(); // Clear all selected months to show all transactions for the new year
        _generateMonths();
      });
    }
  }

  /// Automatically scrolls the horizontal month slider to center the [month] provided.
  void _scrollToSelected(DateTime month) {
    // 1. Find the index of the month in our data list
    final index = _months.indexWhere((m) =>
        m.year == month.year && m.month == month.month);
    if (index != -1) {
      _scrollController.animateTo(
        index * 100.0 - (MediaQuery.of(context).size.width / 2) + 50,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<TransactionModel> _filterTransactions(
    List<TransactionModel> transactions,
  ) {
    return transactions.where((transaction) {
      // 1. Year Filter (Always filter by selected year)
      if (transaction.date.year != _selectedYear) return false;

      // 2. Month Filter (If selection is empty, show all months of the year)
      final matchesMonth = _selectedMonths.isEmpty ||
          _selectedMonths.any((m) =>
              transaction.date.year == m.year &&
              transaction.date.month == m.month);

      // 3. Search filter
      final matchesSearch = transaction.title.toLowerCase().contains(
            _searchQuery,
          );

      // 4. Income / Expense filter
      final matchesType = _selectedFilter == 'All' ||
          (_selectedFilter == 'Income' &&
              transaction.type == TransactionType.income) ||
          (_selectedFilter == 'Expense' &&
              transaction.type == TransactionType.expense);

      return matchesMonth && matchesSearch && matchesType;
    }).toList();
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
          'Transaction History',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: BlocBuilder<CategoryCubit, CategoryState>(
        builder: (context, categoryState) {
          List<CategoryModel> categories = [];
          if (categoryState is CategoryLoaded) {
            categories = categoryState.categories;
          }

          return Column(
            children: [
              _buildMonthSlider(),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search transactions...',
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Colors.deepPurple,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            onPressed: () => _searchController.clear(),
                            icon: const Icon(Icons.clear),
                          )
                        : null,
                    filled: true,
                    fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildFilterChip('All'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Income'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Expense'),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: BlocBuilder<TransactionCubit, TransactionState>(
                  builder: (context, state) {
                    if (state is TransactionLoading && categories.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Colors.deepPurple,
                        ),
                      );
                    }
                    if (state is TransactionError) {
                      return Center(child: Text(state.message));
                    }
                    if (state is TransactionLoaded ||
                        state is TransactionLoading) {
                      final transactions = _filterTransactions(
                        state is TransactionLoaded
                            ? state.transactions
                            : (state as TransactionLoading).transactions,
                      );
                      if (transactions.isEmpty) {
                        return const Center(
                          child: Text(
                            'No transactions found',
                            style: TextStyle(color: Colors.grey),
                          ),
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: transactions.length,
                        itemBuilder: (context, index) {
                          final transaction = transactions[index];
                          final category = categories.firstWhere(
                            (c) => c.id == transaction.categoryId,
                            orElse: () => CategoryModel(
                              id: transaction.categoryId ?? 'other',
                              name: 'Unknown',
                              icon: 'category',
                              type: transaction.type.name,
                            ),
                          );
                          return _buildTransactionItem(
                            context,
                            transaction,
                            category,
                          );
                        },
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMonthSlider() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: Row(
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                size: 16,
                color: Colors.deepPurple,
              ),
              const SizedBox(width: 8),
              Text(
                "Year: $_selectedYear",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const Spacer(),
              TextButton(
                onPressed: _showYearPicker,
                child: const Text("Change Year", style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 45,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 12,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              final month = DateTime(_selectedYear, index + 1);
              final isSelected = _selectedMonths.any((m) => m.month == month.month && m.year == month.year);

              return GestureDetector(
                onTap: () => _toggleMonth(month),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.deepPurple : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? Colors.deepPurple
                          : Colors.grey.withOpacity(0.3),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    DateFormat('MMM').format(month),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String filter) {
    final isSelected = _selectedFilter == filter;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedFilter = filter),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.deepPurple
                : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              if (!isSelected)
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Text(
            filter,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionItem(
    BuildContext context,
    TransactionModel transaction,
    CategoryModel category,
  ) {
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
          '${isIncome ? '+ ' : '- '} Ks ${transaction.amount.toStringAsFixed(0)}',
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
