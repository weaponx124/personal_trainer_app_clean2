import 'package:personal_trainer_app_clean/core/data/models/workout.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class WorkoutRepository {
  Future<List<Workout>> getWorkouts(String programId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final workoutData = prefs.getString('workouts_$programId') ?? '[]';
      final List<dynamic> workoutList = jsonDecode(workoutData);
      return workoutList.map((data) => Workout.fromMap(data)).toList();
    } catch (e) {
      print('Error loading workouts: $e');
      return [];
    }
  }

  Future<void> insertWorkout(String programId, Workout workout) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final workouts = await getWorkouts(programId);
      workouts.add(workout);
      await prefs.setString('workouts_$programId', jsonEncode(workouts.map((w) => w.toMap()).toList()));
      print('Inserted workout for program ID: $programId');
    } catch (e) {
      print('Error inserting workout: $e');
      throw Exception('Failed to insert workout: $e');
    }
  }

  Future<void> updateWorkout(String programId, Workout workout) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final workouts = await getWorkouts(programId);
      final index = workouts.indexWhere((w) => w.id == workout.id);
      if (index != -1) {
        workouts[index] = workout;
        await prefs.setString('workouts_$programId', jsonEncode(workouts.map((w) => w.toMap()).toList()));
        print('Updated workout for program ID: $programId');
      }
    } catch (e) {
      print('Error updating workout: $e');
      throw Exception('Failed to update workout: $e');
    }
  }

  // Modified to fetch workouts within a date range across all programs
  Future<List<Workout>> getWorkoutsForWeek(DateTime startDate, DateTime endDate) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final allKeys = prefs.getKeys();
      final workoutKeys = allKeys.where((key) => key.startsWith('workouts_')).toList();
      List<Workout> allWorkouts = [];

      for (var key in workoutKeys) {
        final workoutData = prefs.getString(key) ?? '[]';
        final List<dynamic> workoutList = jsonDecode(workoutData);
        final workouts = workoutList.map((data) => Workout.fromMap(data)).toList();
        allWorkouts.addAll(workouts);
      }

      // Filter workouts within the date range
      return allWorkouts.where((workout) {
        final workoutDate = DateTime.fromMillisecondsSinceEpoch(workout.timestamp);
        return workoutDate.isAfter(startDate) && workoutDate.isBefore(endDate);
      }).toList();
    } catch (e) {
      print('Error loading workouts for date range: $e');
      return [];
    }
  }
}