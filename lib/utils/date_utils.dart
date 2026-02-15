import 'package:intl/intl.dart';

class DateUtilsHelper {
  static String formatDateTime(DateTime dateTime) {
    final date = DateFormat('dd MMM yyyy').format(dateTime);
    final time = DateFormat('h:mm a').format(dateTime);
    return '$date • $time';
  }
}
