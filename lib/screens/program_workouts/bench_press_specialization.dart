import '../program_logic.dart';

class BenchPressSpecializationWorkout {
  static Map<String, dynamic> generate(Map<String, dynamic> programDetails, int currentWeek, int currentSession) {
    final unit = programDetails['details']?['unit'] as String? ?? 'lbs';
    final details = programDetails['details'] as Map<String, dynamic>? ?? {};
    final oneRMRaw = details['1RM'] as num?;
    final oneRM = oneRMRaw?.toDouble() ?? 100.0;
    final original1RMRaw = details['original1RM'] as num?;
    final original1RM = original1RMRaw?.toDouble() ?? oneRM;

    // Adjust 1RM based on weekly progression (increase by 2% per week)
    final adjusted1RM = oneRM * (1 + 0.02 * (currentWeek - 1));

    // Adjust sessionType to map currentSession 1 to Day 1 (sessionType 0)
    final sessionType = (currentSession - 1) % 3; // Subtract 1 to align Session 1 with Day 1

    final List<Map<String, dynamic>> exercises = [];
    if (sessionType == 0) {
      // Heavy Day
      exercises.add({
        'name': 'Bench Press',
        'sets': 3,
        'reps': 5,
        'weight': ProgramLogic.calculateWorkingWeight(adjusted1RM, 85, unit: unit),
      });
      exercises.add({
        'name': 'Incline Bench Press',
        'sets': 3,
        'reps': 8,
        'weight': ProgramLogic.calculateWorkingWeight(adjusted1RM, 60, unit: unit),
      });
      exercises.add({
        'name': 'Tricep Dips',
        'sets': 3,
        'reps': 5,
        'weight': 0.0,
      });
    } else if (sessionType == 1) {
      // Light Day
      exercises.add({
        'name': 'Bench Press',
        'sets': 3,
        'reps': 8,
        'weight': ProgramLogic.calculateWorkingWeight(adjusted1RM, 60, unit: unit),
      });
      exercises.add({
        'name': 'Dumbbell Press',
        'sets': 3,
        'reps': 10,
        'weight': ProgramLogic.calculateWorkingWeight(adjusted1RM, 50, unit: unit),
      });
      exercises.add({
        'name': 'Overhead Press',
        'sets': 3,
        'reps': 8,
        'weight': ProgramLogic.calculateWorkingWeight(adjusted1RM, 50, unit: unit),
      });
    } else {
      // Volume Day
      exercises.add({
        'name': 'Bench Press',
        'sets': 5,
        'reps': 5,
        'weight': ProgramLogic.calculateWorkingWeight(adjusted1RM, 75, unit: unit),
      });
      exercises.add({
        'name': 'Close-Grip Bench Press',
        'sets': 3,
        'reps': 8,
        'weight': ProgramLogic.calculateWorkingWeight(adjusted1RM, 65, unit: unit),
      });
      exercises.add({
        'name': 'Tricep Pushdowns',
        'sets': 3,
        'reps': 12,
        'weight': 0.0,
      });
    }

    return {
      'week': currentWeek,
      'session': currentSession,
      'workoutName': sessionType == 0 ? 'Heavy Bench' : (sessionType == 1 ? 'Light Bench' : 'Volume Bench'),
      'exercises': exercises,
      'unit': unit,
    };
  }
}