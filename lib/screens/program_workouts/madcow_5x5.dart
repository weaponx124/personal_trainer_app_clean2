import '../program_logic.dart';

class Madcow5x5Workout {
  static Map<String, dynamic> generate(Map<String, dynamic> programDetails, int currentWeek, int currentSession) {
    final unit = programDetails['details']?['unit'] as String? ?? 'lbs';
    final details = programDetails['details'] as Map<String, dynamic>? ?? {};
    final oneRMsRaw = programDetails['oneRMs'] as Map<String, dynamic>?;

    // Debug: Log the raw 1RMs before conversion
    print('Madcow 5x5 - Raw 1RMs from programDetails[\'oneRMs\']: $oneRMsRaw');

    // Convert 1RMs to ensure all values are doubles
    final oneRMs = oneRMsRaw != null
        ? <String, double>{
      'Squat': (oneRMsRaw['Squat'] as num?)?.toDouble() ?? 100.0,
      'Bench': (oneRMsRaw['Bench'] as num?)?.toDouble() ?? 100.0,
      'Deadlift': (oneRMsRaw['Deadlift'] as num?)?.toDouble() ?? 100.0,
    }
        : <String, double>{
      'Squat': 100.0,
      'Bench': 100.0,
      'Deadlift': 100.0,
    };
    final original1RMsRaw = details['original1RMs'] as Map<String, dynamic>?;
    final original1RMs = original1RMsRaw != null
        ? <String, double>{
      'Squat': (original1RMsRaw['Squat'] as num?)?.toDouble() ?? 100.0,
      'Bench': (original1RMsRaw['Bench'] as num?)?.toDouble() ?? 100.0,
      'Deadlift': (original1RMsRaw['Deadlift'] as num?)?.toDouble() ?? 100.0,
    }
        : Map.from(oneRMs);

    // Debug: Log the received 1RMs after conversion
    print('Madcow 5x5 - Received 1RMs: $oneRMs, original1RMs: $original1RMs, unit: $unit');

    // Calculate training max (90% of 1RM) with weekly progression (2.5% increase per week)
    final adjusted1RMs = <String, double>{};
    oneRMs.forEach((key, value) {
      adjusted1RMs[key] = value * (1 + 0.025 * (currentWeek - 1));
    });
    final trainingMaxes = <String, double>{};
    adjusted1RMs.forEach((key, value) {
      trainingMaxes[key] = value * 0.9; // Training max is 90% of adjusted 1RM
    });

    // Estimate training maxes for Barbell Row and Incline Bench Press based on Bench 1RM
    final bench1RM = adjusted1RMs['Bench']!;
    final barbellRow1RM = bench1RM * 0.75; // Adjusted to 75% of Bench 1RM
    final inclineBench1RM = bench1RM * 0.6; // Adjusted to 60% of Bench 1RM
    final barbellRowTrainingMax = barbellRow1RM * 0.9;
    final inclineBenchTrainingMax = inclineBench1RM * 0.9;

    print('Madcow 5x5 - Adjusted 1RMs: $adjusted1RMs, Training Maxes: $trainingMaxes');
    print('Madcow 5x5 - Estimated Barbell Row 1RM: $barbellRow1RM, Training Max: $barbellRowTrainingMax');
    print('Madcow 5x5 - Estimated Incline Bench 1RM: $inclineBench1RM, Training Max: $inclineBenchTrainingMax');

    final sessionType = (currentSession - 1) % 3; // Align Session 1 with Workout A (0)

    // Check if currentWeek exceeds 12 weeks for deload
    bool isDeload = currentWeek > 12;
    double deloadFactor = isDeload ? 0.5 : 1.0; // 50% intensity during deload

    final List<Map<String, dynamic>> exercises = [];
    if (sessionType == 0) {
      // Workout A: Medium (5x5 at 65% of training max)
      double squatTrainingMax = trainingMaxes['Squat']!;
      double benchTrainingMax = trainingMaxes['Bench']!;
      double rowTrainingMax = barbellRowTrainingMax;

      // Add warmup sets for Squat
      _addWarmupSets(exercises, 'Squat', squatTrainingMax, unit);
      // Add working sets for Squat
      exercises.add({
        'name': 'Squat',
        'sets': 5,
        'reps': 5,
        'weight': ProgramLogic.calculateWorkingWeight(squatTrainingMax, 65, unit: unit) * deloadFactor,
      });

      // Add warmup sets for Bench Press
      _addWarmupSets(exercises, 'Bench Press', benchTrainingMax, unit);
      // Add working sets for Bench Press
      exercises.add({
        'name': 'Bench Press',
        'sets': 5,
        'reps': 5,
        'weight': ProgramLogic.calculateWorkingWeight(benchTrainingMax, 65, unit: unit) * deloadFactor,
      });

      // Add warmup sets for Barbell Row
      _addWarmupSets(exercises, 'Barbell Row', rowTrainingMax, unit);
      // Add working sets for Barbell Row
      exercises.add({
        'name': 'Barbell Row',
        'sets': 5,
        'reps': 5,
        'weight': ProgramLogic.calculateWorkingWeight(rowTrainingMax, 65, unit: unit) * deloadFactor,
      });
    } else if (sessionType == 1) {
      // Workout B: Light (4x5 at 60% of training max)
      double squatTrainingMax = trainingMaxes['Squat']!;
      double inclineTrainingMax = inclineBenchTrainingMax;
      double deadliftTrainingMax = trainingMaxes['Deadlift']!;

      // Add warmup sets for Squat
      _addWarmupSets(exercises, 'Squat', squatTrainingMax, unit);
      // Add working sets for Squat
      exercises.add({
        'name': 'Squat',
        'sets': 4,
        'reps': 5,
        'weight': ProgramLogic.calculateWorkingWeight(squatTrainingMax, 60, unit: unit) * deloadFactor,
      });

      // Add warmup sets for Incline Bench Press
      _addWarmupSets(exercises, 'Incline Bench Press', inclineTrainingMax, unit);
      // Add working sets for Incline Bench Press
      exercises.add({
        'name': 'Incline Bench Press',
        'sets': 4,
        'reps': 5,
        'weight': ProgramLogic.calculateWorkingWeight(inclineTrainingMax, 60, unit: unit) * deloadFactor,
      });

      // Add warmup sets for Deadlift
      _addWarmupSets(exercises, 'Deadlift', deadliftTrainingMax, unit);
      // Add working sets for Deadlift
      exercises.add({
        'name': 'Deadlift',
        'sets': 4,
        'reps': 5,
        'weight': ProgramLogic.calculateWorkingWeight(deadliftTrainingMax, 60, unit: unit) * deloadFactor,
      });
    } else {
      // Workout C: Heavy (5x5 at 75% + 1x3 at 85% of training max)
      double squatTrainingMax = trainingMaxes['Squat']!;
      double benchTrainingMax = trainingMaxes['Bench']!;
      double rowTrainingMax = barbellRowTrainingMax;

      // Add warmup sets for Squat
      _addWarmupSets(exercises, 'Squat', squatTrainingMax, unit);
      // Add working sets for Squat (5x5)
      exercises.add({
        'name': 'Squat',
        'sets': 5,
        'reps': 5,
        'weight': ProgramLogic.calculateWorkingWeight(squatTrainingMax, 75, unit: unit) * deloadFactor,
      });
      // Add 6th set (1x3 at 85%)
      exercises.add({
        'name': 'Squat',
        'sets': 1,
        'reps': 3,
        'weight': ProgramLogic.calculateWorkingWeight(squatTrainingMax, 85, unit: unit) * deloadFactor,
      });

      // Add warmup sets for Bench Press
      _addWarmupSets(exercises, 'Bench Press', benchTrainingMax, unit);
      // Add working sets for Bench Press (5x5)
      exercises.add({
        'name': 'Bench Press',
        'sets': 5,
        'reps': 5,
        'weight': ProgramLogic.calculateWorkingWeight(benchTrainingMax, 75, unit: unit) * deloadFactor,
      });
      // Add 6th set (1x3 at 85%)
      exercises.add({
        'name': 'Bench Press',
        'sets': 1,
        'reps': 3,
        'weight': ProgramLogic.calculateWorkingWeight(benchTrainingMax, 85, unit: unit) * deloadFactor,
      });

      // Add warmup sets for Barbell Row
      _addWarmupSets(exercises, 'Barbell Row', rowTrainingMax, unit);
      // Add working sets for Barbell Row (5x5)
      exercises.add({
        'name': 'Barbell Row',
        'sets': 5,
        'reps': 5,
        'weight': ProgramLogic.calculateWorkingWeight(rowTrainingMax, 75, unit: unit) * deloadFactor,
      });
      // Add 6th set (1x3 at 85%)
      exercises.add({
        'name': 'Barbell Row',
        'sets': 1,
        'reps': 3,
        'weight': ProgramLogic.calculateWorkingWeight(rowTrainingMax, 85, unit: unit) * deloadFactor,
      });
    }

    return {
      'week': currentWeek,
      'session': currentSession,
      'workoutName': isDeload
          ? 'Deload: ${sessionType == 0 ? "Workout A: Medium" : (sessionType == 1 ? "Workout B: Light" : "Workout C: Heavy")}'
          : (sessionType == 0 ? 'Workout A: Medium' : (sessionType == 1 ? 'Workout B: Light' : 'Workout C: Heavy')),
      'exercises': exercises,
      'unit': unit,
    };
  }

  // Helper method to add warmup sets before working sets
  static void _addWarmupSets(List<Map<String, dynamic>> exercises, String exerciseName, double trainingMax, String unit) {
    // Warmup sets: 5 reps at 40%, 5 reps at 50%, 3 reps at 60% of training max
    const List<double> warmupPercentages = [40.0, 50.0, 60.0];
    const List<int> warmupReps = [5, 5, 3];

    for (int i = 0; i < warmupPercentages.length; i++) {
      double warmupWeight = ProgramLogic.calculateWorkingWeight(trainingMax, warmupPercentages[i], unit: unit);
      exercises.add({
        'name': 'Warmup: $exerciseName',
        'sets': 1,
        'reps': warmupReps[i],
        'weight': warmupWeight,
      });
      print('Added warmup set: name=Warmup: $exerciseName, weight=$warmupWeight, reps=${warmupReps[i]}');
    }
  }
}