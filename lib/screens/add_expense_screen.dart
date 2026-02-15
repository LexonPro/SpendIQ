import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/expense_model.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String _category = 'Food';

  final List<String> _categories = [
    'Food',
    'Transport',
    'Shopping',
    'Bills',
    'Entertainment',
    'Other',
  ];

  final DBHelper _dbHelper = DBHelper();

  Future<void> _saveExpense() async {
    final title = _titleController.text.trim();
    final amount = double.tryParse(_amountController.text.trim());

    if (title.isEmpty || amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter valid data')),
      );
      return;
    }

    await _dbHelper.insertExpense(
      ExpenseModel(
        title: title,
        category: _category,
        amount: amount,
        dateTime: DateTime.now(),
      ),
    );

    Navigator.pop(context, true); // return success
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Expense')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount (₹)',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _category,
              items: _categories
                  .map(
                    (c) => DropdownMenuItem(
                      value: c,
                      child: Text(c),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _category = v!),
              decoration: const InputDecoration(
                labelText: 'Category',
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveExpense,
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
