import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecurityHelper {
  static const _pinKey = 'app_pin';
  static const _lockEnabledKey = 'lock_enabled';
  static const _bioEnabledKey = 'bio_enabled';

  /// Save PIN
  static Future<void> savePin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pinKey, pin);
  }

  /// Get PIN
  static Future<String?> getPin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_pinKey);
  }

  /// Enable/Disable lock
  static Future<void> setLockEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_lockEnabledKey, value);
  }

  static Future<bool> isLockEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_lockEnabledKey) ?? false;
  }

  /// Enable/Disable biometric
  static Future<void> setBiometricEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_bioEnabledKey, value);
  }

  static Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_bioEnabledKey) ?? false;
  }

  /// Authenticate with fingerprint/face (OLD local_auth compatible)
  static Future<bool> authenticateBiometric() async {
    final auth = LocalAuthentication();

    try {
      return await auth.authenticate(
        localizedReason: 'Unlock SpendIQ',
        biometricOnly: true,
      );
    } catch (_) {
      return false;
    }
  }
}
