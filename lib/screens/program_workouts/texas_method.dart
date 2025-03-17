import '../program_logic.dart';

class TexasMethodWorkout {
  static Map<String, dynamic> generate(Map<String, dynamic> programDetails, int currentWeek, int currentSession) {
    final unit = programDetails['details']?['unit'] as String? ?? 'lbs';
    final details = programDetails['details'] as Map<String, dynamic>? ?? {};
    final oneRMsRaw = details['1RMs'] as Map<String, dynamic>?;

    // Debug: Log the raw 1RMs before conversion
    print('Texas Method - Raw 1RMs from programDetails[\'details\']: $oneRMsRaw');

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
        : oneRMs;

    // Adjust 1RMs based on weekly progression (increase by 2% per week)
    final adjusted1RMs = Map<String, double>.from(oneRMs);
    adjusted1RMs.updateAll((key, value) => value * (1 + 0.02 * (currentWeek - 1)));

    // Adjust sessionType to map currentSession 1 to Day 1 (sessionType 0)
    final sessionType = (currentSession - 1) % 3; // Subtract 1 to align Session 1 with Day 1

    final List<Map<String, dynamic>> exercises = [];
    if (sessionType == 0) {
      // Day 1: Volume
      exercises.add({
        'name': 'Squat',
        'sets': 5,
        'reps': 5,
        'weight': ProgramLogic.calculateWorkingWeight(adjusted1RMs['Squat']!, 70, unit: unit),
      });
      exercises.add({
        'name': 'Bench Press',
        'sets': 5,
        'reps': 5,
        'weight': ProgramLogic.calculateWorkingWeight(adjusted1RMs['Bench']!, 70, unit: unit),
      });
      exercises.add({
        'name': 'Row',
        'sets': 5,
        'reps': 5,
        'weight': ProgramLogic.calculateWorkingWeight(adjusted1RMs['Bench']!, 60, unit: unit),
      });
    } else if (sessionType == 1) {
      // Day 2: Recovery
      exercises.add({
        'name': 'Squat',
        'sets': 2,
        'reps': 5,
        'weight': ProgramLogic.calculateWorkingWeight(adjusted1RMs['Squat']!, 60, unit: unit),
      });
      exercises.add({
        'name': 'Overhead Press',
        'sets': 3,
        'reps': 5,
        'weight': ProgramLogic.calculateWorkingWeight(adjusted1RMs['Bench']!, 60, unit: unit),
      });
      exercises.add({
        'name': 'Deadlift',
        'sets': 2,
        'reps': 5,
        'weight': ProgramLogic.calculateWorkingWeight(adjusted1RMs['Deadlift']!, 60, unit: unit),
      });
    } else {
      // Day 3: Intensity
      exercises.add({
        'name': 'Squat',
        'sets': 1,
        'reps': 5,
        'weight': ProgramLogic.calculateWorkingWeight(adjusted1RMs['Squat']!, 90, unit: unit),
      });
      exercises.add({
        'name': 'Bench Press',
        'sets': 1,
        'reps': 5,
        'weight': ProgramLogic.calculateWorkingWeight(adjusted1RMs['Bench']!, 90, unit: unit),
      });
      exercises.add({
        'name': 'Row',
        'sets': 1,
        'reps': 5,
        'weight': ProgramLogic.calculateWorkingWeight(adjusted1RMs['Bench']!, 80, unit: unit),
      });
    }

    return {
      'week': currentWeek,
      'session': currentSession,
      'workoutName': sessionType == 0 ? 'Volume Day' : (sessionType == 1 ? 'Recovery Day' : 'Intensity Day'),
      'exercises': exercises,
      'unit': unit,
    };
  }
}