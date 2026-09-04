import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../data/model/category_model.dart';
import '../../../data/model/transaction_model.dart';

class ExpensesByCategoryChart extends StatelessWidget {
  final List<TransactionModel> transactions;
  final List<CategoryModel> categories;

  const ExpensesByCategoryChart({
    super.key,
    required this.transactions,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final expenses = transactions
        .where((tx) => tx.type == TransactionType.expense)
        .toList();

    if (expenses.isEmpty) return const SizedBox.shrink();

    final Map<String, double> categoryMap = {};
    double totalExpense = 0;

    for (var tx in expenses) {
      final categoryId = tx.categoryId ?? 'other';
      categoryMap[categoryId] = (categoryMap[categoryId] ?? 0) + tx.amount;
      totalExpense += tx.amount;
    }

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
