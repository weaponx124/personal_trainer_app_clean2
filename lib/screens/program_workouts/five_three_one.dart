import '../program_logic.dart';

class FiveThreeOneWorkout {
  static Map<String, dynamic> generate(Map<String, dynamic> programDetails, int currentWeek, int currentSession) {
    final unit = programDetails['details']?['unit'] as String? ?? 'lbs';
    final details = programDetails['details'] as Map<String, dynamic>? ?? {};
    final oneRMsRaw = details['1RMs'] as Map<String, dynamic>?;

    // Debug: Log the raw 1RMs before conversion
    print('5/3/1 Program - Raw 1RMs from programDetails[\'details\']: $oneRMsRaw');

    final oneRMs = oneRMsRaw != null
        ? <String, double>{
      'Squat': (oneRMsRaw['Squat'] as num?)?.toDouble() ?? 100.0,
      'Bench': (oneRMsRaw['Bench'] as num?)?.toDouble() ?? 100.0,
      'Deadlift': (oneRMsRaw['Deadlift'] as num?)?.toDouble() ?? 100.0,
      'Overhead': (oneRMsRaw['Overhead'] as num?)?.toDouble() ?? 100.0,
    }
        : <String, double>{
      'Squat': 100.0,
      'Bench': 100.0,
      'Deadlift': 100.0,
      'Overhead': 100.0,
    };
    final original1RMsRaw = details['original1RMs'] as Map<String, dynamic>?;
    final original1RMs = original1RMsRaw != null
        ? <String, double>{
      'Squat': (original1RMsRaw['Squat'] as num?)?.toDouble() ?? 100.0,
      'Bench': (original1RMsRaw['Bench'] as num?)?.toDouble() ?? 100.0,
      'Deadlift': (original1RMsRaw['Deadlift'] as num?)?.toDouble() ?? 100.0,
      'Overhead': (original1RMsRaw['Overhead'] as num?)?.toDouble() ?? 100.0,
    }
        : oneRMs;

    // Adjust 1RMs based on cycles (assume 4 weeks per cycle, increase every 4 weeks)
    final adjusted1RMs = Map<String, double>.from(oneRMs);
    final cycleNumber = ((currentWeek - 1) ~/ 4) + 1;
    final increment = unit == 'kg' ? 2.5 : 5.0;
    adjusted1RMs.updateAll((key, value) => value + (increment * (cycleNumber - 1)));

    final weekInCycle = (currentWeek - 1) % 4 + 1; // 1, 2, 3, 4 (repeats every 4 weeks)
    // Adjust sessionType to map currentSession 1 to Day 1 (sessionType 0)
    final sessionType = (currentSession - 1) % 4; // Subtract 1 to align Session 1 with Day 1

    final List<double> percentages;
    if (weekInCycle == 1) {
      percentages = [65, 75, 85]; // 3/3/3+
    } else if (weekInCycle == 2) {
      percentages = [70, 80, 90]; // 5/5/5+
    } else if (weekInCycle == 3) {
      percentages = [75, 85, 95]; // 3/3/1+
    } else {
      percentages = [40, 50, 60]; // Deload week
    }

    final List<Map<String, dynamic>> exercises = [];
    String lift;
    switch (sessionType) {
      case 0:
        lift = 'Overhead';
        break;
      case 1:
        lift = 'Deadlift';
        break;
      case 2:
        lift = 'Bench';
        break;
      case 3:
        lift = 'Squat';
        break;
      default:
        lift = 'Squat';
    }

    for (int i = 0; i < 3; i++) {
      exercises.add({
        'name': lift,
        'sets': 1,
        'reps': weekInCycle == 1 ? 3 : (weekInCycle == 2 ? 5 : (weekInCycle == 3 ? (i == 2 ? 1 : 3) : 5)),
        'weight': ProgramLogic.calculateWorkingWeight(adjusted1RMs[lift]!, percentages[i], unit: unit),
      });
    }

    return {
      'week': currentWeek,
      'session': currentSession,
      'workoutName': 'Day ${sessionType + 1}: $lift (${weekInCycle == 1 ? "3/3/3+" : (weekInCycle == 2 ? "5/5/5+" : (weekInCycle == 3 ? "3/3/1+" : "Deload"))})',
      'exercises': exercises,
      'unit': unit,
    };
  }
}