import 'package:personal_trainer_app_clean/core/data/models/workout.dart';
import 'package:personal_trainer_app_clean/core/services/database_service.dart';
import 'package:personal_trainer_app_clean/core/utils/locator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:personal_trainer_app_clean/core/data/repositories/program_repository.dart';

class WorkoutRepository {
  final DatabaseService _databaseService = getIt<DatabaseService>();

  Future<List<Workout>> getWorkouts(String programId) async {
    try {
      final workouts = await _databaseService.getWorkouts(programId);
      print('WorkoutRepository: Retrieved ${workouts.length} workouts for program $programId: ${workouts.map((w) => w.name).toList()}');
      return workouts;
    } catch (e) {
      print('Error loading workouts for program $programId: $e');
      return [];
    }
  }

  Future<void> insertWorkout(String programId, Workout workout) async {
    try {
      await _databaseService.insertWorkout(workout);
    } catch (e) {
      print('Error inserting workout: $e');
      throw Exception('Failed to insert workout: $e');
    }
  }

  Future<void> updateWorkout(String programId, Workout updatedWorkout) async {
    try {
      await _databaseService.updateWorkout(updatedWorkout);
    } catch (e) {
      print('Error updating workout: $e');
      throw Exception('Failed to update workout: $e');
    }
  }

  Future<List<Workout>> getWorkoutsForWeek(DateTime startOfWeek, DateTime endOfWeek) async {
    try {
      final allWorkouts = <Workout>[];
      final programIds = await getAllProgramIds();
      for (var programId in programIds) {
        final workouts = await getWorkouts(programId);
        allWorkouts.addAll(workouts.where((workout) {
          final workoutDate = DateTime.fromMillisecondsSinceEpoch(workout.timestamp);
          return workoutDate.isAfter(startOfWeek) && workoutDate.isBefore(endOfWeek);
        }));
      }
      return allWorkouts;
    } catch (e) {
      print('Error loading workouts for week: $e');
      return [];
    }
  }

  Future<void> clearWorkouts(String programId) async {
    try {
      await _databaseService.clearWorkouts(programId);
    } catch (e) {
      print('Error clearing workouts for program $programId: $e');
      throw Exception('Failed to clear workouts: $e');
    }
  }

  Future<List<String>> getAllProgramIds() async {
    try {
      final programs = await getIt<ProgramRepository>().getPrograms();
      final programIds = programs.map((program) => program.id).toList();
      print('WorkoutRepository: Retrieved program IDs: $programIds');
      return programIds;
    } catch (e) {
      print('Error getting program IDs: $e');
      return [];
    }
  }

  // Migrate existing data from SharedPreferences to SQLite (one-time operation)
  Future<void> migrateFromSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith('workouts_')).toList();

      // Get all program IDs from SQLite to verify existence
      final programIds = await getAllProgramIds();
      print('WorkoutRepository: Available program IDs in SQLite: $programIds');

      for (var key in keys) {
        final programId = key.replaceFirst('workouts_', '');
        print('WorkoutRepository: Processing workouts for program $programId');

        // Check if the programId exists in the programs table
        if (!programIds.contains(programId)) {
          print('WorkoutRepository: Skipping workouts for program $programId - program not found in SQLite');
          continue;
        }

        final workoutsJson = prefs.getString(key);
        if (workoutsJson != null) {
          final decodedData = jsonDecode(workoutsJson);
          if (decodedData is List<dynamic>) {
            final workouts = decodedData.map((json) => Workout.fromMap(json)).toList();
            for (var workout in workouts) {
              await insertWorkout(programId, workout);
            }
            print('WorkoutRepository: Migrated ${workouts.length} workouts for program $programId from SharedPreferences to SQLite.');
          }
        }
        // Clear SharedPreferences after migration
        await prefs.remove(key);
      }
    } catch (e) {
      print('Error migrating workouts from SharedPreferences: $e');
    }
  }
}