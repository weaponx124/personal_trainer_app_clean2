class BodyweightFitnessWorkout {
  static Map<String, dynamic> generate(Map<String, dynamic> programDetails, int currentWeek, int currentSession) {
    // Bodyweight Fitness has 3 workouts: Full Body A, Full Body B, Full Body C, cycled each session
    // No 1RM needed, progression is by increasing reps or difficulty
    // Full Body A: Push-ups 3x10, Squats 3x15, Pull-ups 3x5
    // Full Body B: Dips 3x8, Lunges 3x12, Rows 3x8
    // Full Body C: Push-ups 3x12, Squats 3x20, Pull-ups 3x6

    final sessionType = (currentSession % 3); // Cycles through 0, 1, 2 (A, B, C)

    final List<Map<String, dynamic>> exercises = [];
    if (sessionType == 0) {
      // Full Body A
      exercises.add({'name': 'Push-ups', 'sets': 3, 'reps': 10, 'weight': 0.0});
      exercises.add({'name': 'Squats', 'sets': 3, 'reps': 15, 'weight': 0.0});
      exercises.add({'name': 'Pull-ups', 'sets': 3, 'reps': 5, 'weight': 0.0});
    } else if (sessionType == 1) {
      // Full Body B
      exercises.add({'name': 'Dips', 'sets': 3, 'reps': 8, 'weight': 0.0});
      exercises.add({'name': 'Lunges', 'sets': 3, 'reps': 12, 'weight': 0.0});
      exercises.add({'name': 'Rows', 'sets': 3, 'reps': 8, 'weight': 0.0});
    } else {
      // Full Body C
      exercises.add({'name': 'Push-ups', 'sets': 3, 'reps': 12, 'weight': 0.0});
      exercises.add({'name': 'Squats', 'sets': 3, 'reps': 20, 'weight': 0.0});
      exercises.add({'name': 'Pull-ups', 'sets': 3, 'reps': 6, 'weight': 0.0});
    }

    return {
      'week': currentWeek,
      'session': currentSession,
      'workoutName': sessionType == 0 ? 'Full Body A' : (sessionType == 1 ? 'Full Body B' : 'Full Body C'),
      'exercises': exercises,
      'unit': 'bodyweight',
    };
  }
}