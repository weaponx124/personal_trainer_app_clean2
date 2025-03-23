import 'package:personal_trainer_app_clean/core/data/models/workout.dart';
import 'package:personal_trainer_app_clean/core/data/repositories/workout_repository.dart';

class ProgramLogic {
  final Map<String, dynamic> program;

  ProgramLogic(this.program);

  List<Map<String, dynamic>> getWorkoutsForCurrentDay() {
    final currentWeek = program['currentWeek'] as int;
    final currentDay = program['currentDay'] as int;
    final workouts = program['workouts'] as List<Map<String, dynamic>>? ?? [];

    return workouts.where((workout) {
      final week = workout['week'] as int;
      final day = workout['day'] as int;
      return week == currentWeek && day == currentDay;
    }).toList();
  }

  Future<void> logWorkout(String programId, Map<String, dynamic> workoutData) async {
    final workoutRepository = WorkoutRepository();
    final exercises = workoutData['exercises'] as List<Map<String, dynamic>>;
    final completed = workoutData['completed'] as bool;

    final workout = Workout(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      programId: programId,
      name: 'Workout on ${DateTime.now().toIso8601String()}',
      exercises: exercises,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );

    if (completed) {
      await workoutRepository.insertWorkout(programId, workout);
    }
  }

  static Map<String, dynamic> calculateMadcow(Map<String, dynamic> program, int week, int session) {
    final details = program['details'] as Map<String, dynamic>;
    final oneRMs = program['oneRMs'] as Map<String, dynamic>;
    final exercises = <Map<String, dynamic>>[];

    // Simplified Madcow calculation for demonstration
    final squatWeight = (oneRMs['Squat'] ?? 0.0) * 0.9 * (week / 4);
    final benchWeight = (oneRMs['Bench'] ?? 0.0) * 0.9 * (week / 4);

    if (session == 1) {
      exercises.add({
        'name': 'Squat',
        'sets': 5,
        'reps': 5,
        'weight': squatWeight,
      });
      exercises.add({
        'name': 'Bench',
        'sets': 5,
        'reps': 5,
        'weight': benchWeight,
      });
    }

    return {
      'week': week,
      'session': session,
      'workoutName': 'Madcow Day $session',
      'exercises': exercises,
    };
  }

  static Map<String, dynamic> calculate531(Map<String, dynamic> oneRMs, int week, String lift) {
    final trainingMax = (oneRMs[lift] ?? 0.0) * 0.9;
    final sets = <Map<String, dynamic>>[];

    if (week == 1) {
      sets.add({'reps': 3, 'weight': trainingMax * 0.65});
      sets.add({'reps': 3, 'weight': trainingMax * 0.75});
      sets.add({'reps': 3, 'weight': trainingMax * 0.85});
    } else if (week == 2) {
      sets.add({'reps': 3, 'weight': trainingMax * 0.70});
      sets.add({'reps': 3, 'weight': trainingMax * 0.80});
      sets.add({'reps': 3, 'weight': trainingMax * 0.90});
    } else if (week == 3) {
      sets.add({'reps': 3, 'weight': trainingMax * 0.75});
      sets.add({'reps': 3, 'weight': trainingMax * 0.85});
      sets.add({'reps': 3, 'weight': trainingMax * 0.95});
    }

    return {
      'sets': sets,
    };
  }
}