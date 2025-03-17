class PPLWorkout {
  static Map<String, dynamic> generate(Map<String, dynamic> programDetails, int currentWeek, int currentSession) {
    final unit = programDetails['details']?['unit'] as String? ?? 'lbs';

    // Adjust sessionType to map currentSession 1 to Day 1 (sessionType 0)
    final sessionType = (currentSession - 1) % 3; // Subtract 1 to align Session 1 with Day 1

    final List<Map<String, dynamic>> exercises = [];
    if (sessionType == 0) {
      // Push Day
      exercises.add({'name': 'Bench Press', 'sets': 4, 'reps': 8, 'weight': 0.0});
      exercises.add({'name': 'Overhead Press', 'sets': 3, 'reps': 10, 'weight': 0.0});
      exercises.add({'name': 'Tricep Dips', 'sets': 3, 'reps': 12, 'weight': 0.0});
    } else if (sessionType == 1) {
      // Pull Day
      exercises.add({'name': 'Rows', 'sets': 4, 'reps': 8, 'weight': 0.0});
      exercises.add({'name': 'Pull-ups', 'sets': 3, 'reps': 10, 'weight': 0.0});
      exercises.add({'name': 'Bicep Curls', 'sets': 3, 'reps': 12, 'weight': 0.0});
    } else {
      // Legs Day
      exercises.add({'name': 'Squat', 'sets': 4, 'reps': 8, 'weight': 0.0});
      exercises.add({'name': 'Deadlift', 'sets': 3, 'reps': 6, 'weight': 0.0});
      exercises.add({'name': 'Lunges', 'sets': 3, 'reps': 12, 'weight': 0.0});
    }

    return {
      'week': currentWeek,
      'session': currentSession,
      'workoutName': sessionType == 0 ? 'Push' : (sessionType == 1 ? 'Pull' : 'Legs'),
      'exercises': exercises,
      'unit': unit,
    };
  }
}