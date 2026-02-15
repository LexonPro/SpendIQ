import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';

import '../database/db_helper.dart';
import '../models/expense_model.dart';

class ExportExcelHelper {
  /// 📊 Always exports LATEST database data
  static Future<String?> exportExcel() async {
    try {
      /// 🔄 Force fresh DB read
      final List<ExpenseModel> expenses =
          await DBHelper.instance.getExpenses();

      /// Create Excel
      final excel = Excel.createExcel();
      final sheet = excel['Expenses'];

      /// Header
      sheet.appendRow([
        TextCellValue('Title'),
        TextCellValue('Amount'),
        TextCellValue('Category'),
        TextCellValue('Type'),
        TextCellValue('Date'),
      ]);

      /// Latest rows
      for (final e in expenses) {
        sheet.appendRow([
          TextCellValue(e.title),
          DoubleCellValue(e.amount),
          TextCellValue(e.category),
          TextCellValue(e.type),
          TextCellValue(e.dateTime.toLocal().toString()),
        ]);
      }

      /// Save location (always writable & fresh)
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/spendiq_expenses.xlsx';

      final file = File(filePath);

      /// Delete old file first (IMPORTANT 🔥)
      if (await file.exists()) {
        await file.delete();
      }

      final bytes = excel.encode();
      if (bytes == null) return null;

      await file.writeAsBytes(bytes, flush: true);

      return filePath;
    } catch (e) {
      print('EXCEL EXPORT ERROR: $e');
      return null;
    }
  }
}
