import 'package:personal_trainer_app_clean/core/data/models/workout.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
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
      final workoutWithId = Workout(
        id: Uuid().v4(),
        programId: programId,
        name: workout.name,
        exercises: workout.exercises,
        timestamp: DateTime.now().millisecondsSinceEpoch, // Added timestamp
      );
      workouts.add(workoutWithId);
      await prefs.setString('workouts_$programId', jsonEncode(workouts.map((w) => w.toMap()).toList()));
      print('Inserted workout: ${workoutWithId.name}');
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
        print('Updated workout: ${workout.name}');
      }
    } catch (e) {
      print('Error updating workout: $e');
      throw Exception('Failed to update workout: $e');
    }
  }
}