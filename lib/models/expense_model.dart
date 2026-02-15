class ExpenseModel {
  final int? id;
  final String title;
  final String category;
  final double amount;
  final DateTime dateTime;
  final String type; // 'expense' or 'income'

  ExpenseModel({
    this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.dateTime,
    this.type = 'expense',
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'category': category,
      'amount': amount,
      'dateTime': dateTime.toIso8601String(),
      'type': type,
    };
  }

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      category: map['category'] as String,
      amount: (map['amount'] as num).toDouble(),
      dateTime: DateTime.parse(map['dateTime'] as String),
      type: map['type'] as String? ?? 'expense',
    );
  }
}
