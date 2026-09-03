import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DashboardMonthFilter extends StatelessWidget {
  final DateTime selectedMonth;
  final VoidCallback onMonthPickerTap;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  const DashboardMonthFilter({
    super.key,
    required this.selectedMonth,
    required this.onMonthPickerTap,
    required this.onPreviousMonth,
    required this.onNextMonth,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
            onPressed: onPreviousMonth,
            icon: const Icon(Icons.chevron_left, color: Colors.deepPurple),
          ),
          Expanded(
            child: GestureDetector(
              onTap: onMonthPickerTap,
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
                    DateFormat('MMMM yyyy').format(selectedMonth),
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
            onPressed: onNextMonth,
            icon: const Icon(Icons.chevron_right, color: Colors.deepPurple),
          ),
        ],
      ),
    );
  }
}
