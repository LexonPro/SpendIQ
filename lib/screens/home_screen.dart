import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'contribute_screen.dart';

import '../database/db_helper.dart';
import '../models/expense_model.dart';
import '../utils/date_utils.dart';
import '../utils/category_helper.dart';

import 'add_expense.dart';
import 'edit_expense_screen.dart';

import '../widgets/empty_state.dart';

enum FilterType { all, income, expense }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final DBHelper db = DBHelper.instance;

  List<ExpenseModel> allExpenses = [];
  bool isLoading = true;

  late int selectedMonth;
  late int selectedYear;
  FilterType filter = FilterType.all;

  bool fabOpen = false;

  late AnimationController _chartController;
  late Animation<double> _chartScale;

  final List<String> months = const [
    'January','February','March','April','May','June',
    'July','August','September','October','November','December'
  ];

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    selectedMonth = now.month;
    selectedYear = now.year;

    _chartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _chartScale = CurvedAnimation(
      parent: _chartController,
      curve: Curves.easeOutBack,
    );

    _load();
  }

  Future<void> _load() async {
    setState(() => isLoading = true);
    allExpenses = await db.getExpenses();
    setState(() => isLoading = false);

    _chartController.forward(from: 0);
  }

  @override
  void dispose() {
    _chartController.dispose();
    super.dispose();
  }

  List<ExpenseModel> get visibleExpenses {
    return allExpenses.where((e) {
      final sameMonth =
          e.dateTime.month == selectedMonth &&
          e.dateTime.year == selectedYear;

      if (!sameMonth) return false;

      if (filter == FilterType.income) return e.type == 'income';
      if (filter == FilterType.expense) return e.type == 'expense';

      return true;
    }).toList();
  }

  double get totalIncome =>
      visibleExpenses.where((e) => e.type == 'income').fold(0.0, (s, e) => s + e.amount);

  double get totalExpense =>
      visibleExpenses.where((e) => e.type == 'expense').fold(0.0, (s, e) => s + e.amount);

  double get balance => totalIncome - totalExpense;

  Widget _legendDot(String label, Color color, double value) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text('$label ₹${value.toStringAsFixed(0)}'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final glowColor = balance >= 0 ? Colors.greenAccent : Colors.redAccent;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SpendIQ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            tooltip: "Support Developer",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ContributeScreen()),
              );
            },
          ),
        ],
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// MONTH SELECTOR
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: DropdownButton<int>(
              value: selectedMonth,
              isExpanded: true,
              items: List.generate(12, (i) {
                return DropdownMenuItem(
                  value: i + 1,
                  child: Text('${months[i]} $selectedYear'),
                );
              }),
              onChanged: (v) {
                if (v != null) {
                  setState(() => selectedMonth = v);
                  _chartController.forward(from: 0);
                }
              },
            ),
          ),

          /// PIE BALANCE CARD WITH ANIMATION
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ScaleTransition(
              scale: _chartScale,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                elevation: 6,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 180,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            PieChart(
                              PieChartData(
                                sectionsSpace: 2,
                                centerSpaceRadius: 60,
                                sections: [
                                  PieChartSectionData(
                                    value: totalExpense == 0 && totalIncome == 0
                                        ? 1
                                        : totalExpense,
                                    color: Colors.redAccent,
                                    showTitle: false,
                                    radius: 42,
                                  ),
                                  PieChartSectionData(
                                    value: totalIncome,
                                    color: Colors.greenAccent,
                                    showTitle: false,
                                    radius: 42,
                                  ),
                                ],
                              ),
                            ),

                            /// BALANCE TEXT WITH NEON GLOW
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Balance',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '₹${balance.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: glowColor,
                                    shadows: [
                                      Shadow(
                                        color: glowColor.withOpacity(0.7),
                                        blurRadius: 18,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _legendDot('Income', Colors.greenAccent, totalIncome),
                          _legendDot('Expense', Colors.redAccent, totalExpense),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          /// FILTER CHIPS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _chip('All', FilterType.all),
                _chip('Income', FilterType.income),
                _chip('Expense', FilterType.expense),
              ],
            ),
          ),

          /// LIST
          Expanded(
            child: visibleExpenses.isEmpty
                ? const EmptyState(
                    title: 'No transactions',
                    subtitle: 'Try another month or add new one',
                    icon: Icons.account_balance_wallet_outlined,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: visibleExpenses.length,
                    itemBuilder: (_, i) {
                      final e = visibleExpenses[i];
                      final isIncome = e.type == 'income';

                      final color = CategoryHelper.getColor(e.category);
                      final icon = CategoryHelper.getIcon(e.category);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 4,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: color.withOpacity(0.15),
                            child: Icon(icon, color: color),
                          ),
                          title: Text(
                            e.title,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(DateUtilsHelper.formatDateTime(e.dateTime)),
                          trailing: Text(
                            '${isIncome ? '+' : '-'} ₹${e.amount.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isIncome ? Colors.greenAccent : Colors.redAccent,
                            ),
                          ),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditExpenseScreen(expense: e),
                              ),
                            );
                            _load();
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      /// ANIMATED FAB
      floatingActionButton: AnimatedScale(
        scale: fabOpen ? 1.1 : 1,
        duration: const Duration(milliseconds: 200),
        child: FloatingActionButton(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddExpense()),
            );
            _load();
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _chip(String text, FilterType type) {
    final selected = filter == type;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(text),
        selected: selected,
        selectedColor: Colors.greenAccent.withOpacity(0.2),
        onSelected: (_) => setState(() => filter = type),
      ),
    );
  }
}
