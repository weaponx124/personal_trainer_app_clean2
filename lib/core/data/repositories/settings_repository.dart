import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SettingsRepository {
  static const String _weightUnitKey = 'weightUnit';
  static const String _themeModeKey = 'themeMode';
  static const String _fitnessGoalKey = 'fitness_goal';
  static const String _experienceLevelKey = 'experience_level';
  static const String _preferredWorkoutTypeKey = 'preferred_workout_type';
  static const String _mealReminderEnabledKey = 'mealReminderEnabled';
  static const String _waterReminderEnabledKey = 'waterReminderEnabled';
  static const String _workoutReminderEnabledKey = 'workoutReminderEnabled';
  static const String _mealReminderTimesKey = 'mealReminderTimes';
  static const String _waterReminderTimeKey = 'waterReminderTime';
  static const String _workoutReminderTimeKey = 'workoutReminderTime';

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

  Future<bool> getMealReminderEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_mealReminderEnabledKey) ?? false;
    } catch (e) {
      print('Error loading meal reminder enabled: $e');
      return false;
    }
  }

  Future<void> setMealReminderEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_mealReminderEnabledKey, enabled);
      print('Saved meal reminder enabled: $enabled');
    } catch (e) {
      print('Error saving meal reminder enabled: $e');
      throw Exception('Failed to save meal reminder enabled: $e');
    }
  }

  Future<bool> getWaterReminderEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_waterReminderEnabledKey) ?? false;
    } catch (e) {
      print('Error loading water reminder enabled: $e');
      return false;
    }
  }

  Future<void> setWaterReminderEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_waterReminderEnabledKey, enabled);
      print('Saved water reminder enabled: $enabled');
    } catch (e) {
      print('Error saving water reminder enabled: $e');
      throw Exception('Failed to save water reminder enabled: $e');
    }
  }

  Future<bool> getWorkoutReminderEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_workoutReminderEnabledKey) ?? false;
    } catch (e) {
      print('Error loading workout reminder enabled: $e');
      return false;
    }
  }

  Future<void> setWorkoutReminderEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_workoutReminderEnabledKey, enabled);
      print('Saved workout reminder enabled: $enabled');
    } catch (e) {
      print('Error saving workout reminder enabled: $e');
      throw Exception('Failed to save workout reminder enabled: $e');
    }
  }

  Future<Map<String, TimeOfDay>> getMealReminderTimes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timesString = prefs.getString(_mealReminderTimesKey);
      if (timesString == null) {
        // Default meal times
        return {
          'Breakfast': const TimeOfDay(hour: 8, minute: 0),
          'Lunch': const TimeOfDay(hour: 12, minute: 0),
          'Dinner': const TimeOfDay(hour: 18, minute: 0),
          'Snack': const TimeOfDay(hour: 15, minute: 0),
        };
      }
      final timesMap = jsonDecode(timesString) as Map<String, dynamic>;
      return timesMap.map((key, value) {
        final parts = (value as String).split(':');
        return MapEntry(key, TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1])));
      });
    } catch (e) {
      print('Error loading meal reminder times: $e');
      return {
        'Breakfast': const TimeOfDay(hour: 8, minute: 0),
        'Lunch': const TimeOfDay(hour: 12, minute: 0),
        'Dinner': const TimeOfDay(hour: 18, minute: 0),
        'Snack': const TimeOfDay(hour: 15, minute: 0),
      };
    }
  }

  Future<void> setMealReminderTimes(Map<String, TimeOfDay> times) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timesMap = times.map((key, time) => MapEntry(key, '${time.hour}:${time.minute}'));
      await prefs.setString(_mealReminderTimesKey, jsonEncode(timesMap));
      print('Saved meal reminder times: $timesMap');
    } catch (e) {
      print('Error saving meal reminder times: $e');
      throw Exception('Failed to save meal reminder times: $e');
    }
  }

  Future<TimeOfDay> getWaterReminderTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timeString = prefs.getString(_waterReminderTimeKey) ?? '10:00'; // Default to 10:00 AM
      final parts = timeString.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (e) {
      print('Error loading water reminder time: $e');
      return const TimeOfDay(hour: 10, minute: 0);
    }
  }

  Future<void> setWaterReminderTime(TimeOfDay time) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timeString = '${time.hour}:${time.minute}';
      await prefs.setString(_waterReminderTimeKey, timeString);
      print('Saved water reminder time: $timeString');
    } catch (e) {
      print('Error saving water reminder time: $e');
      throw Exception('Failed to save water reminder time: $e');
    }
  }

  Future<TimeOfDay> getWorkoutReminderTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timeString = prefs.getString(_workoutReminderTimeKey) ?? '18:00'; // Default to 6:00 PM
      final parts = timeString.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (e) {
      print('Error loading workout reminder time: $e');
      return const TimeOfDay(hour: 18, minute: 0);
    }
  }

  Future<void> setWorkoutReminderTime(TimeOfDay time) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timeString = '${time.hour}:${time.minute}';
      await prefs.setString(_workoutReminderTimeKey, timeString);
      print('Saved workout reminder time: $timeString');
    } catch (e) {
      print('Error saving workout reminder time: $e');
      throw Exception('Failed to save workout reminder time: $e');
    }
  }
}