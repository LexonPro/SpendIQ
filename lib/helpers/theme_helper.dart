import 'package:shared_preferences/shared_preferences.dart';

class ThemeHelper {
  static const _themeKey = 'theme_mode';

  static Future<void> saveTheme(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode);
  }

  static Future<String> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeKey) ?? 'dark';
  }
}
