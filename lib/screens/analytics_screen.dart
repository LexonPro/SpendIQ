import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../database/db_helper.dart';
import '../models/expense_model.dart';
import '../utils/category_helper.dart';
import '../ui/app_styles.dart';

enum ChartType { pie, bar, line }

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  AnalyticsScreenState createState() => AnalyticsScreenState();
}

/// Public state so main.dart can call refresh()
class AnalyticsScreenState extends State<AnalyticsScreen> {
  final DBHelper db = DBHelper.instance;

  List<ExpenseModel> expenses = [];
  ChartType type = ChartType.bar;

  late int selectedMonth;
  late int selectedYear;

  final List<String> _months = const [
    'January','February','March','April','May','June',
    'July','August','September','October','November','December',
  ];

  final List<String> allCategories = const [
    'Food','Transport','Shopping','Bills',
    'Entertainment','Health','Education','Other'
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedMonth = now.month;
    selectedYear = now.year;
    _load();
  }

  /// Called from main.dart when Analytics tab opens
  void refresh() => _load();

  Future<void> _load() async {
    final data = await db.getExpenses();
    expenses = data;
    setState(() {});
  }

  // ================= DATA =================

  Map<String, double> get categoryTotals {
    final map = {for (var c in allCategories) c: 0.0};

    for (final e in expenses) {
      if (e.type == 'expense' &&
          e.dateTime.year == selectedYear &&
          e.dateTime.month == selectedMonth) {
        map[e.category] = (map[e.category] ?? 0) + e.amount;
      }
    }
    return map;
  }

  double get totalExpense =>
      categoryTotals.values.fold(0.0, (a, b) => a + b);

  double get totalIncome => expenses
      .where((e) =>
          e.type == 'income' &&
          e.dateTime.month == selectedMonth &&
          e.dateTime.year == selectedYear)
      .fold(0.0, (s, e) => s + e.amount);

  double get balance => totalIncome - totalExpense;

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    final data = categoryTotals;

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    const Text("Month:",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButton<int>(
                        value: selectedMonth,
                        isExpanded: true,
                        items: List.generate(12, (i) {
                          return DropdownMenuItem(
                            value: i + 1,
                            child: Text('${_months[i]} $selectedYear'),
                          );
                        }),
                        onChanged: (v) {
                          if (v != null) setState(() => selectedMonth = v);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: ChartType.values.map((t) {
                    final selected = t == type;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: ChoiceChip(
                        label: Text(t.name.toUpperCase()),
                        selected: selected,
                        onSelected: (_) => setState(() => type = t),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 260,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: _buildChart(data),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              itemCount: allCategories.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 18, color: Colors.white10),
              itemBuilder: (_, i) {
                final cat = allCategories[i];
                final amount = data[cat] ?? 0;
                final color = CategoryHelper.getColor(cat);

                return Row(
                  children: [
                    CircleAvatar(radius: 6, backgroundColor: color),
                    const SizedBox(width: 12),
                    Expanded(child: Text(cat)),
                    Text(
                      '₹${amount.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ================= CHART SWITCH =================

  Widget _buildChart(Map<String, double> data) {
    switch (type) {
      case ChartType.bar:
        return _barChart(data);
      case ChartType.line:
        return _lineChart(data);
      default:
        return _pieChart(data);
    }
  }

  Widget _pieChart(Map<String, double> data) {
    final total = data.values.fold(0.0, (a, b) => a + b);

    return Stack(
      alignment: Alignment.center,
      children: [
        PieChart(
          PieChartData(
            sectionsSpace: 2,
            centerSpaceRadius: 60,
            sections: data.entries.map((e) {
              final percent = total == 0 ? 0 : (e.value / total * 100);
              return PieChartSectionData(
                value: e.value == 0 ? 0.1 : e.value,
                color: CategoryHelper.getColor(e.key),
                radius: 70,
                title: percent < 5 ? '' : '${percent.toStringAsFixed(0)}%',
              );
            }).toList(),
          ),
        ),
        Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    const Text(
      "Balance",
      style: TextStyle(
        color: Colors.grey,
        fontSize: 14,
      ),
    ),
    Text(
      "₹${balance.toStringAsFixed(0)}",
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: balance >= 0 ? Colors.green : Colors.red,
      ),
    ),
  ],
),

      ],
    );
  }

  Widget _barChart(Map<String, double> data) {
    final maxVal =
        data.values.isEmpty ? 1 : data.values.reduce((a, b) => a > b ? a : b);

    return BarChart(
      BarChartData(
        maxY: maxVal * 1.25,
        barGroups: allCategories.asMap().entries.map((e) {
          final amount = data[e.value] ?? 0;
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: amount,
                width: 18,
                color: CategoryHelper.getColor(e.value),
              )
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _lineChart(Map<String, double> data) {
    final spots = data.entries
        .toList()
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.value))
        .toList();

    return LineChart(
      LineChartData(
        minY: 0,
        lineBarsData: [
          LineChartBarData(
            spots: spots.isEmpty ? [const FlSpot(0, 0)] : spots,
            isCurved: true,
            barWidth: 4,
            gradient:
                const LinearGradient(colors: [AppColors.accent, Colors.green]),
          ),
        ],
      ),
    );
  }
}
