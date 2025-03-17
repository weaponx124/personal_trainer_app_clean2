// program_details_logic.dart
import 'package:flutter/material.dart';
import '../database_helper.dart';
import 'program_logic.dart';

class ProgramDetailsLogic {
  final String programId;
  String unit;
  final Function(List<Map<String, dynamic>>, List<TextEditingController>, List<bool>, Map<String, dynamic>?) onSessionInitialized;

  ProgramDetailsLogic({
    required this.programId,
    required this.unit,
    required this.onSessionInitialized,
  });

  void updateUnit(String newUnit) {
    unit = newUnit;
  }

  void initializeSessionSets(Map<String, dynamic> program) {
    List<Map<String, dynamic>> currentSessionSets = [];
    List<TextEditingController> repsControllers = [];
    List<bool> setCompleted = [];
    Map<String, dynamic>? currentWorkout;

    currentWorkout = ProgramLogic.generateWorkout(
      program['name'] as String,
      program,
      program['currentWeek'] as int? ?? 1,
      program['currentSession'] as int? ?? 1,
    );
    print('Generated workout in initializeSessionSets: $currentWorkout');

    if (currentWorkout != null && currentWorkout['exercises'] != null) {
      final List<Map<String, dynamic>> exercises = currentWorkout['exercises'] as List<Map<String, dynamic>>;
      print('Found ${exercises.length} exercises in workout');
      for (var exercise in exercises) {
        final name = exercise['name'] as String? ?? 'Unknown Exercise'; // Ensure name is non-null
        final sets = exercise['sets'] as int;
        final reps = exercise['reps'] as int;
        final weight = exercise['weight'] as double;
        for (int i = 0; i < sets; i++) {
          currentSessionSets.add({
            'name': name,
            'weight': weight,
            'reps': reps,
            'programId': programId,
            'workoutName': currentWorkout['workoutName'] ?? 'Unknown Workout',
          });
          print('Added set: name=$name, weight=$weight, reps=$reps, workoutName=${currentWorkout['workoutName'] ?? 'Unknown Workout'}');
        }
      }
      print('Total sets added: ${currentSessionSets.length}');
      repsControllers = List<TextEditingController>.generate(currentSessionSets.length, (i) => TextEditingController(text: ''));
      setCompleted = List<bool>.filled(currentSessionSets.length, false);
      print('Initialized repsControllers: ${repsControllers.length}, setCompleted: ${setCompleted.length}');
    } else if (program['name'] == '5/3/1 Program' || program['name'] == 'Russian Squat Program') {
      final setsInfo = program['name'] == '5/3/1 Program'
          ? _calculate531Workouts(program)
          : program['name'] == 'Russian Squat Program'
          ? _calculateRussianSquatWorkouts(program)
          : [];
      if (setsInfo.isNotEmpty) {
        currentSessionSets = List.from(setsInfo[0]['sets']);
        // Ensure all sets have a valid name
        for (var set in currentSessionSets) {
          if (!set.containsKey('name') || set['name'] == null) {
            set['name'] = 'Unknown Exercise';
          }
        }
        print('Loaded ${currentSessionSets.length} sets from special program logic');
        repsControllers = List<TextEditingController>.generate(currentSessionSets.length, (i) => TextEditingController(text: ''));
        setCompleted = List<bool>.filled(currentSessionSets.length, false);
        print('Initialized repsControllers: ${repsControllers.length}, setCompleted: ${setCompleted.length}');
      } else {
        print('No sets generated for special program, using empty lists');
      }
    } else {
      print('No valid workout or special program logic applied, using empty lists');
    }

    onSessionInitialized(currentSessionSets, repsControllers, setCompleted, currentWorkout);
  }

  VoidCallback completeSession({
    required BuildContext context,
    required List<bool> setCompleted,
    required List<Map<String, dynamic>> currentSessionSets,
    required List<TextEditingController> repsControllers,
    required String programId,
    required VoidCallback onComplete,
    Map<String, dynamic>? currentWorkout,
  }) {
    return () async {
      print('Completing session. Sets length: ${currentSessionSets.length}, Completed length: ${setCompleted.length}, Controllers length: ${repsControllers.length}, currentWorkout: $currentWorkout');
      if (currentSessionSets.isEmpty || setCompleted.length != currentSessionSets.length || repsControllers.length != currentSessionSets.length) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Session sets data is inconsistent. Please reload the program.')),
        );
        return;
      }

      bool hasIncompleteWorkingSets = false;
      for (int i = 0; i < currentSessionSets.length; i++) {
        if (!currentSessionSets[i]['name'].toString().startsWith('Warmup') && !setCompleted[i]) {
          hasIncompleteWorkingSets = true;
          print('Incomplete working set found at index $i: ${currentSessionSets[i]['name']}');
          break;
        }
      }

