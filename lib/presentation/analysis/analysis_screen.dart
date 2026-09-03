import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../data/model/category_model.dart';
import '../../data/model/transaction_model.dart';
import '../category/cubit/category_cubit.dart';
import '../category/cubit/category_state.dart';
import '../transcation/cubit/transcation_cubit.dart';
import '../transcation/cubit/transcation_state.dart';

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

  String _formatChartAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    }
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    }
    return amount.toStringAsFixed(0);
  }

  Widget _buildChartLegend(String label, Color color, bool isDark) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
      ],
    );
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
        title: Text(
          'Analysis',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<CategoryCubit, CategoryState>(
        builder: (context, categoryState) {
          return BlocBuilder<TransactionCubit, TransactionState>(
            builder: (context, transactionState) {
              List<TransactionModel> transactions = [];
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

              List<CategoryModel> categories = [];
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
                          _buildIncomeVsExpenseChart(
                            context,
                            transactions,
                            isDark,
                          ),
                          const SizedBox(height: 24),
                          _buildExpensesByCategoryChart(
                            context,
                            transactions,
                            categories,
                            isDark,
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

  Widget _buildIncomeVsExpenseChart(
    BuildContext context,
    List<TransactionModel> transactions,
    bool isDark,
  ) {
    final Map<String, double> monthlyIncome = {};
    final Map<String, double> monthlyExpense = {};

    for (final tx in transactions) {
      final monthKey = DateFormat('yyyy-MM').format(tx.date);
      if (tx.type == TransactionType.income) {
        monthlyIncome[monthKey] = (monthlyIncome[monthKey] ?? 0) + tx.amount;
      } else {
        monthlyExpense[monthKey] = (monthlyExpense[monthKey] ?? 0) + tx.amount;
      }
    }

    final Set<String> monthKeys = {
      ...monthlyIncome.keys,
      ...monthlyExpense.keys,
    };
    final sortedMonths = monthKeys.toList()..sort();
    final displayMonths = sortedMonths.length > 4
        ? sortedMonths.sublist(sortedMonths.length - 4)
        : sortedMonths;

    if (displayMonths.isEmpty) return const SizedBox.shrink();

    double maxValue = 0;
    for (final month in displayMonths) {
      final income = monthlyIncome[month] ?? 0;
      final expense = monthlyExpense[month] ?? 0;
      maxValue = [maxValue, income, expense].reduce((a, b) => a > b ? a : b);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monthly Income vs Expense',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Your financial activity over the last 4 months',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 260,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxValue == 0 ? 100 : maxValue * 1.2,
                minY: 0,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => Colors.deepPurple,
                    tooltipPadding: const EdgeInsets.all(8),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final month = displayMonths[groupIndex];
                      final label = rodIndex == 0 ? 'Income' : 'Expense';
                      return BarTooltipItem(
                        '$month\n$label\nKs ${rod.toY.toStringAsFixed(0)}',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 35,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= displayMonths.length)
                          return const SizedBox.shrink();
                        final month = DateTime.parse(
                          '${displayMonths[index]}-01',
                        );
                        final label = DateFormat('MMM').format(month);
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            label,
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black54,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox.shrink();
                        return Text(
                          _formatChartAmount(value),
                          style: TextStyle(
                            color: isDark ? Colors.white54 : Colors.black45,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxValue == 0 ? 100 : maxValue / 4,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: isDark ? Colors.white10 : Colors.black12,
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(displayMonths.length, (index) {
                  final month = displayMonths[index];
                  final income = monthlyIncome[month] ?? 0;
                  final expense = monthlyExpense[month] ?? 0;
                  return BarChartGroupData(
                    x: index,
                    barsSpace: 4,
                    barRods: [
                      BarChartRodData(
                        toY: income,
                        color: Colors.green,
                        width: 14,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                      ),
                      BarChartRodData(
                        toY: expense,
                        color: Colors.redAccent,
                        width: 14,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildChartLegend('Income', Colors.green, isDark),
              const SizedBox(width: 30),
              _buildChartLegend('Expense', Colors.redAccent, isDark),
            ],
          ),
          const SizedBox(height: 20),
          if (displayMonths.isNotEmpty)
            _buildLatestMonthSummary(
              displayMonths.last,
              monthlyIncome,
              monthlyExpense,
              isDark,
            ),
        ],
      ),
    );
  }

  Widget _buildLatestMonthSummary(
    String month,
    Map<String, double> monthlyIncome,
    Map<String, double> monthlyExpense,
    bool isDark,
  ) {
    final income = monthlyIncome[month] ?? 0;
    final expense = monthlyExpense[month] ?? 0;
    final balance = income - expense;
    final date = DateTime.parse('$month-01');
    final monthName = DateFormat('MMMM yyyy').format(date);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.deepPurple.withOpacity(0.15)
            : Colors.deepPurple.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            monthName,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMonthlySummaryItem(
                  'Income',
                  income,
                  Colors.green,
                  isDark,
                ),
              ),
              Expanded(
                child: _buildMonthlySummaryItem(
                  'Expense',
                  expense,
                  Colors.redAccent,
                  isDark,
                ),
              ),
              Expanded(
                child: _buildMonthlySummaryItem(
                  'Balance',
                  balance,
                  balance >= 0 ? Colors.deepPurple : Colors.redAccent,
                  isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlySummaryItem(
    String label,
    double amount,
    Color color,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          'Ks ${amount.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildExpensesByCategoryChart(
    BuildContext context,
    List<TransactionModel> transactions,
    List<CategoryModel> categories,
    bool isDark,
  ) {
    final expenses = transactions
        .where((tx) => tx.type == TransactionType.expense)
        .toList();
    final Map<String, double> categoryMap = {};
    double totalExpense = 0;

    for (var tx in expenses) {
      final categoryId = tx.categoryId ?? 'other';
      categoryMap[categoryId] = (categoryMap[categoryId] ?? 0) + tx.amount;
      totalExpense += tx.amount;
    }

    if (expenses.isEmpty) return const SizedBox.shrink();

    final List<Color> colors = [
      Colors.deepPurple,
      Colors.blue,
      Colors.orange,
      Colors.pink,
      Colors.teal,
      Colors.amber,
      Colors.indigo,
    ];

    int colorIndex = 0;
    final List<PieChartSectionData> sections = categoryMap.entries.map((entry) {
      final color = colors[colorIndex % colors.length];
      colorIndex++;
      final percentage = (entry.value / totalExpense) * 100;
      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '${percentage.toStringAsFixed(0)}%',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Expenses by Category',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 180,
                  child: PieChart(
                    PieChartData(
                      sections: sections,
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: categoryMap.entries.map((entry) {
                    final index = categoryMap.keys.toList().indexOf(entry.key);
                    final color = colors[index % colors.length];
                    final category = categories.firstWhere(
                      (c) => c.id == entry.key,
                      orElse: () => CategoryModel(
                        id: entry.key,
                        name: 'Unknown',
                        icon: 'category',
                        type: 'expense',
                      ),
                    );
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              category.name,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
