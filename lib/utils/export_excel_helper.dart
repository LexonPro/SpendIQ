import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';

import '../database/db_helper.dart';
import '../models/expense_model.dart';

class ExportExcelHelper {
  static Future<String?> exportExcel() async {
    try {
      /// Always fetch latest DB data
      final List<ExpenseModel> expenses =
          await DBHelper.instance.getExpenses();

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

      /// Rows
      for (final e in expenses) {
        sheet.appendRow([
          TextCellValue(e.title),
          DoubleCellValue(e.amount),
          TextCellValue(e.category),
          TextCellValue(e.type),
          TextCellValue(e.dateTime.toLocal().toString()),
        ]);
      }

      /// 🔥 SAVE TO DOWNLOADS FOLDER (REAL FIX)
      final dir = await getExternalStorageDirectory();
      if (dir == null) throw Exception("Storage not available");

      final downloadsPath = dir.path.replaceAll(
        "Android/data/${dir.path.split("Android/data/").last.split("/").first}/files",
        "Download",
      );

      final filePath =
          "$downloadsPath/spendiq_${DateTime.now().millisecondsSinceEpoch}.xlsx";

      final file = File(filePath);

      final bytes = excel.encode();
      if (bytes == null || bytes.isEmpty) {
        throw Exception("Excel encode failed");
      }

      await file.writeAsBytes(bytes, flush: true);

      return filePath;
    } catch (e) {
      print("EXCEL EXPORT ERROR: $e");
      return null;
    }
  }
}
