import '../program_logic.dart';

class RussianSquatWorkout {
  static Map<String, dynamic> generate(Map<String, dynamic> programDetails, int currentWeek, int currentSession) {
    final unit = programDetails['details']?['unit'] as String? ?? 'lbs';
    final details = programDetails['details'] as Map<String, dynamic>? ?? {};
    final oneRMRaw = details['1RM'] as num?;
    final oneRM = oneRMRaw?.toDouble() ?? 100.0;
    final original1RMRaw = details['original1RM'] as num?;
    final original1RM = original1RMRaw?.toDouble() ?? oneRM;
    final oneRMIncrement = (details['oneRMIncrement'] as num?)?.toDouble() ?? (unit == 'kg' ? 2.5 : 5.0);

    // Adjust 1RM based on weeks (increase at the end of the cycle)
    final adjusted1RM = oneRM + (oneRMIncrement * ((currentWeek - 1) ~/ 6));

    // Adjust sessionType to map currentSession 1 to Session 1 (sessionType 0)
    final sessionType = (currentSession - 1) % 3; // Subtract 1 to align Session 1 with sessionType 0

    final List<Map<String, dynamic>> exercises = [];
    double percentage;
    int sets = 6;
    int reps;

    if (currentWeek <= 3) {
      percentage = 80;
      if (currentWeek == 1) {
        reps = sessionType == 0 ? 2 : (sessionType == 1 ? 3 : 2);
      } else if (currentWeek == 2) {
        reps = sessionType == 0 ? 4 : (sessionType == 1 ? 2 : 5);
      } else {
        reps = sessionType == 0 ? 3 : (sessionType == 1 ? 6 : 2);
      }
    } else {
      percentage = 85;
      if (currentWeek == 4) {
        reps = sessionType == 0 ? 4 : (sessionType == 1 ? 3 : 5);
      } else if (currentWeek == 5) {
        reps = sessionType == 0 ? 2 : (sessionType == 1 ? 4 : 6);
      } else {
        if (sessionType == 2) {
          // Test max on the last session of Week 6
          sets = 1;
          reps = 1;
          percentage = 100;
        } else {
          reps = sessionType == 0 ? 3 : 2;
        }
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
      'workoutName': sessionType == 2 && currentWeek == 6 ? 'Test Max' : 'Squat Session ${sessionType + 1}',
      'exercises': exercises,
      'unit': unit,
    };
  }
}