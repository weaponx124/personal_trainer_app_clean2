import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:personal_trainer_app_clean/core/data/models/workout.dart';

class WorkoutRepository {
  Future<List<Workout>> getWorkouts(String programId) async {
    final prefs = await SharedPreferences.getInstance();
    final workoutsJson = prefs.getString('workouts_$programId');
    if (workoutsJson == null) {
      return [];
    }
    final List<dynamic> workoutsList = jsonDecode(workoutsJson);
    return workoutsList.map((json) => Workout.fromMap(json)).toList();
  }

  Future<void> insertWorkout(String programId, Workout workout) async {
    final workouts = await getWorkouts(programId);
    workouts.add(workout);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('workouts_$programId', jsonEncode(workouts.map((e) => e.toMap()).toList()));
  }

  Future<void> updateWorkout(String programId, Workout updatedWorkout) async {
    final workouts = await getWorkouts(programId);
    final index = workouts.indexWhere((workout) => workout.id == updatedWorkout.id);
    if (index != -1) {
      workouts[index] = updatedWorkout;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('workouts_$programId', jsonEncode(workouts.map((e) => e.toMap()).toList()));
    } else {
      throw Exception('Workout with ID ${updatedWorkout.id} not found for program $programId');
    }
  }

  Future<List<Workout>> getWorkoutsForWeek(DateTime startOfWeek, DateTime endOfWeek) async {
    final allWorkouts = <Workout>[];
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => key.startsWith('workouts_')).toList();

    for (var key in keys) {
      final programId = key.replaceFirst('workouts_', '');
      final workouts = await getWorkouts(programId);
      allWorkouts.addAll(workouts.where((workout) {
        final workoutDate = DateTime.fromMillisecondsSinceEpoch(workout.timestamp);
        return workoutDate.isAfter(startOfWeek) && workoutDate.isBefore(endOfWeek);
      }));
    }

    return allWorkouts;
  }

  Future<void> clearWorkouts(String programId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('workouts_$programId');
  }

  Future<List<String>> getAllProgramIds() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => key.startsWith('workouts_')).toList();
    return keys.map((key) => key.replaceFirst('workouts_', '')).toList();
  }
}