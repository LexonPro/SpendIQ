import 'dart:io';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

import '../database/db_helper.dart';
import 'date_utils.dart';

class ExportPdfHelper {
  static Future<String> exportPDF() async {
    final pdf = pw.Document();
    final db = DBHelper.instance;
    final expenses = await db.getExpenses();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Text(
            'SpendIQ – Expense Report',
            style: pw.TextStyle(
              fontSize: 22,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 16),
          pw.Table.fromTextArray(
            headers: ['Date', 'Title', 'Category', 'Type', 'Amount'],
            data: expenses
                .map(
                  (e) => [
                    DateUtilsHelper.formatDateTime(e.dateTime),
                    e.title,
                    e.category,
                    e.type,
                    '₹${e.amount.toStringAsFixed(0)}',
                  ],
                )
                .toList(),
          ),
        ],
      ),
    );

    final dir = await getExternalStorageDirectory();
    final file = File('${dir!.path}/spendiq_expenses.pdf');

    await file.writeAsBytes(await pdf.save());
    return file.path;
  }
}
