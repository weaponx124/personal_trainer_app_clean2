import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class VerseOfTheDayRepository {
  static const String _verseOfTheDayKey = 'verseOfTheDay';
  static const String _weeklyWorkoutGoalKey = 'weeklyWorkoutGoal';
  static const String _celebratedMilestoneKey = 'celebratedMilestone';

  Future<Map<String, dynamic>?> getVerseOfTheDay() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final verseJson = prefs.getString(_verseOfTheDayKey);
      if (verseJson == null) return null;
      return jsonDecode(verseJson) as Map<String, dynamic>;
    } catch (e, stackTrace) {
      print('Error loading verse of the day: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  Future<void> setVerseOfTheDay(Map<String, dynamic> verse) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_verseOfTheDayKey, jsonEncode(verse));
      print('Saved verse of the day: $verse');
    } catch (e, stackTrace) {
      print('Error saving verse of the day: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to save verse of the day: $e');
    }
  }

  Future<int> getWeeklyWorkoutGoal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_weeklyWorkoutGoalKey) ?? 3; // Default to 3 if not set
    } catch (e, stackTrace) {
      print('Error loading weekly workout goal: $e');
      print('Stack trace: $stackTrace');
      return 3; // Default value
    }
  }

  Future<void> setWeeklyWorkoutGoal(int goal) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_weeklyWorkoutGoalKey, goal);
      print('Saved weekly workout goal: $goal');
    } catch (e, stackTrace) {
      print('Error saving weekly workout goal: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to save weekly workout goal: $e');
    }
  }

  Future<bool> hasCelebratedMilestoneThisWeek(DateTime startOfWeek) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final celebratedJson = prefs.getString(_celebratedMilestoneKey);
      if (celebratedJson == null) return false;
      final celebratedData = jsonDecode(celebratedJson) as Map<String, dynamic>;
      final celebratedDate = DateTime.parse(celebratedData['date'] as String);
      final celebrated = celebratedData['celebrated'] as bool;
      // Check if the celebration was for the same week
      return celebrated &&
          celebratedDate.year == startOfWeek.year &&
          celebratedDate.month == startOfWeek.month &&
          celebratedDate.day == startOfWeek.day;
    } catch (e, stackTrace) {
      print('Error checking milestone celebration: $e');
      print('Stack trace: $stackTrace');
      return false;
    }
  }

  Future<void> setCelebratedMilestoneThisWeek(DateTime startOfWeek, bool celebrated) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = {
        'date': startOfWeek.toIso8601String(),
        'celebrated': celebrated,
      };
      await prefs.setString(_celebratedMilestoneKey, jsonEncode(data));
      print('Saved milestone celebration: $data');
    } catch (e, stackTrace) {
      print('Error saving milestone celebration: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to save milestone celebration: $e');
    }
  }
}