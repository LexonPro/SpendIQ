import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/expense_model.dart';
import '../utils/date_utils.dart';
import 'edit_expense_screen.dart';

class MonthlyExpenseScreen extends StatefulWidget {
  const MonthlyExpenseScreen({super.key});

  @override
  State<MonthlyExpenseScreen> createState() =>
      _MonthlyExpenseScreenState();
}

class _MonthlyExpenseScreenState extends State<MonthlyExpenseScreen> {
  final DBHelper db = DBHelper.instance;
  List<ExpenseModel> expenses = [];

  final List<String> _months = const [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    expenses = await db.getExpenses();
    setState(() {});
  }

  /// Group ALL transactions by year-month
  Map<String, List<ExpenseModel>> get groupedByMonth {
    final Map<String, List<ExpenseModel>> map = {};

    for (final e in expenses) {
      final key =
          '${e.dateTime.year}-${e.dateTime.month.toString().padLeft(2, '0')}';
      map.putIfAbsent(key, () => []).add(e);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final entries = groupedByMonth.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));

    return Scaffold(
      appBar: AppBar(title: const Text('Monthly Summary')),
      body: entries.isEmpty
          ? const Center(child: Text('No transactions found'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final monthKey = entries[index].key;
                final monthItems = entries[index].value;

                final totalExpense = monthItems
                    .where((e) => e.type == 'expense')
                    .fold<double>(0, (s, e) => s + e.amount);

                final totalIncome = monthItems
                    .where((e) => e.type == 'income')
                    .fold<double>(0, (s, e) => s + e.amount);

                final balance = totalIncome - totalExpense;

                final parts = monthKey.split('-');
                final label =
                    '${_months[int.parse(parts[1]) - 1]} ${parts[0]}';

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),

                        _row('Expense', totalExpense, Colors.red),
                        _row('Income', totalIncome, Colors.green),
                        const Divider(),
                        _row(
                          'Balance',
                          balance,
                          balance >= 0
                              ? Colors.green
                              : Colors.red,
                          bold: true,
                        ),

                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MonthDetailScreen(
                                    title: label,
                                    expenses: monthItems,
                                  ),
                                ),
                              );
                            },
                            child: const Text('View details'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _row(String label, double value, Color color,
      {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style:
                bold ? const TextStyle(fontWeight: FontWeight.bold) : null),
        Text(
          '₹${value.toStringAsFixed(0)}',
          style: TextStyle(
            color: color,
            fontWeight: bold ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class MonthDetailScreen extends StatelessWidget {
  final String title;
  final List<ExpenseModel> expenses;

  const MonthDetailScreen({
    super.key,
    required this.title,
    required this.expenses,
  });

  @override
  Widget build(BuildContext context) {
    final totalExpense = expenses
        .where((e) => e.type == 'expense')
        .fold<double>(0, (s, e) => s + e.amount);

    final totalIncome = expenses
        .where((e) => e.type == 'income')
        .fold<double>(0, (s, e) => s + e.amount);

    final balance = totalIncome - totalExpense;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Column(
        children: [
          /// 🔹 SUMMARY HEADER
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _summaryRow('Expense', totalExpense, Colors.red),
                  _summaryRow('Income', totalIncome, Colors.green),
                  const Divider(),
                  _summaryRow(
                    'Balance',
                    balance,
                    balance >= 0 ? Colors.green : Colors.red,
                    bold: true,
                  ),
                ],
              ),
            ),
          ),

          /// 🔹 TRANSACTIONS
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                final e = expenses[index];
                final isIncome = e.type == 'income';

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(e.title),
                    subtitle: Text(
                      DateUtilsHelper.formatDateTime(e.dateTime),
                    ),
                    trailing: Text(
                      '${isIncome ? '+' : '-'} ₹${e.amount.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isIncome
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              EditExpenseScreen(expense: e),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, double value, Color color,
      {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style:
                bold ? const TextStyle(fontWeight: FontWeight.bold) : null),
        Text(
          '₹${value.toStringAsFixed(0)}',
          style: TextStyle(
            color: color,
            fontWeight: bold ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
