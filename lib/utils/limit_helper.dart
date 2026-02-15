import 'package:shared_preferences/shared_preferences.dart';

class LimitHelper {
  static const String _key = 'monthly_limit';

  static Future<void> setLimit(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_key, value);
  }

  static Future<double> getLimit() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_key) ?? 0.0;
  }
}
