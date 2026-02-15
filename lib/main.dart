import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';

import 'screens/home_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/settings_screen.dart';
import 'ui/app_styles.dart';

final GlobalKey<AnalyticsScreenState> analyticsKey =
    GlobalKey<AnalyticsScreenState>();

void main() {
  runApp(const SpendIQApp());
}

class SpendIQApp extends StatefulWidget {
  const SpendIQApp({super.key});

  static final ValueNotifier<bool> themeNotifier = ValueNotifier(true);

  @override
  State<SpendIQApp> createState() => _SpendIQAppState();
}

class _SpendIQAppState extends State<SpendIQApp> {
  int index = 0;

  final LocalAuthentication _auth = LocalAuthentication();

  bool _checkingLock = true;
  bool _locked = false;
  String? _savedPin;

  List<Widget> get screens => [
        const HomeScreen(),
        AnalyticsScreen(key: analyticsKey),
        const SettingsScreen(),
      ];

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    final prefs = await SharedPreferences.getInstance();

    SpendIQApp.themeNotifier.value = prefs.getBool('dark_mode') ?? true;

    final appLock = prefs.getBool('app_lock') ?? false;
    _savedPin = prefs.getString('app_pin');

    if (appLock && _savedPin != null) {
      _locked = !(await _tryBiometric());
    }

    setState(() => _checkingLock = false);
  }

  Future<bool> _tryBiometric() async {
    try {
      if (!await _auth.canCheckBiometrics) return false;
      return await _auth.authenticate(
        localizedReason: 'Unlock SpendIQ',
        biometricOnly: true,
      );
    } catch (_) {
      return false;
    }
  }

  void _unlock(String pin) {
    if (pin == _savedPin) setState(() => _locked = false);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: SpendIQApp.themeNotifier,
      builder: (_, isDark, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: isDark ? Brightness.dark : Brightness.light,
            scaffoldBackgroundColor:
                isDark ? AppColors.background : Colors.white,
          ),
          home: _checkingLock
              ? const Scaffold(body: Center(child: CircularProgressIndicator()))
              : Stack(
                  children: [
                    Scaffold(
                      body: SafeArea(
                        child: IndexedStack(index: index, children: screens),
                      ),
                      bottomNavigationBar: BottomNavigationBar(
                        currentIndex: index,
                        onTap: (i) {
                          setState(() => index = i);
                          if (i == 1) analyticsKey.currentState?.refresh();
                        },
                        items: const [
                          BottomNavigationBarItem(
                              icon: Icon(Icons.home), label: 'Home'),
                          BottomNavigationBarItem(
                              icon: Icon(Icons.bar_chart), label: 'Analytics'),
                          BottomNavigationBarItem(
                              icon: Icon(Icons.settings), label: 'Settings'),
                        ],
                      ),
                    ),
                    if (_locked)
                      _PinLockScreen(onUnlock: _unlock, savedPin: _savedPin),
                  ],
                ),
        );
      },
    );
  }
}

class _PinLockScreen extends StatelessWidget {
  final void Function(String) onUnlock;
  final String? savedPin;

  const _PinLockScreen({required this.onUnlock, required this.savedPin});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.85),
      body: Center(
        child: ElevatedButton(
          onPressed: () => onUnlock(controller.text),
          child: const Text("Unlock"),
        ),
      ),
    );
  }
}
