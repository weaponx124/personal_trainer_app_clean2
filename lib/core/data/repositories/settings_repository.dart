import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  static const String _weightUnitKey = 'weightUnit';
  static const String _themeModeKey = 'themeMode';
  static const String _fitnessGoalKey = 'fitness_goal';
  static const String _experienceLevelKey = 'experience_level';
  static const String _preferredWorkoutTypeKey = 'preferred_workout_type';

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

  // New methods for user preferences
  Future<String> getFitnessGoal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_fitnessGoalKey) ?? 'strength'; // Default to 'strength'
    } catch (e) {
      print('Error loading fitness goal: $e');
      return 'strength'; // Default value
    }
  }

  Future<void> setFitnessGoal(String goal) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_fitnessGoalKey, goal);
      print('Saved fitness goal: $goal');
    } catch (e) {
      print('Error saving fitness goal: $e');
      throw Exception('Failed to save fitness goal: $e');
    }
  }

  Future<String> getExperienceLevel() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_experienceLevelKey) ?? 'beginner'; // Default to 'beginner'
    } catch (e) {
      print('Error loading experience level: $e');
      return 'beginner'; // Default value
    }
  }

  Future<void> setExperienceLevel(String level) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_experienceLevelKey, level);
      print('Saved experience level: $level');
    } catch (e) {
      print('Error saving experience level: $e');
      throw Exception('Failed to save experience level: $e');
    }
  }

  Future<String> getPreferredWorkoutType() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_preferredWorkoutTypeKey) ?? 'strength'; // Default to 'strength'
    } catch (e) {
      print('Error loading preferred workout type: $e');
      return 'strength'; // Default value
    }
  }

  Future<void> setPreferredWorkoutType(String type) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_preferredWorkoutTypeKey, type);
      print('Saved preferred workout type: $type');
    } catch (e) {
      print('Error saving preferred workout type: $e');
      throw Exception('Failed to save preferred workout type: $e');
    }
  }
}