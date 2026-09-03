import 'package:flutter/material.dart';

class CategoryTypeSelector extends StatelessWidget {
  final String selectedType;
  final ValueChanged<String> onTypeChanged;

  const CategoryTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildTypeButton(
            context,
            'expense',
            'Expense',
            Colors.redAccent,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildTypeButton(
            context,
            'income',
            'Income',
            Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildTypeButton(
    BuildContext context,
    String type,
    String label,
    Color color,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selected = selectedType == type;

    return GestureDetector(
      onTap: () => onTypeChanged(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? color.withOpacity(0.15)
              : isDark
                  ? const Color(0xFF1E1E1E)
                  : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected
                ? color
                : isDark
                    ? Colors.white
                    : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
