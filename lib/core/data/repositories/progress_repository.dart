import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'package:personal_trainer_app_clean/core/data/models/progress.dart';

class ProgressRepository {
  static const String _progressKey = 'progress';

  Future<List<Progress>> getProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressJson = prefs.getString(_progressKey);
      print('Progress JSON from SharedPreferences: $progressJson');
      if (progressJson == null) return [];
      final progressList = jsonDecode(progressJson) as List<dynamic>;
      final progress = progressList.map((progress) => Progress.fromMap(progress as Map<String, dynamic>)).toList();
      print('Loaded progress: ${progress.map((p) => p.toMap()).toList()}');
      return progress;
    } catch (e, stackTrace) {
      print('Error loading progress: $e');
      print('Stack trace: $stackTrace');
      await clearProgress();
      return [];
    }
  }

  Future<void> insertProgress(Progress progress) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressList = await getProgress();
      final progressWithId = Progress(
        id: Uuid().v4(),
        date: progress.date,
        weight: progress.weight,
        bodyFat: progress.bodyFat,
        measurements: progress.measurements,
      );
      progressList.add(progressWithId);
      print('Inserting progress: ${progressWithId.toMap()}');
      await prefs.setString(_progressKey, jsonEncode(progressList.map((p) => p.toMap()).toList()));
      print('Saved progress to SharedPreferences: ${prefs.getString(_progressKey)}');
    } catch (e, stackTrace) {
      print('Error inserting progress: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to insert progress: $e');
    }
  }

  Future<void> updateProgress(Progress updatedProgress) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressList = await getProgress();
      final index = progressList.indexWhere((p) => p.id == updatedProgress.id);
      if (index != -1) {
        progressList[index] = updatedProgress;
        print('Updating progress: ${updatedProgress.toMap()}');
        await prefs.setString(_progressKey, jsonEncode(progressList.map((p) => p.toMap()).toList()));
        print('Saved progress to SharedPreferences: ${prefs.getString(_progressKey)}');
      } else {
        throw Exception('Progress with ID ${updatedProgress.id} not found');
      }
    } catch (e, stackTrace) {
      print('Error updating progress: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to update progress: $e');
    }
  }

  Future<void> deleteProgress(String progressId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressList = await getProgress();
      progressList.removeWhere((p) => p.id == progressId);
      print('Deleting progress with ID: $progressId');
      await prefs.setString(_progressKey, jsonEncode(progressList.map((p) => p.toMap()).toList()));
      print('Saved progress to SharedPreferences: ${prefs.getString(_progressKey)}');
    } catch (e, stackTrace) {
      print('Error deleting progress: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to delete progress: $e');
    }
  }

  Future<void> clearProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_progressKey);
    print('Cleared all progress from SharedPreferences');
  }
}