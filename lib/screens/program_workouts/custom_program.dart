import '../program_logic.dart';

class CustomProgramWorkout {
  static Map<String, dynamic> generate(Map<String, dynamic> programDetails, int currentWeek, int currentSession) {
    final unit = programDetails['details']?['unit'] as String? ?? 'lbs';
    final details = programDetails['details'] as Map<String, dynamic>? ?? {};
    final movement = details['movement'] as String? ?? 'Squat';
    final sets = details['sets'] as int? ?? 5;
    final reps = details['reps'] as int? ?? 5;
    final percentages = (details['percentages'] as List<dynamic>?)?.cast<double>() ?? [65.0, 70.0, 75.0, 80.0, 85.0];
    final increment = (details['increment'] as num?)?.toDouble() ?? 2.5;
    final isPercentageBased = details['isPercentageBased'] as bool? ?? true;
    final oneRM = (details['1RM'] as num?)?.toDouble() ?? 100.0;

    // Adjust 1RM based on increment per session
    final adjusted1RM = oneRM + (increment * (currentSession - 1));

    final List<Map<String, dynamic>> exercises = [];
    if (isPercentageBased) {
      for (int i = 0; i < sets; i++) {
        final percentage = percentages[i % percentages.length];
        exercises.add({
          'name': movement,
          'sets': 1,
          'reps': reps,
          'weight': ProgramLogic.calculateWorkingWeight(adjusted1RM, percentage, unit: unit),
        });
      }
    } else {
      exercises.add({
        'name': movement,
        'sets': sets,
        'reps': reps,
        'weight': 0.0, // User-defined weight
      });
    }

    return {
      'week': currentWeek,
      'session': currentSession,
      'workoutName': 'Custom Workout',
      'exercises': exercises,
      'unit': unit,
    };
  }
}