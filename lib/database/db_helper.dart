import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/expense_model.dart';

class DBHelper {
  DBHelper._internal();
  static final DBHelper instance = DBHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'spendiq.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        dateTime TEXT NOT NULL,
        type TEXT NOT NULL DEFAULT 'expense'
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        "ALTER TABLE expenses ADD COLUMN type TEXT NOT NULL DEFAULT 'expense'",
      );
    }
  }

  Future<int> insertExpense(ExpenseModel expense) async {
    final db = await database;
    return await db.insert('expenses', expense.toMap());
  }

  Future<List<ExpenseModel>> getExpenses() async {
    final db = await database;
    final maps = await db.query(
      'expenses',
      orderBy: 'dateTime DESC',
    );
    return maps.map((e) => ExpenseModel.fromMap(e)).toList();
  }

  Future<void> updateExpense(ExpenseModel expense) async {
    final db = await database;
    await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<void> deleteExpense(int id) async {
    final db = await database;
    await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearAllExpenses() async {
    final db = await database;
    await db.delete('expenses');
  }
}
