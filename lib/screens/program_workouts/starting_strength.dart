import '../program_logic.dart';

class StartingStrengthWorkout {
  static Map<String, dynamic> generate(Map<String, dynamic> programDetails, int currentWeek, int currentSession) {
    final unit = programDetails['details']?['unit'] as String? ?? 'lbs';
    final increment = unit == 'kg' ? 2.5 : 5.0;
    final details = programDetails['details'] as Map<String, dynamic>? ?? {};
    final oneRMsRaw = details['1RMs'] as Map<String, dynamic>?;

    // Debug: Log the raw 1RMs before conversion
    print('Starting Strength - Raw 1RMs from programDetails[\'details\']: $oneRMsRaw');

    final oneRMs = oneRMsRaw != null
        ? <String, double>{
      'Squat': (oneRMsRaw['Squat'] as num?)?.toDouble() ?? 100.0,
      'Bench': (oneRMsRaw['Bench'] as num?)?.toDouble() ?? 100.0,
      'Overhead': (oneRMsRaw['Overhead'] as num?)?.toDouble() ?? 100.0,
      'Deadlift': (oneRMsRaw['Deadlift'] as num?)?.toDouble() ?? 100.0,
    }
        : <String, double>{
      'Squat': 100.0,
      'Bench': 100.0,
      'Overhead': 100.0,
      'Deadlift': 100.0,
    };
    final original1RMsRaw = details['original1RMs'] as Map<String, dynamic>?;
    final original1RMs = original1RMsRaw != null
        ? <String, double>{
      'Squat': (original1RMsRaw['Squat'] as num?)?.toDouble() ?? 100.0,
      'Bench': (original1RMsRaw['Bench'] as num?)?.toDouble() ?? 100.0,
      'Overhead': (original1RMsRaw['Overhead'] as num?)?.toDouble() ?? 100.0,
      'Deadlift': (original1RMsRaw['Deadlift'] as num?)?.toDouble() ?? 100.0,
    }
        : oneRMs;

    // Adjust 1RMs based on progression
    final adjusted1RMs = Map<String, double>.from(oneRMs);
    final sessionsCompleted = programDetails['sessionsCompleted'] as int? ?? 0;
    adjusted1RMs.updateAll((key, value) => value + (increment * sessionsCompleted));

    final bool isWorkoutA = currentSession % 2 == 1; // Alternates A, B, A, B...

    final List<Map<String, dynamic>> exercises = [];
    if (isWorkoutA) {
      // Workout A
      exercises.add({
        'name': 'Squat',
        'sets': 3,
        'reps': 5,
        'weight': ProgramLogic.calculateWorkingWeight(adjusted1RMs['Squat']!, 75, unit: unit), // 75% of 1RM
      });
      exercises.add({
        'name': 'Bench Press',
        'sets': 3,
        'reps': 5,
        'weight': ProgramLogic.calculateWorkingWeight(adjusted1RMs['Bench']!, 75, unit: unit),
      });
      exercises.add({
        'name': 'Deadlift',
        'sets': 1,
        'reps': 5,
        'weight': ProgramLogic.calculateWorkingWeight(adjusted1RMs['Deadlift']!, 75, unit: unit),
      });
    } else {
      // Workout B
      exercises.add({
        'name': 'Squat',
        'sets': 3,
        'reps': 5,
        'weight': ProgramLogic.calculateWorkingWeight(adjusted1RMs['Squat']!, 75, unit: unit),
      });
      exercises.add({
        'name': 'Overhead Press',
        'sets': 3,
        'reps': 5,
        'weight': ProgramLogic.calculateWorkingWeight(adjusted1RMs['Overhead']!, 75, unit: unit),
      });
      exercises.add({
        'name': 'Deadlift',
        'sets': 1,
        'reps': 5,
        'weight': ProgramLogic.calculateWorkingWeight(adjusted1RMs['Deadlift']!, 75, unit: unit),
      });
    }

    return {
      'week': currentWeek,
      'session': currentSession,
      'workoutName': isWorkoutA ? 'Workout A' : 'Workout B',
      'exercises': exercises,
      'unit': unit,
    };
  }
}