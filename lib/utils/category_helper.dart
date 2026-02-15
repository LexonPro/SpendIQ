import 'package:flutter/material.dart';

class CategoryHelper {
  static const List<String> categories = [
    'Food',
    'Transport',
    'Shopping',
    'Bills',
    'Entertainment',
    'Health',
    'Education',
    'Other',
  ];

  // 🔹 Central category config (icon + color)
  static const Map<String, IconData> _iconMap = {
    'Food': Icons.restaurant,
    'Transport': Icons.directions_bus,
    'Shopping': Icons.shopping_bag,
    'Bills': Icons.receipt_long,
    'Entertainment': Icons.movie,
    'Health': Icons.health_and_safety,
    'Education': Icons.school,
  };

  static const Map<String, Color> _colorMap = {
    'Food': Colors.orange,
    'Transport': Colors.blue,
    'Shopping': Colors.purple,
    'Bills': Colors.red,
    'Entertainment': Colors.green,
    'Health': Colors.teal,
    'Education': Colors.indigo,
  };

  // 🔹 Public helpers (used everywhere)
  static IconData getIcon(String category) {
    return _iconMap[category] ?? Icons.category;
  }

  static Color getColor(String category) {
    return _colorMap[category] ?? Colors.grey;
  }
}