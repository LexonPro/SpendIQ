import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/expense_model.dart';
import '../utils/category_helper.dart';

class AddExpense extends StatefulWidget {
  const AddExpense({super.key});

  @override
  State<AddExpense> createState() => _AddExpenseState();
}

class _AddExpenseState extends State<AddExpense> {
  final titleCtrl = TextEditingController();
  final amountCtrl = TextEditingController();

  String category = CategoryHelper.categories.first;
  String type = 'expense'; // default

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Transaction')),
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
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Title'),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: amountCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Amount'),
            ),

            const SizedBox(height: 10),

            DropdownButton<String>(
              value: category,
              isExpanded: true,
              items: CategoryHelper.categories
                  .map(
                    (c) => DropdownMenuItem(
                      value: c,
                      child: Text(c),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => category = v!),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                final title = titleCtrl.text.trim();
                final amount =
                    double.tryParse(amountCtrl.text.trim());

                if (title.isEmpty || amount == null || amount <= 0) {
                  return;
                }

                final expense = ExpenseModel(
                  title: title,
                  amount: amount,
                  category: category,
                  dateTime: DateTime.now(),
                  type: type,
                );

                await DBHelper.instance.insertExpense(expense);

                Navigator.pop(context, true);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
