import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../data/model/transaction/transaction_model.dart';
import '../../domain/entities/transaction_entity.dart';
import '../category/cubit/category_cubit.dart';
import '../utils/snackbar_utils.dart';
import 'cubit/transaction_cubit.dart';
import 'widgets/category_dropdown_field.dart';
import 'widgets/transaction_date_picker.dart';
import 'widgets/transaction_text_field.dart';
import 'widgets/transaction_type_selector.dart';

class AddTransactionScreen extends StatefulWidget {
  final TransactionEntity? transaction;

  const AddTransactionScreen({super.key, this.transaction});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  TransactionType _selectedType = TransactionType.expense;
  String? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();

  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final transaction = widget.transaction;
    if (transaction != null) {
      _titleController.text = transaction.title;
      _amountController.text = transaction.amount.toString();
      _noteController.text = transaction.note ?? '';
      _selectedType = transaction.type;
      _selectedCategoryId = transaction.categoryId;
      _selectedDate = transaction.date;
    }

    final uid = FirebaseAuth.instance.currentUser!.uid;
    context.read<CategoryCubit>().loadCategories(
      uid: uid,
      type: _selectedType.name,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveTransaction() async {
    if (_isSaving) return;

    final title = _titleController.text.trim();
    final amount = double.tryParse(_amountController.text.trim());
    final note = _noteController.text.trim();

    if (title.isEmpty || amount == null || amount <= 0) {
      SnackBarUtils.showError(
        context,
        'Please enter valid transaction details.',
      );
      return;
    }

    if (_selectedCategoryId == null) {
      SnackBarUtils.showError(
        context,
        'Please select a category.',
      );
      return;
    }

    setState(() => _isSaving = true);

    final transaction = TransactionModel(
      id:
          widget.transaction?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      amount: amount,
      type: _selectedType,
      categoryId: _selectedCategoryId,
      date: _selectedDate,
      note: note.isEmpty ? null : note,
    );

    final cubit = context.read<TransactionCubit>();

    try {
      if (widget.transaction == null) {
        await cubit.addTransaction(transaction);
      } else {
        await cubit.updateTransaction(transaction);
      }

      if (!mounted) return;
      
      // Navigate first, then show success (prevents Snackbar from blocking nav)
      context.pop();
      
      SnackBarUtils.showSuccess(
        context,
        widget.transaction == null
            ? 'Transaction added successfully.'
            : 'Transaction updated successfully.',
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      SnackBarUtils.showError(
        context,
        'Failed to save transaction: ${e.toString()}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = widget.transaction != null;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: isDark
            ? const Color(0xFF121212)
            : const Color(0xFFF7F7FB),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            isEditing ? 'Update Transaction' : 'Add Transaction',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TransactionTypeSelector(
                selectedType: _selectedType,
                onTypeChanged: (type) {
                  setState(() => _selectedType = type);
                },
              ),
              const SizedBox(height: 30),
              _buildLabel('Title'),
              const SizedBox(height: 8),
              TransactionTextField(
                controller: _titleController,
                hint: 'e.g. Monthly Salary or Lunch',
                prefix: const Icon(
                  Icons.title_rounded,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 20),
              _buildLabel('Amount'),
              const SizedBox(height: 8),
              TransactionTextField(
                controller: _amountController,
                hint: '0',
                prefix: Container(
                  width: 60,
                  alignment: Alignment.center,
                  child: const Text(
                    'Ks',
                    style: TextStyle(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              const SizedBox(height: 20),
              _buildLabel('Category'),
              const SizedBox(height: 8),
              CategoryDropdownField(
                selectedType: _selectedType,
                selectedCategoryId: _selectedCategoryId,
                onCategoryChanged: (value) {
                  setState(() => _selectedCategoryId = value);
                },
              ),
              const SizedBox(height: 20),
              _buildLabel('Date'),
              const SizedBox(height: 8),
              TransactionDatePicker(
                selectedDate: _selectedDate,
                onDateChanged: (date) {
                  setState(() => _selectedDate = date);
                },
              ),
              const SizedBox(height: 20),
              _buildLabel('Note (Optional)'),
              const SizedBox(height: 8),
              TransactionTextField(
                controller: _noteController,
                hint: 'Add a note...',
                prefix: const Icon(
                  Icons.note_add_outlined,
                  color: Colors.deepPurple,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.deepPurple, Color(0xFF9575CD)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurple.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveTransaction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            isEditing
                                ? 'Update Transaction'
                                : 'Save Transaction',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Colors.grey,
      ),
    );
  }
}
