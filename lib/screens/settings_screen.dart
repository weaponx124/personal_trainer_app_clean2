import 'package:flutter/material.dart';
import 'package:personal_trainer_app_clean/database_helper.dart';
import 'package:personal_trainer_app_clean/main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String unit = 'lbs';
  String themeMode = 'System'; // Default to system

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final loadedUnit = await DatabaseHelper.getWeightUnit();
    final loadedThemeMode = await DatabaseHelper.getThemeMode();
    setState(() {
      unit = loadedUnit;
      themeMode = _themeModeToString(loadedThemeMode);
    });
  }

  Future<void> _setUnit(String newUnit) async {
    final oldUnit = unit;
    setState(() => unit = newUnit);
    await DatabaseHelper.setWeightUnit(newUnit, currentUnit: oldUnit);
    unitNotifier.value = newUnit;
    Navigator.pop(context);
  }

  Future<void> _setThemeMode(String newThemeMode) async {
    setState(() => themeMode = newThemeMode);
    final mode = _stringToThemeMode(newThemeMode);
    await DatabaseHelper.setThemeMode(mode);
    themeNotifier.value = mode;
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
      default:
        return 'System';
    }
  }

  ThemeMode _stringToThemeMode(String mode) {
    switch (mode) {
      case 'Light':
        return ThemeMode.light;
      case 'Dark':
        return ThemeMode.dark;
      case 'System':
      default:
        return ThemeMode.system;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weight Unit',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: unit,
              items: <String>['lbs', 'kg'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  _setUnit(newValue);
                }
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Theme Mode',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: themeMode,
              items: <String>['System', 'Light', 'Dark'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  _setThemeMode(newValue);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}