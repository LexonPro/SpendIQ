import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import '../utils/export_excel_helper.dart';
import '../utils/export_pdf_helper.dart';
import '../utils/export_image_helper.dart';
import '../database/db_helper.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // ================= INFO PAGE =================

  void _openInfoPage(String title, String content) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text(title)),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Text(
                content,
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ================= PIN DIALOG =================

  Future<String?> _askPinDialog() async {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Set 4-digit PIN"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          maxLength: 4,
          obscureText: true,
          decoration: const InputDecoration(counterText: ""),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.length == 4) {
                Navigator.pop(context, controller.text);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // ================= STATE =================

  String _userName = "User";
  bool _darkMode = true;
  bool _appLock = false;
  String? _imagePath;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  // ================= PREFS =================

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _userName = prefs.getString('user_name') ?? "User";
      _darkMode = prefs.getBool('dark_mode') ?? true;
      _appLock = prefs.getBool('app_lock') ?? false;
      _imagePath = prefs.getString('profile_image');
    });
  }

  Future<void> _saveName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    setState(() => _userName = name);
  }

  // ================= PROFILE IMAGE =================

  Future<void> _pickImage() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image', file.path);

    setState(() => _imagePath = file.path);
  }

  // ================= DARK MODE =================

  Future<void> _toggleDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', value);

    setState(() => _darkMode = value);
    SpendIQApp.themeNotifier.value = value;
  }

  // ================= APP LOCK =================

  Future<void> _toggleAppLock(bool value) async {
    final prefs = await SharedPreferences.getInstance();

    if (value) {
      final pin = await _askPinDialog();

      if (pin == null || pin.length != 4) {
        setState(() => _appLock = false);
        return;
      }

      await prefs.setBool('app_lock', true);
      await prefs.setString('app_pin', pin);
      setState(() => _appLock = true);
    } else {
      await prefs.setBool('app_lock', false);
      await prefs.remove('app_pin');
      setState(() => _appLock = false);
    }
  }

  // ================= EDIT NAME =================

  Future<void> _editNameDialog() async {
    final controller = TextEditingController(text: _userName);

    final name = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Your Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Enter name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (name != null && name.isNotEmpty) {
      await _saveName(name);
    }
  }

  // ================= EXPORT SNACKBAR =================

  void _showExportSnackBar(BuildContext context, String path) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 4),
        content: const Text('File exported successfully'),
        action: SnackBarAction(
          label: 'OPEN',
          onPressed: () => OpenFilex.open(path),
        ),
      ),
    );
  }

  // ================= EXPORT =================

  Future<void> _exportExcel(BuildContext context) async {
  final path = await ExportExcelHelper.exportExcel();

  if (path == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Excel export failed')),
    );
    return;
  }

  _showExportSnackBar(context, path);
}


  Future<void> _exportPDF(BuildContext context) async {
    final path = await ExportPdfHelper.exportPDF();
    _showExportSnackBar(context, path);
  }

  Future<void> _exportImage(BuildContext context) async {
    final path = await ExportImageHelper.exportImage();
    _showExportSnackBar(context, path);
  }

  // ================= CLEAR DATA =================

  Future<void> _clearAllData(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all expenses.\n\nAre you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DBHelper.instance.clearAllExpenses();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All expenses deleted')),
      );
    }
  }

  // ================= UI HELPERS =================

  Widget _profileHeader() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: GestureDetector(
          onTap: _pickImage,
          child: CircleAvatar(
            radius: 28,
            backgroundImage:
                _imagePath != null ? FileImage(File(_imagePath!)) : null,
            child: _imagePath == null
                ? Text(
                    _userName.isNotEmpty ? _userName[0].toUpperCase() : "U",
                    style: const TextStyle(fontSize: 20),
                  )
                : null,
          ),
        ),
        title: Text(
          _userName,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: const Text("Edit profile"),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: _editNameDialog,
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          _profileHeader(),

          _sectionTitle("Appearance"),
          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.dark_mode),
              title: const Text("Dark Mode"),
              value: _darkMode,
              onChanged: _toggleDarkMode,
            ),
          ),
          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.lock),
              title: const Text("App Lock"),
              value: _appLock,
              onChanged: _toggleAppLock,
            ),
          ),

          _sectionTitle("Export"),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.grid_on),
                  title: const Text("Export as Excel"),
                  onTap: () => _exportExcel(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.picture_as_pdf),
                  title: const Text("Export as PDF"),
                  onTap: () => _exportPDF(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.image),
                  title: const Text("Export as Image"),
                  onTap: () => _exportImage(context),
                ),
              ],
            ),
          ),

          _sectionTitle("Legal & Info"),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text("Privacy Policy"),
                  onTap: () => _openInfoPage(
                    "Privacy Policy",
                    "SpendIQ does not collect, store, or share any personal data.\n\n"
                    "All expense and income information remains securely on your device.\n\n"
                    "We respect your privacy and ensure full offline data protection.",
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text("Terms & Conditions"),
                  onTap: () => _openInfoPage(
                    "Terms & Conditions",
                    "SpendIQ is provided for personal finance tracking purposes only.\n\n"
                    "The developer is not responsible for financial decisions made using this app.\n\n"
                    "By using SpendIQ, you agree to use it responsibly.",
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text("About SpendIQ"),
                  onTap: () => _openInfoPage(
                    "About SpendIQ",
                    "SpendIQ\nVersion 1.0.0\n\n"
                    "A smart and simple expense tracker designed to help you manage "
                    "income, spending, and monthly budget with ease.",
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Card(
            child: ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text(
                "Clear All Data",
                style: TextStyle(color: Colors.red),
              ),
              onTap: () => _clearAllData(context),
            ),
          ),
        ],
      ),
    );
  }
}
