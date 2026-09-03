import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthSlider extends StatelessWidget {
  final int selectedYear;
  final Set<DateTime> selectedMonths;
  final List<DateTime> months;
  final ScrollController scrollController;
  final VoidCallback onShowYearPicker;
  final Function(DateTime) onMonthToggle;

  const MonthSlider({
    super.key,
    required this.selectedYear,
    required this.selectedMonths,
    required this.months,
    required this.scrollController,
    required this.onShowYearPicker,
    required this.onMonthToggle,
  });

  @override
  Widget build(BuildContext context) {
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
                "Year: $selectedYear",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const Spacer(),
              TextButton(
                onPressed: onShowYearPicker,
                child: const Text("Change Year", style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 45,
          child: ListView.builder(
            controller: scrollController,
            scrollDirection: Axis.horizontal,
            itemCount: 12,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              final month = DateTime(selectedYear, index + 1);
              final isSelected = selectedMonths.any((m) => m.month == month.month && m.year == month.year);

              return GestureDetector(
                onTap: () => onMonthToggle(month),
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
}
