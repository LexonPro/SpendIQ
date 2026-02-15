import 'package:flutter/material.dart';

import '../database/db_helper.dart';
import '../models/expense_model.dart';

class EditExpenseScreen extends StatefulWidget {
  final ExpenseModel expense;

  const EditExpenseScreen({super.key, required this.expense});

  @override
  State<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  late TextEditingController titleController;
  late TextEditingController amountController;

  final DBHelper db = DBHelper.instance;
  late String type; // expense / income

  @override
  void initState() {
    super.initState();
    titleController =
        TextEditingController(text: widget.expense.title);
    amountController =
        TextEditingController(text: widget.expense.amount.toString());
    type = widget.expense.type; // 🔴 keep existing type
  }

  Future<void> _saveExpense() async {
    final String title = titleController.text.trim();
    final String amountText = amountController.text.trim();

    if (title.isEmpty || amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final double amount = double.tryParse(amountText) ?? 0;

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Amount must be greater than 0')),
      );
      return;
    }

    final updatedExpense = ExpenseModel(
      id: widget.expense.id, // 🔒 keep same ID
      title: title,
      category: widget.expense.category, // unchanged
      amount: amount,
      dateTime: widget.expense.dateTime, // unchanged
      type: type, // 🔴 IMPORTANT
    );

    await db.updateExpense(updatedExpense);

    Navigator.pop(context); // HomeScreen reloads
  }

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Transaction')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// 🔁 Expense / Income Toggle
            ToggleButtons(
              isSelected: [
                type == 'expense',
                type == 'income',
              ],
              onPressed: (i) {
                setState(() {
                  type = i == 0 ? 'expense' : 'income';
                });
              },
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text('Expense'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text('Income'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Amount'),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _saveExpense,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
