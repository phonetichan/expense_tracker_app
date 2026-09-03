import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/utils/category_icon_utils.dart';
import '../../data/model/category_model.dart';
import 'cubit/category_cubit.dart';

// create and edit page
class CategoryFormScreen extends StatefulWidget {
  final CategoryModel? category;

  const CategoryFormScreen({
    super.key,
    this.category,
  });

  @override
  State<CategoryFormScreen> createState() =>
      _CategoryFormScreenState();
}

class _CategoryFormScreenState
    extends State<CategoryFormScreen> {
  final _nameController = TextEditingController();

  String _selectedType = 'expense';
  String _selectedIcon = 'category';

  bool _isSaving = false;

  final List<String> _icons = [
    'category',
    'restaurant',
    'directions_car',
    'shopping_cart',
    'home',
    'movie',
    'school',
    'medical_services',
    'fitness_center',
    'payments',
    'work',
    'flight',
    'pets',
  ];

  @override
  void initState() {
    super.initState();

    final category = widget.category;

    if (category != null) {
      _nameController.text = category.name;
      _selectedType = category.type;
      _selectedIcon = category.icon;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveCategory() async {
    if (_isSaving) return;

    final name = _nameController.text.trim();

    if (name.isEmpty) {
      _showMessage('Please enter a category name.');
      return;
    }

    final uid =
        FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      _showMessage('User is not logged in.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final category = CategoryModel(
      id: widget.category?.id ?? '',
      name: name,
      icon: _selectedIcon,
      type: _selectedType,
    );

    try {
      if (widget.category == null) {
        await context.read<CategoryCubit>().addCategory(
          uid: uid,
          category: category,
        );
      } else {
        await context.read<CategoryCubit>().updateCategory(
          uid: uid,
          category: category,
        );
      }

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      _showMessage('Failed to save category.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final isEditing = widget.category != null;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: isDark
            ? const Color(0xFF121212)
            : const Color(0xFFF7F7FB),

        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            isEditing
                ? 'Edit Category'
                : 'Add Category',
            style: TextStyle(
              color: isDark
                  ? Colors.white
                  : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              _buildLabel('Category Name'),

              const SizedBox(height: 8),

              TextField(
                controller: _nameController,
                style: TextStyle(
                  color: isDark
                      ? Colors.white
                      : Colors.black,
                ),
                decoration: InputDecoration(
                  hintText: 'e.g. Food',
                  prefixIcon: const Icon(
                    Icons.category_outlined,
                    color: Colors.deepPurple,
                  ),
                  filled: true,
                  fillColor: isDark
                      ? const Color(0xFF1E1E1E)
                      : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              _buildLabel('Type'),

              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: _buildTypeButton(
                      'expense',
                      'Expense',
                      Colors.redAccent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTypeButton(
                      'income',
                      'Income',
                      Colors.green,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              _buildLabel('Icon'),

              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E1E1E)
                      : Colors.white,
                  borderRadius:
                  BorderRadius.circular(12),
                ),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics:
                  const NeverScrollableScrollPhysics(),
                  itemCount: _icons.length,
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  itemBuilder: (context, index) {
                    final iconName = _icons[index];
                    final selected =
                        iconName == _selectedIcon;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedIcon = iconName;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: selected
                              ? Colors.deepPurple
                              .withOpacity(0.15)
                              : Colors.transparent,
                          borderRadius:
                          BorderRadius.circular(10),
                          border: Border.all(
                            color: selected
                                ? Colors.deepPurple
                                : Colors.transparent,
                          ),
                        ),
                        child: Icon(
                          getCategoryIcon(iconName),
                          color: selected
                              ? Colors.deepPurple
                              : Colors.grey,
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                  _isSaving ? null : _saveCategory,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding:
                    const EdgeInsets.symmetric(
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child:
                    CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : Text(
                    isEditing
                        ? 'Update Category'
                        : 'Save Category',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildTypeButton(
      String type,
      String label,
      Color color,
      ) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final selected = _selectedType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
        });
      },
      child: AnimatedContainer(
        duration:
        const Duration(milliseconds: 200),
        padding:
        const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? color.withOpacity(0.15)
              : isDark
              ? const Color(0xFF1E1E1E)
              : Colors.white,
          borderRadius:
          BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? color
                : Colors.transparent,
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
