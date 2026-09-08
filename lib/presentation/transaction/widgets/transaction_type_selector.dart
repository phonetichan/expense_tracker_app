import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../../category/cubit/category_cubit.dart';

class TransactionTypeSelector extends StatelessWidget {
  final TransactionType selectedType;
  final Function(TransactionType) onTypeChanged;

  const TransactionTypeSelector({
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
            type: TransactionType.income,
            label: 'Income',
            isSelected: selectedType == TransactionType.income,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildTypeButton(
            context,
            type: TransactionType.expense,
            label: 'Expense',
            isSelected: selectedType == TransactionType.expense,
            color: Colors.redAccent,
          ),
        ),
      ],
    );
  }

  Widget _buildTypeButton(
    BuildContext context, {
    required TransactionType type,
    required String label,
    required bool isSelected,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        onTypeChanged(type);
        final uid = FirebaseAuth.instance.currentUser!.uid;
        context.read<CategoryCubit>().loadCategories(uid: uid, type: type.name);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.2)
              : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              type == TransactionType.income
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: isSelected ? color : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? color
                    : (isDark ? Colors.white : Colors.black87),
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