      if (hasIncompleteWorkingSets) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please complete all working sets before marking the session as complete!')),
        );
        return;
      }

      final date = DateTime.now().toIso8601String().split('T')[0];
      final logEntry = {
        'date': date,
        'lift': currentSessionSets.isNotEmpty ? currentSessionSets[0]['name'] as String : 'Unknown',
        'workoutName': currentWorkout?['workoutName'] ?? 'Unknown Workout',
        'programId': programId,
        'sets': currentSessionSets.asMap().entries.map((entry) {
          final index = entry.key;
          final set = entry.value;
          final completedReps = int.tryParse(repsControllers[index].text) ?? 0;
          return {
            'weight': set['weight'] as double,
            'reps': set['reps'] as int,
            'completedReps': completedReps,
            'name': set['name'] as String? ?? 'Unknown Exercise', // Ensure name is non-null
          };
        }).toList(),
      };

      try {
        final currentLog = await DatabaseHelper.getProgramLog(programId);
        currentLog.add(logEntry);
        await DatabaseHelper.saveProgramLog(programId, currentLog);
        await DatabaseHelper.incrementProgramSession(programId);
        onComplete();
        print('Completed session with log: $logEntry, unit: $unit');
      } catch (e) {
        print('Error completing session: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error completing session: $e')));
      }
    };
  }

  List<Map<String, dynamic>> _calculate531Workouts(Map<String, dynamic> program) {
    if (program['name'] != '5/3/1 Program' || program['details'] == null) return [];

    final oneRMs = program['details']['1RMs'] as Map<String, dynamic>;
    final trainingMaxes = oneRMs.map((lift, value) => MapEntry(lift, (value as double) * 0.9));
    final currentWeek = program['currentWeek'] as int? ?? 1;

    List<List<double>> percentages;
    List<List<int>> reps;

    switch (currentWeek) {
      case 1:
        percentages = List.generate(4, (_) => [0.65, 0.75, 0.85]);
        reps = List.generate(4, (_) => [3, 3, 3]);
        break;
      case 2:
        percentages = List.generate(4, (_) => [0.70, 0.80, 0.90]);
        reps = List.generate(4, (_) => [3, 3, 3]);
        break;
      case 3:
        percentages = List.generate(4, (_) => [0.75, 0.85, 0.95]);
        reps = List.generate(4, (_) => [3, 3, 1]);
        break;
      case 4:
        percentages = List.generate(4, (_) => [0.40, 0.50, 0.60]);
        reps = List.generate(4, (_) => [3, 3, 3]);
        break;
      default:
        percentages = [];
        reps = [];
    }

    List<Map<String, dynamic>> workouts = [];
    for (var lift in trainingMaxes.keys) {
      final trainingMax = trainingMaxes[lift] as double;
      final liftWorkouts = List.generate(3, (setIndex) {
        final weight = ProgramLogic.calculateWorkingWeight(trainingMax, percentages[0][setIndex], unit: unit);
        return {'weight': weight, 'reps': reps[0][setIndex], 'name': lift};
      });
      workouts.add({'lift': lift, 'sets': liftWorkouts});
    }
    return workouts;
  }

  List<Map<String, dynamic>> _calculateRussianSquatWorkouts(Map<String, dynamic> program) {
    if (program['name'] != 'Russian Squat Program' || program['details'] == null) return [];

    final oneRM = program['details']['1RM'] as double;
    final currentSession = program['currentSession'] as int? ?? 1;
    double percentage;

    if (currentSession <= 9) {
      percentage = 0.8;
    } else {
      switch (currentSession) {
        case 10:
          percentage = 0.85;
          break;
        case 11:
        case 13:
        case 15:
        case 17:
          percentage = 0.80;
          break;
        case 12:
          percentage = 0.90;
          break;
        case 14:
          percentage = 0.95;
          break;
        case 16:
          percentage = 1.00;
          break;
        case 18:
          percentage = 1.05;
          break;
        default:
          percentage = 0.80;
      }
    }

    double trainingWeight = ProgramLogic.calculateWorkingWeight(oneRM, percentage, unit: unit);

    int sets;
    int reps;
    switch (currentSession) {
      case 1:
      case 3:
      case 5:
      case 7:
      case 9:
        sets = 6;
        reps = 2;
        break;
      case 2:
        sets = 6;
        reps = 3;
        break;
      case 4:
        sets = 6;
        reps = 4;
        break;
      case 6:
        sets = 6;
        reps = 5;
        break;
      case 8:
        sets = 6;
        reps = 6;
        break;
      case 10:
        sets = 5;
        reps = 5;
        break;
      case 11:
      case 13:
      case 15:
      case 17:
        sets = 6;
        reps = 2;
        break;
      case 12:
        sets = 4;
        reps = 4;
        break;
      case 14:
        sets = 3;
        reps = 3;
        break;
      case 16:
        sets = 2;
        reps = 2;
        break;
      case 18:
        sets = 1;
        reps = 1;
        break;
      default:
        sets = 6;
        reps = 2;
    }

    List<Map<String, dynamic>> workouts = [];
    final liftWorkouts = List.generate(sets, (setIndex) {
      return {'weight': trainingWeight, 'reps': reps, 'name': 'Squat'};
    });
    workouts.add({'lift': 'Squat', 'sets': liftWorkouts});
    return workouts;
  }

  double _roundWeight(double weight, String unit) {
    if (unit == 'lbs') {
      return (weight / 5).round() * 5;
    } else {
      return weight.roundToDouble();
    }
  }
}