import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/category_icon_utils.dart';
import '../../../data/model/category_model.dart';
import '../../../data/model/transaction_model.dart';
import '../../../domain/transaction.dart';
import '../../category/category_form_screen.dart';
import '../../category/cubit/category_cubit.dart';
import '../../category/cubit/category_state.dart';

class CategoryDropdownField extends StatelessWidget {
  final TransactionType selectedType;
  final String? selectedCategoryId;
  final ValueChanged<String?> onCategoryChanged;

  const CategoryDropdownField({
    super.key,
    required this.selectedType,
    required this.selectedCategoryId,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const addCategoryValue = '__add_category__';

    return BlocBuilder<CategoryCubit, CategoryState>(
      builder: (context, state) {
        if (state is CategoryLoading) {
          return _buildLoadingContainer(isDark);
        }

        if (state is CategoryError) {
          return _buildErrorContainer(isDark, context);
        }

        if (state is CategoryLoaded) {
          final categories = state.categories;

          if (categories.isEmpty) {
            return _buildEmptyContainer(isDark, context, addCategoryValue);
          }

          final categoryExists = categories.any(
            (category) => category.id == selectedCategoryId,
          );

          final selectedValue = categoryExists ? selectedCategoryId : null;

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButtonFormField<String>(
                value: selectedValue,
                dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 16,
                ),
                decoration: const InputDecoration(border: InputBorder.none),
                hint: const Text('Select category'),
                items: [
                  ...categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category.id,
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.deepPurple.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              getCategoryIcon(category.icon),
                              color: Colors.deepPurple,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            category.name,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const DropdownMenuItem<String>(
                    value: addCategoryValue,
                    child: Row(
                      children: [
                        Icon(
                          Icons.add_circle_outline,
                          color: Colors.deepPurple,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Add Category',
                          style: TextStyle(
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                onChanged: (value) async {
                  if (value == addCategoryValue) {
                    final newCategory = await Navigator.push<CategoryModel>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CategoryFormScreen(),
                      ),
                    );

                    if (!context.mounted) return;

                    final uid = FirebaseAuth.instance.currentUser?.uid;
                    if (uid != null) {
                      await context.read<CategoryCubit>().loadCategories(
                            uid: uid,
                            type: selectedType.name,
                          );
                    }

                    if (newCategory != null) {
                      onCategoryChanged(newCategory.id);
                    }
                    return;
                  }
                  onCategoryChanged(value);
                },
              ),
            ),
          );
        }

        return _buildInitialContainer(isDark);
      },
    );
  }

  Widget _buildLoadingContainer(bool isDark) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: SizedBox(
          height: 22,
          width: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.deepPurple,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorContainer(bool isDark, BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Failed to load categories.',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyContainer(bool isDark, BuildContext context, String addCategoryValue) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<String>(
          dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          decoration: const InputDecoration(border: InputBorder.none),
          hint: const Text('No categories available.'),
          items: [
            DropdownMenuItem<String>(
              value: addCategoryValue,
              child: const Row(
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    color: Colors.deepPurple,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Add Category',
                    style: TextStyle(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
          onChanged: (value) async {
            if (value == addCategoryValue) {
              final newCategory = await Navigator.push<CategoryModel>(
                context,
                MaterialPageRoute(
                  builder: (_) => const CategoryFormScreen(),
                ),
              );

              if (!context.mounted) return;

              final uid = FirebaseAuth.instance.currentUser?.uid;
              if (uid != null) {
                await context.read<CategoryCubit>().loadCategories(
                      uid: uid,
                      type: selectedType.name,
                    );
              }

              if (newCategory != null) {
                onCategoryChanged(newCategory.id);
              }
            }
          },
        ),
      ),
    );
  }

  Widget _buildInitialContainer(bool isDark) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Align(
        alignment: Alignment.centerLeft,
        child: Text('Select category'),
      ),
    );
  }
}
