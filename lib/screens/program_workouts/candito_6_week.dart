import '../program_logic.dart';

class Candito6WeekWorkout {
  static Map<String, dynamic> generate(Map<String, dynamic> programDetails, int currentWeek, int currentSession) {
    final unit = programDetails['details']?['unit'] as String? ?? 'lbs';
    final details = programDetails['details'] as Map<String, dynamic>? ?? {};
    final oneRMsRaw = details['1RMs'] as Map<String, dynamic>?;

    // Debug: Log the raw 1RMs before conversion
    print('Candito 6-Week - Raw 1RMs from programDetails[\'details\']: $oneRMsRaw');

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

    // Adjust 1RMs based on weekly progression (increase by 1% per week)
    final adjusted1RMs = Map<String, double>.from(oneRMs);
    adjusted1RMs.updateAll((key, value) => value * (1 + 0.01 * (currentWeek - 1)));

    // Adjust sessionType to map currentSession 1 to Day 1 (sessionType 0)
    final sessionType = (currentSession - 1) % 3; // Subtract 1 to align Session 1 with Day 1

    final List<Map<String, dynamic>> exercises = [];
    if (currentWeek <= 2) {
      // Hypertrophy Phase (Weeks 1-2)
      if (sessionType == 0) {
        // Day 1: Lower Body
        exercises.add({
          'name': 'Squat',
          'sets': 4,
          'reps': 8,
          'weight': ProgramLogic.calculateWorkingWeight(adjusted1RMs['Squat']!, 65, unit: unit),
        });
        exercises.add({
          'name': 'Deadlift',
          'sets': 3,
          'reps': 8,
          'weight': ProgramLogic.calculateWorkingWeight(adjusted1RMs['Deadlift']!, 60, unit: unit),
        });
      } else if (sessionType == 1) {
        // Day 2: Upper Body
        exercises.add({
          'name': 'Bench Press',
          'sets': 4,
          'reps': 8,
          'weight': ProgramLogic.calculateWorkingWeight(adjusted1RMs['Bench']!, 65, unit: unit),
        });
        exercises.add({
          'name': 'Row',
          'sets': 3,
          'reps': 10,
          'weight': ProgramLogic.calculateWorkingWeight(adjusted1RMs['Bench']!, 50, unit: unit),
        });
      } else {
        // Day 3: Full Body
        exercises.add({
          'name': 'Squat',
          'sets': 3,
          'reps': 10,
          'weight': ProgramLogic.calculateWorkingWeight(adjusted1RMs['Squat']!, 60, unit: unit),
        });
        exercises.add({
          'name': 'Bench Press',
          'sets': 3,
          'reps': 10,
          'weight': ProgramLogic.calculateWorkingWeight(adjusted1RMs['Bench']!, 60, unit: unit),
        });
      }
    } else if (currentWeek <= 4) {
      // Strength Phase (Weeks 3-4)
      if (sessionType == 0) {
        // Day 1: Lower Body
        exercises.add({
          'name': 'Squat',
          'sets': 4,
          'reps': 5,
          'weight': ProgramLogic.calculateWorkingWeight(adjusted1RMs['Squat']!, 75, unit: unit),
        });
        exercises.add({
          'name': 'Deadlift',
          'sets': 3,
          'reps': 5,
          'weight': ProgramLogic.calculateWorkingWeight(adjusted1RMs['Deadlift']!, 70, unit: unit),
        });
      } else if (sessionType == 1) {
        // Day 2: Upper Body
        exercises.add({
          'name': 'Bench Press',
          'sets': 4,
          'reps': 5,
          'weight': ProgramLogic.calculateWorkingWeight(adjusted1RMs['Bench']!, 75, unit: unit),
        });
        exercises.add({
          'name': 'Row',
          'sets': 3,
          'reps': 8,
          'weight': ProgramLogic.calculateWorkingWeight(adjusted1RMs['Bench']!, 60, unit: unit),
        });
      } else {
        // Day 3: Full Body
        exercises.add({
          'name': 'Squat',
          'sets': 3,
          'reps': 6,
          'weight': ProgramLogic.calculateWorkingWeight(adjusted1RMs['Squat']!, 70, unit: unit),
        });
        exercises.add({
          'name': 'Bench Press',
          'sets': 3,
          'reps': 6,
          'weight': ProgramLogic.calculateWorkingWeight(adjusted1RMs['Bench']!, 70, unit: unit),
        });
      }
    } else {
      // Peaking Phase (Weeks 5-6)
      if (sessionType == 0) {
        // Day 1: Lower Body
        exercises.add({
          'name': 'Squat',
          'sets': 3,
          'reps': 3,
          'weight': ProgramLogic.calculateWorkingWeight(adjusted1RMs['Squat']!, 85, unit: unit),
        });
        exercises.add({
          'name': 'Deadlift',
          'sets': 2,
          'reps': 3,
          'weight': ProgramLogic.calculateWorkingWeight(adjusted1RMs['Deadlift']!, 80, unit: unit),
        });
      } else if (sessionType == 1) {
        // Day 2: Upper Body
        exercises.add({
          'name': 'Bench Press',
          'sets': 3,
          'reps': 3,
          'weight': ProgramLogic.calculateWorkingWeight(adjusted1RMs['Bench']!, 85, unit: unit),
        });
        exercises.add({
          'name': 'Row',
          'sets': 2,
          'reps': 5,
          'weight': ProgramLogic.calculateWorkingWeight(adjusted1RMs['Bench']!, 70, unit: unit),
        });
      } else {
        // Day 3: Full Body (Test Max)
        exercises.add({
          'name': 'Squat',
          'sets': 1,
          'reps': 3,
          'weight': ProgramLogic.calculateWorkingWeight(adjusted1RMs['Squat']!, 90, unit: unit),
        });
        exercises.add({
          'name': 'Bench Press',
          'sets': 1,
          'reps': 3,
          'weight': ProgramLogic.calculateWorkingWeight(adjusted1RMs['Bench']!, 90, unit: unit),
        });
      }
    }

    return {
      'week': currentWeek,
      'session': currentSession,
      'workoutName': sessionType == 0 ? 'Day 1' : (sessionType == 1 ? 'Day 2' : 'Day 3'),
      'exercises': exercises,
      'unit': unit,
    };
  }
}