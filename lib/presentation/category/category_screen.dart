import 'package:expense_tracker_app/presentation/category/widgets/category_list_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/model/category_model.dart';
import 'category_form_screen.dart';
import 'cubit/category_cubit.dart';
import 'cubit/category_state.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  @override
  void initState() {
    super.initState();

    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid != null) {
      context.read<CategoryCubit>().loadAllCategories(uid: uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
      isDark ? const Color(0xFF121212) : const Color(0xFFF7F7FB),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Categories',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CategoryFormScreen(),
            ),
          );

          if (!mounted) return;

          final uid =
              FirebaseAuth.instance.currentUser?.uid;

          if (uid != null) {
            if (context.mounted) {
              context.read<CategoryCubit>().loadAllCategories(uid: uid);
            }
          }
        },
        child: const Icon(Icons.add),
      ),

      body: BlocBuilder<CategoryCubit, CategoryState>(
        builder: (context, state) {
          List<CategoryModel> categories = [];
          bool isLoading = false;

          if (state is CategoryLoading) {
            categories = state.categories;
            isLoading = true;
          } else if (state is CategoryLoaded) {
            categories = state.categories;
          } else if (state is CategoryError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.redAccent),
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(color: Colors.deepPurple),
            );
          }

          if (categories.isEmpty && !isLoading) {
            return const Center(
              child: Text(
                'No categories found.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          final expenseCategories = categories
              .where((category) => category.type == 'expense')
              .toList();

          final incomeCategories = categories
              .where((category) => category.type == 'income')
              .toList();

          return Stack(
            children: [
              RefreshIndicator(
                color: Colors.deepPurple,
                onRefresh: () async {
                  final uid = FirebaseAuth.instance.currentUser?.uid;
                  if (uid != null) {
                    await context
                        .read<CategoryCubit>()
                        .loadAllCategories(uid: uid);
                  }
                },
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                  children: [
                    if (expenseCategories.isNotEmpty) ...[
                      _buildSectionTitle('Expense', isDark),
                      const SizedBox(height: 10),
                      ...expenseCategories.map(
                        (category) => CategoryListItem(
                          category: category,
                          onEdit: () => _editCategory(category),
                          onDelete: () => _deleteCategory(category),
                        ),
                      ),
                      const SizedBox(height: 25),
                    ],
                    if (incomeCategories.isNotEmpty) ...[
                      _buildSectionTitle('Income', isDark),
                      const SizedBox(height: 10),
                      ...incomeCategories.map(
                        (category) => CategoryListItem(
                          category: category,
                          onEdit: () => _editCategory(category),
                          onDelete: () => _deleteCategory(category),
                        ),
                      ),
                    ],
                  ],
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
      ),
    );
  }

  Widget _buildSectionTitle(
      String title,
      bool isDark,
      ) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        letterSpacing: 1,
        color: isDark
            ? Colors.white70
            : Colors.black54,
      ),
    );
  }

  Future<void> _editCategory(
      CategoryModel category,
      ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryFormScreen(
          category: category,
        ),
      ),
    );

    if (!mounted) return;

    final uid =
        FirebaseAuth.instance.currentUser?.uid;

    if (uid != null) {
      context
          .read<CategoryCubit>()
          .loadAllCategories(uid: uid);
    }
  }

  Future<void> _deleteCategory(
      CategoryModel category,
      ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Category'),
          content: Text(
            'Are you sure you want to delete '
                '"${category.name}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    if (context.mounted) {
      await context.read<CategoryCubit>().deleteCategory(
            uid: uid,
            categoryId: category.id,
            type: category.type,
          );
    }
  }
}
