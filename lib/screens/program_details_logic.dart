import 'package:personal_trainer_app_clean/core/data/models/program.dart';
import 'package:personal_trainer_app_clean/core/data/models/workout.dart';
import 'package:personal_trainer_app_clean/core/data/repositories/program_repository.dart';
import 'package:personal_trainer_app_clean/core/data/repositories/workout_repository.dart';

class ProgramDetailsLogic {
  final ProgramRepository _programRepository = ProgramRepository();
  final WorkoutRepository _workoutRepository = WorkoutRepository();

  Future<Map<String, dynamic>> getCurrentWorkout(String programId, int week, int day) async {
    final workouts = await _workoutRepository.getWorkouts(programId);
    final program = await _programRepository.getPrograms();
    final currentProgram = program.firstWhere(
          (p) => p.id == programId,
      orElse: () => throw Exception('Program not found'),
    );

    final startDate = DateTime.parse(currentProgram.toMap()['startDate']);
    final currentDate = DateTime.now();
    final daysSinceStart = currentDate.difference(startDate).inDays;
    final currentWeek = (daysSinceStart / 7).floor() + 1;
    final currentDay = (daysSinceStart % 7) + 1;

    final workout = workouts.firstWhere(
          (w) => w.toMap()['week'] == week && w.toMap()['day'] == day,
      orElse: () => Workout(
        id: '',
        programId: programId,
        name: 'Workout not found',
        exercises: [],
        timestamp: DateTime.now().millisecondsSinceEpoch,
      ),
    );

    return {
      'workout': workout.toMap(),
      'currentWeek': currentWeek,
      'currentDay': currentDay,
    };
  }

  Future<void> logWorkout(String programId, Map<String, dynamic> workout) async {
    final workouts = await _workoutRepository.getWorkouts(programId);
    final existingIndex = workouts.indexWhere((w) => w.id == workout['id']);
    final updatedWorkout = Workout(
      id: workout['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      programId: programId,
      name: workout['name'] ?? 'Unnamed Workout',
      exercises: List<Map<String, dynamic>>.from(workout['exercises'] ?? []),
      timestamp: workout['timestamp'] != null
          ? int.parse(workout['timestamp'].toString())
          : DateTime.now().millisecondsSinceEpoch,
    );

    if (existingIndex != -1) {
      await _workoutRepository.updateWorkout(programId, updatedWorkout);
    } else {
      await _workoutRepository.insertWorkout(programId, updatedWorkout);
    }
  }

  // Added missing method
  Workout getTodayWorkout(Program program) {
    return Workout(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      programId: program.id,
      name: 'Today\'s Workout',
      exercises: [
        {
          'name': 'Squat',
          'sets': 3,
          'reps': 5,
          'weight': program.oneRMs['Squat'] ?? 0.0,
        },
        {
          'name': 'Bench',
          'sets': 3,
          'reps': 5,
          'weight': program.oneRMs['Bench'] ?? 0.0,
        },
      ],
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }
}