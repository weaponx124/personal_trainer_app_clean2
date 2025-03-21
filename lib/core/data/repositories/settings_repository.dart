import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  static const String _weightUnitKey = 'weightUnit';
  static const String _themeModeKey = 'themeMode';

  Future<String> getWeightUnit() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_weightUnitKey) ?? 'lbs'; // Default to 'lbs'
    } catch (e) {
      print('Error loading weight unit: $e');
      return 'lbs'; // Default value
    }
  }

  Future<void> setWeightUnit(String unit) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_weightUnitKey, unit);
      print('Saved weight unit: $unit');
    } catch (e) {
      print('Error saving weight unit: $e');
      throw Exception('Failed to save weight unit: $e');
    }
  }

  Future<ThemeMode> getThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeModeString = prefs.getString(_themeModeKey);
      switch (themeModeString) {
        case 'light':
          return ThemeMode.light;
        case 'dark':
          return ThemeMode.dark;
        default:
          return ThemeMode.system;
      }
    } catch (e) {
      print('Error loading theme mode: $e');
      return ThemeMode.system; // Default value
    }
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String themeModeString;
      switch (themeMode) {
        case ThemeMode.light:
          themeModeString = 'light';
          break;
        case ThemeMode.dark:
          themeModeString = 'dark';
          break;
        default:
          themeModeString = 'system';
      }
      await prefs.setString(_themeModeKey, themeModeString);
      print('Saved theme mode: $themeModeString');
    } catch (e) {
      print('Error saving theme mode: $e');
      throw Exception('Failed to save theme mode: $e');
    }
  }
}