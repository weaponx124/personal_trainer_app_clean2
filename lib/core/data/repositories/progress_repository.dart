import 'package:personal_trainer_app_clean/core/data/models/progress.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ProgressRepository {
  Future<List<Progress>> getProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressData = prefs.getString('progress') ?? '[]';
      final List<dynamic> progressList = jsonDecode(progressData);
      return progressList.map((data) => Progress.fromMap(data)).toList();
    } catch (e) {
      print('Error loading progress: $e');
      return [];
    }
  }

  Future<void> insertProgress(Progress progress) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressList = await getProgress();
      progressList.add(progress);
      await prefs.setString('progress', jsonEncode(progressList.map((p) => p.toMap()).toList()));
      print('Inserted progress: ${progress.weight}');
    } catch (e) {
      print('Error inserting progress: $e');
      throw Exception('Failed to insert progress: $e');
    }
  }

  Future<void> deleteProgress(String progressId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressList = await getProgress();
      final updatedProgress = progressList.where((p) => p.id != progressId).toList();
      await prefs.setString('progress', jsonEncode(updatedProgress.map((p) => p.toMap()).toList()));
      print('Deleted progress with ID: $progressId');
    } catch (e) {
      print('Error deleting progress: $e');
      throw Exception('Failed to delete progress: $e');
    }
  }
}