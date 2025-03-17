import '../program_logic.dart';

class SmolovBaseCycleWorkout {
  static Map<String, dynamic> generate(Map<String, dynamic> programDetails, int currentWeek, int currentSession) {
    final unit = programDetails['details']?['unit'] as String? ?? 'lbs';
    final details = programDetails['details'] as Map<String, dynamic>? ?? {};
    final oneRMRaw = details['1RM'] as num?;
    final oneRM = oneRMRaw?.toDouble() ?? 100.0;
    final original1RMRaw = details['original1RM'] as num?;
    final original1RM = original1RMRaw?.toDouble() ?? oneRM;
    final oneRMIncrement = (details['oneRMIncrement'] as num?)?.toDouble() ?? (unit == 'kg' ? 2.5 : 5.0);

    // Adjust 1RM based on weeks
    double adjusted1RM = oneRM;
    if (currentWeek == 2) {
      adjusted1RM += oneRMIncrement;
    } else if (currentWeek >= 3) {
      adjusted1RM += oneRMIncrement * 2;
    }

    // Adjust sessionType to map currentSession 1 to Session 1 (sessionType 0)
    final sessionType = (currentSession - 1) % 4; // Subtract 1 to align Session 1 with sessionType 0

    final List<Map<String, dynamic>> exercises = [];
    int sets;
    int reps;
    double percentage;

    if (sessionType == 0) {
      sets = 4;
      reps = 9;
      percentage = 70;
    } else if (sessionType == 1) {
      sets = 5;
      reps = 7;
      percentage = 75;
    } else if (sessionType == 2) {
      sets = 7;
      reps = 5;
      percentage = 80;
    } else {
      if (currentWeek == 4) {
        // Test max on the last session of Week 4
        sets = 1;
        reps = 1;
        percentage = 100;
      } else {
        sets = 10;
        reps = 3;
        percentage = 85;
      }
    }

    exercises.add({
      'name': 'Squat',
      'sets': sets,
      'reps': reps,
      'weight': ProgramLogic.calculateWorkingWeight(adjusted1RM, percentage, unit: unit),
    });

    return {
      'week': currentWeek,
      'session': currentSession,
      'workoutName': sessionType == 3 && currentWeek == 4 ? 'Test Max' : 'Squat Session ${sessionType + 1}',
      'exercises': exercises,
      'unit': unit,
    };
  }
}