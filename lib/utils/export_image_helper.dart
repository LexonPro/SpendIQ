import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../database/db_helper.dart';

class ExportImageHelper {
  static Future<String> exportImage() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    const width = 800.0;
    const height = 1000.0;

    final paint = Paint()..color = Colors.white;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, width, height),
      paint,
    );

    final textPainter =
        TextPainter(textDirection: TextDirection.ltr);

    textPainter.text = const TextSpan(
      text: 'SpendIQ – Expense Summary',
      style: TextStyle(
        color: Colors.black,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, const Offset(20, 20));

    final db = DBHelper.instance;
    final expenses = await db.getExpenses();

    double y = 80;
    for (final e in expenses.take(15)) {
      textPainter.text = TextSpan(
        text: '${e.title}  |  ${e.type}  |  ₹${e.amount}',
        style: const TextStyle(color: Colors.black, fontSize: 18),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(20, y));
      y += 30;
    }

    final picture = recorder.endRecording();
    final image =
        await picture.toImage(width.toInt(), height.toInt());
    final byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);

    final dir = await getExternalStorageDirectory();
    final file = File('${dir!.path}/spendiq_expenses.png');

    await file.writeAsBytes(byteData!.buffer.asUint8List());
    return file.path;
  }
}
