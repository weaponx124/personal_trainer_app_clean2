// lib/screens/program_logic.dart
import 'package:flutter/material.dart';
import 'program_workouts/madcow_5x5.dart';

class ProgramLogic {
  // Helper function to calculate working weight based on 1RM, percentage, and unit
  static double calculateWorkingWeight(double oneRM, double percentage, {required String unit}) {
    double weight = oneRM * (percentage / 100);
    if (unit == 'lbs') {
      weight = (weight / 5).round() * 5; // Round to nearest 5 lbs
    } else {
      weight = weight.roundToDouble(); // Round to nearest kg
    }
    return weight;
  }

  // Starting Strength (Beginner, General Fitness)
  static Map<String, dynamic> generateStartingStrengthWorkout(Map<String, dynamic> programDetails, int currentWeek, int currentSession) {
    // Starting Strength has 2 workouts: A and B, alternating each session
    // Workout A: Squat 3x5, Bench 3x5, Deadlift 1x5
    // Workout B: Squat 3x5, Overhead Press 3x5, Deadlift 1x5
    // Linear progression: add 5 lbs (or 2.5 kg) per session

    final unit = programDetails['unit'] as String? ?? 'lbs';
    final increment = unit == 'kg' ? 2.5 : 5.0;
    final oneRMs = programDetails['1RMs'] as Map<String, dynamic>? ?? {
      'Squat': 100.0,
      'Bench': 100.0,
      'Overhead': 100.0,
      'Deadlift': 100.0,
    };
    final original1RMs = programDetails['original1RMs'] as Map<String, dynamic>? ?? oneRMs;

    // Adjust 1RMs based on progression
    final adjusted1RMs = <String, double>{};
    oneRMs.forEach((key, value) {
      adjusted1RMs[key] = (value is double ? value : double.parse(value.toString()));
    });
    final sessionsCompleted = programDetails['sessionsCompleted'] as int? ?? 0;
    adjusted1RMs.updateAll((key, value) => value + (increment * sessionsCompleted));

    final bool isWorkoutA = currentSession % 2 == 1; // Alternates A, B, A, B...

    final List<Map<String, dynamic>> exercises = [];
    if (isWorkoutA) {
      // Workout A
      exercises.add({
        'name': 'Squat',
        'sets': 3,
        'reps': 5,
        'weight': calculateWorkingWeight(adjusted1RMs['Squat']!, 75, unit: unit),
      });
      exercises.add({
        'name': 'Bench Press',
        'sets': 3,
        'reps': 5,
        'weight': calculateWorkingWeight(adjusted1RMs['Bench']!, 75, unit: unit),
      });
      exercises.add({
        'name': 'Deadlift',
        'sets': 1,
        'reps': 5,
        'weight': calculateWorkingWeight(adjusted1RMs['Deadlift']!, 75, unit: unit),
      });
    } else {
      // Workout B
      exercises.add({
        'name': 'Squat',
        'sets': 3,
        'reps': 5,
        'weight': calculateWorkingWeight(adjusted1RMs['Squat']!, 75, unit: unit),
      });
      exercises.add({
        'name': 'Overhead Press',
        'sets': 3,
        'reps': 5,
        'weight': calculateWorkingWeight(adjusted1RMs['Overhead']!, 75, unit: unit),
      });
      exercises.add({
        'name': 'Deadlift',
        'sets': 1,
        'reps': 5,
        'weight': calculateWorkingWeight(adjusted1RMs['Deadlift']!, 75, unit: unit),
      });
    }

    return {
      'week': currentWeek,
      'session': currentSession,
      'workoutName': isWorkoutA ? 'Workout A' : 'Workout B',
      'exercises': exercises,
      'unit': unit,
    };
  }

  // Bodyweight Fitness (Beginner, General Fitness)
  static Map<String, dynamic> generateBodyweightFitnessWorkout(Map<String, dynamic> programDetails, int currentWeek, int currentSession) {
    // Bodyweight Fitness has 3 workouts: Full Body A, Full Body B, Full Body C, cycled each session
    // No 1RM needed, progression is by increasing reps or difficulty
    // Full Body A: Push-ups 3x10, Squats 3x15, Pull-ups 3x5
    // Full Body B: Dips 3x8, Lunges 3x12, Rows 3x8
    // Full Body C: Push-ups 3x12, Squats 3x20, Pull-ups 3x6

    final unit = programDetails['unit'] as String? ?? 'bodyweight';
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
      'unit': unit,
    };
  }

  // Candito 6-Week Program (Intermediate, Powerlifting)
  static Map<String, dynamic> generateCandito6WeekWorkout(Map<String, dynamic> programDetails, int currentWeek, int currentSession) {
    // Candito 6-Week Program:
    // Weeks 1-2: Hypertrophy (3 days/week, high volume)
    // Weeks 3-4: Strength (3 days/week, moderate volume)
    // Weeks 5-6: Peaking (3 days/week, low volume, high intensity)
    // Progression: based on 1RM, adjusting percentages each week

    final unit = programDetails['unit'] as String? ?? 'lbs';
    final oneRMs = programDetails['1RMs'] as Map<String, dynamic>? ?? {
      'Squat': 100.0,
      'Bench': 100.0,
      'Deadlift': 100.0,
    };
    final original1RMs = programDetails['original1RMs'] as Map<String, dynamic>? ?? oneRMs;

    // Adjust 1RMs based on weekly progression (increase by 1% per week)
    final adjusted1RMs = <String, double>{};
    oneRMs.forEach((key, value) {
      adjusted1RMs[key] = (value is double ? value : double.parse(value.toString()));
    });
    adjusted1RMs.updateAll((key, value) => value * (1 + 0.01 * (currentWeek - 1)));

    final sessionType = (currentSession % 3); // 3 workouts per week

    final List<Map<String, dynamic>> exercises = [];
    if (currentWeek <= 2) {
      // Hypertrophy Phase (Weeks 1-2)
      if (sessionType == 0) {
        // Day 1: Lower Body
        exercises.add({
          'name': 'Squat',
          'sets': 4,
          'reps': 8,
          'weight': calculateWorkingWeight(adjusted1RMs['Squat']!, 65, unit: unit),
        });
        exercises.add({
          'name': 'Deadlift',
          'sets': 3,
          'reps': 8,
          'weight': calculateWorkingWeight(adjusted1RMs['Deadlift']!, 60, unit: unit),
        });
      } else if (sessionType == 1) {
        // Day 2: Upper Body
        exercises.add({
          'name': 'Bench Press',
          'sets': 4,
          'reps': 8,
          'weight': calculateWorkingWeight(adjusted1RMs['Bench']!, 65, unit: unit),
        });
        exercises.add({
          'name': 'Row',
          'sets': 3,
          'reps': 10,
          'weight': calculateWorkingWeight(adjusted1RMs['Bench']!, 50, unit: unit),
        });
      } else {
        // Day 3: Full Body
        exercises.add({
          'name': 'Squat',
          'sets': 3,
          'reps': 10,
          'weight': calculateWorkingWeight(adjusted1RMs['Squat']!, 60, unit: unit),
        });
        exercises.add({
          'name': 'Bench Press',
          'sets': 3,
          'reps': 10,
          'weight': calculateWorkingWeight(adjusted1RMs['Bench']!, 60, unit: unit),
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
          'weight': calculateWorkingWeight(adjusted1RMs['Squat']!, 75, unit: unit),
        });
        exercises.add({
          'name': 'Deadlift',
          'sets': 3,
          'reps': 5,
          'weight': calculateWorkingWeight(adjusted1RMs['Deadlift']!, 70, unit: unit),
        });
      } else if (sessionType == 1) {
        // Day 2: Upper Body
        exercises.add({
          'name': 'Bench Press',
          'sets': 4,
          'reps': 5,
          'weight': calculateWorkingWeight(adjusted1RMs['Bench']!, 75, unit: unit),
        });
        exercises.add({
          'name': 'Row',
          'sets': 3,
          'reps': 8,
          'weight': calculateWorkingWeight(adjusted1RMs['Bench']!, 60, unit: unit),
        });
      } else {
        // Day 3: Full Body
        exercises.add({
          'name': 'Squat',
          'sets': 3,
          'reps': 6,
          'weight': calculateWorkingWeight(adjusted1RMs['Squat']!, 70, unit: unit),
        });
        exercises.add({
          'name': 'Bench Press',
          'sets': 3,
          'reps': 6,
          'weight': calculateWorkingWeight(adjusted1RMs['Bench']!, 70, unit: unit),
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
          'weight': calculateWorkingWeight(adjusted1RMs['Squat']!, 85, unit: unit),
        });
        exercises.add({
          'name': 'Deadlift',
          'sets': 2,
          'reps': 3,
          'weight': calculateWorkingWeight(adjusted1RMs['Deadlift']!, 80, unit: unit),
        });
      } else if (sessionType == 1) {
        // Day 2: Upper Body
        exercises.add({
          'name': 'Bench Press',
          'sets': 3,
          'reps': 3,
          'weight': calculateWorkingWeight(adjusted1RMs['Bench']!, 85, unit: unit),
        });
        exercises.add({
          'name': 'Row',
          'sets': 2,
          'reps': 5,
          'weight': calculateWorkingWeight(adjusted1RMs['Bench']!, 70, unit: unit),
        });
      } else {
        // Day 3: Full Body (Test Max)
        exercises.add({
          'name': 'Squat',
          'sets': 1,
          'reps': 3,
          'weight': calculateWorkingWeight(adjusted1RMs['Squat']!, 90, unit: unit),
        });
        exercises.add({
          'name': 'Bench Press',
          'sets': 1,
          'reps': 3,
          'weight': calculateWorkingWeight(adjusted1RMs['Bench']!, 90, unit: unit),
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

  // Texas Method (Intermediate, Powerlifting)
  static Map<String, dynamic> generateTexasMethodWorkout(Map<String, dynamic> programDetails, int currentWeek, int currentSession) {
    // Texas Method has 3 workouts per week:
    // Day 1: Volume (Squat 5x5, Bench 5x5, Row 5x5 at 70%)
    // Day 2: Recovery (Squat 2x5 at 60%, Overhead 3x5 at 60%, Deadlift 2x5 at 60%)
    // Day 3: Intensity (Squat 1x5 at 90%, Bench 1x5 at 90%, Row 1x5 at 80%)
    // Progression: increase weights weekly by 2% of 1RM

    final unit = programDetails['unit'] as String? ?? 'lbs';
    final oneRMs = programDetails['1RMs'] as Map<String, dynamic>? ?? {
      'Squat': 100.0,
      'Bench': 100.0,
      'Deadlift': 100.0,
    };
    final original1RMs = programDetails['original1RMs'] as Map<String, dynamic>? ?? oneRMs;

    // Adjust 1RMs based on weekly progression (increase by 2% per week)
    final adjusted1RMs = <String, double>{};
    oneRMs.forEach((key, value) {
      adjusted1RMs[key] = (value is double ? value : double.parse(value.toString()));
    });
    adjusted1RMs.updateAll((key, value) => value * (1 + 0.02 * (currentWeek - 1)));

    final sessionType = (currentSession % 3); // Cycles through 0, 1, 2 (Volume, Recovery, Intensity)

    final List<Map<String, dynamic>> exercises = [];
    if (sessionType == 0) {
      // Day 1: Volume
      exercises.add({
        'name': 'Squat',
        'sets': 5,
        'reps': 5,
        'weight': calculateWorkingWeight(adjusted1RMs['Squat']!, 70, unit: unit),
      });
      exercises.add({
        'name': 'Bench Press',
        'sets': 5,
        'reps': 5,
        'weight': calculateWorkingWeight(adjusted1RMs['Bench']!, 70, unit: unit),
      });
      exercises.add({
        'name': 'Row',
        'sets': 5,
        'reps': 5,
        'weight': calculateWorkingWeight(adjusted1RMs['Bench']!, 60, unit: unit),
      });
    } else if (sessionType == 1) {
      // Day 2: Recovery
      exercises.add({
        'name': 'Squat',
        'sets': 2,
        'reps': 5,
        'weight': calculateWorkingWeight(adjusted1RMs['Squat']!, 60, unit: unit),
      });
      exercises.add({
        'name': 'Overhead Press',
        'sets': 3,
        'reps': 5,
        'weight': calculateWorkingWeight(adjusted1RMs['Bench']!, 60, unit: unit),
      });
      exercises.add({
        'name': 'Deadlift',
        'sets': 2,
        'reps': 5,
        'weight': calculateWorkingWeight(adjusted1RMs['Deadlift']!, 60, unit: unit),
      });
    } else {
      // Day 3: Intensity
      exercises.add({
        'name': 'Squat',
        'sets': 1,
        'reps': 5,
        'weight': calculateWorkingWeight(adjusted1RMs['Squat']!, 90, unit: unit),
      });
      exercises.add({
        'name': 'Bench Press',
        'sets': 1,
        'reps': 5,
        'weight': calculateWorkingWeight(adjusted1RMs['Bench']!, 90, unit: unit),
      });
      exercises.add({
        'name': 'Row',
        'sets': 1,
        'reps': 5,
        'weight': calculateWorkingWeight(adjusted1RMs['Bench']!, 80, unit: unit),
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

  // 5/3/1 Program (Intermediate, Powerlifting)
  static Map<String, dynamic> generate531Workout(Map<String, dynamic> programDetails, int currentWeek, int currentSession) {
    // 5/3/1 Program has 4-week cycles, 4 workouts per week:
    // Day 1: Overhead Press
    // Day 2: Deadlift
    // Day 3: Bench Press
    // Day 4: Squat
    // Each week has a different rep scheme: 3x65%, 3x75%, 3x85% (Week 1), 3x70%, 3x80%, 3x90% (Week 2), etc.
    // Progression: increase 1RMs by 5-10 lbs (2.5-5 kg) per cycle

    final unit = programDetails['unit'] as String? ?? 'lbs';
    final oneRMs = programDetails['1RMs'] as Map<String, dynamic>? ?? {
      'Squat': 100.0,
      'Bench': 100.0,
      'Deadlift': 100.0,
      'Overhead': 100.0,
    };
    final original1RMs = programDetails['original1RMs'] as Map<String, dynamic>? ?? oneRMs;

    // Adjust 1RMs based on cycles (assume 4 weeks per cycle, increase every 4 weeks)
    final adjusted1RMs = <String, double>{};
    oneRMs.forEach((key, value) {
      adjusted1RMs[key] = (value is double ? value : double.parse(value.toString()));
    });
    final cycleNumber = ((currentWeek - 1) ~/ 4) + 1;
    final increment = unit == 'kg' ? 2.5 : 5.0;
    adjusted1RMs.updateAll((key, value) => value + (increment * (cycleNumber - 1)));

    final weekInCycle = (currentWeek - 1) % 4 + 1; // 1, 2, 3, 4 (repeats every 4 weeks)
    final sessionType = (currentSession % 4); // 0: Overhead, 1: Deadlift, 2: Bench, 3: Squat

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
        'weight': calculateWorkingWeight(adjusted1RMs[lift]!, percentages[i], unit: unit),
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

  // Push/Pull/Legs (PPL) (All Levels, Bodybuilding)
  static Map<String, dynamic> generatePPLWorkout(Map<String, dynamic> programDetails, int currentWeek, int currentSession) {
    // PPL has 3 workouts: Push, Pull, Legs, cycled each session
    // Push: Bench Press 4x8, Overhead Press 3x10, Tricep Dips 3x12
    // Pull: Rows 4x8, Pull-ups 3x10, Bicep Curls 3x12
    // Legs: Squat 4x8, Deadlift 3x6, Lunges 3x12
    // No 1RM needed, weights are static or user-defined

    final unit = programDetails['unit'] as String? ?? 'lbs';
    final sessionType = (currentSession % 3); // Cycles through 0, 1, 2 (Push, Pull, Legs)

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

  // Bench Press Specialization (Intermediate, Specific Body Part)
  static Map<String, dynamic> generateBenchPressSpecializationWorkout(Map<String, dynamic> programDetails, int currentWeek, int currentSession) {
    // Bench Press Specialization: 3 workouts per week
    // Day 1: Heavy Bench (3x5 at 85%), Incline Bench 3x8, Tricep Dips 3x10
    // Day 2: Light Bench (3x8 at 60%), Dumbbell Press 3x10, Overhead Press 3x8
    // Day 3: Volume Bench (5x5 at 75%), Close-Grip Bench 3x8, Tricep Pushdowns 3x12
    // Progression: increase 1RM by 2% per week

    final unit = programDetails['unit'] as String? ?? 'lbs';
    final oneRM = programDetails['1RM'] as double? ?? 100.0;
    final original1RM = programDetails['original1RM'] as double? ?? oneRM;

    // Adjust 1RM based on weekly progression (increase by 2% per week)
    final adjusted1RM = oneRM * (1 + 0.02 * (currentWeek - 1));

    final sessionType = (currentSession % 3); // Cycles through 0, 1, 2 (Heavy, Light, Volume)

    final List<Map<String, dynamic>> exercises = [];
    if (sessionType == 0) {
      // Heavy Day
      exercises.add({
        'name': 'Bench Press',
        'sets': 3,
        'reps': 5,
        'weight': calculateWorkingWeight(adjusted1RM, 85, unit: unit),
      });
      exercises.add({
        'name': 'Incline Bench Press',
        'sets': 3,
        'reps': 8,
        'weight': calculateWorkingWeight(adjusted1RM, 60, unit: unit),
      });
      exercises.add({
        'name': 'Tricep Dips',
        'sets': 3,
        'reps': 10,
        'weight': 0.0,
      });
    } else if (sessionType == 1) {
      // Light Day
      exercises.add({
        'name': 'Bench Press',
        'sets': 3,
        'reps': 8,
        'weight': calculateWorkingWeight(adjusted1RM, 60, unit: unit),
      });
      exercises.add({
        'name': 'Dumbbell Press',
        'sets': 3,
        'reps': 10,
        'weight': calculateWorkingWeight(adjusted1RM, 50, unit: unit),
      });
      exercises.add({
        'name': 'Overhead Press',
        'sets': 3,
        'reps': 8,
        'weight': calculateWorkingWeight(adjusted1RM, 50, unit: unit),
      });
    } else {
      // Volume Day
      exercises.add({
        'name': 'Bench Press',
        'sets': 5,
        'reps': 5,
        'weight': calculateWorkingWeight(adjusted1RM, 75, unit: unit),
      });
      exercises.add({
        'name': 'Close-Grip Bench Press',
        'sets': 3,
        'reps': 8,
        'weight': calculateWorkingWeight(adjusted1RM, 65, unit: unit),
      });
      exercises.add({
        'name': 'Tricep Pushdowns',
        'sets': 3,
        'reps': 12,
        'weight': 0.0,
      });
    }

    return {
      'week': currentWeek,
      'session': currentSession,
      'workoutName': sessionType == 0 ? 'Heavy Bench' : (sessionType == 1 ? 'Light Bench' : 'Volume Bench'),
      'exercises': exercises,
      'unit': unit,
    };
  }

  // Russian Squat Program (Intermediate, Specific Body Part)
  static Map<String, dynamic> generateRussianSquatWorkout(Map<String, dynamic> programDetails, int currentWeek, int currentSession) {
    // Russian Squat Program: 6 weeks, 3 sessions per week
    // Week 1: 6x2 at 80%, 6x3 at 80%, 6x2 at 80%
    // Week 2: 6x4 at 80%, 6x2 at 80%, 6x5 at 80%
    // Week 3: 6x3 at 80%, 6x6 at 80%, 6x2 at 80%
    // Week 4: 6x4 at 85%, 6x3 at 85%, 6x5 at 85%
    // Week 5: 6x2 at 85%, 6x4 at 85%, 6x6 at 85%
    // Week 6: 6x3 at 85%, 6x2 at 85%, Test max

    final unit = programDetails['unit'] as String? ?? 'lbs';
    final oneRM = programDetails['1RM'] as double? ?? 100.0;
    final original1RM = programDetails['original1RM'] as double? ?? oneRM;
    final oneRMIncrement = programDetails['oneRMIncrement'] as double? ?? (unit == 'kg' ? 2.5 : 5.0);

    // Adjust 1RM based on weeks (increase at the end of the cycle)
    final adjusted1RM = oneRM + (oneRMIncrement * ((currentWeek - 1) ~/ 6));

    final sessionType = (currentSession % 3); // 3 sessions per week
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
      'weight': calculateWorkingWeight(adjusted1RM, percentage, unit: unit),
    });

    return {
      'week': currentWeek,
      'session': currentSession,
      'workoutName': sessionType == 2 && currentWeek == 6 ? 'Test Max' : 'Squat Session ${sessionType + 1}',
      'exercises': exercises,
      'unit': unit,
    };
  }

  // Smolov Base Cycle (Intermediate, Specific Body Part)
  static Map<String, dynamic> generateSmolovBaseCycleWorkout(Map<String, dynamic> programDetails, int currentWeek, int currentSession) {
    // Smolov Base Cycle: 4 weeks, 4 sessions per week
    // Week 1: 4x9 at 70%, 5x7 at 75%, 7x5 at 80%, 10x3 at 85%
    // Week 2: Same as Week 1, but add 5-10 lbs (2.5-5 kg)
    // Week 3: 4x9 at 70%, 5x7 at 75%, 7x5 at 80%, 10x3 at 85% + 10-20 lbs
    // Week 4: 4x9 at 70%, 5x7 at 75%, 7x5 at 80%, Test max

    final unit = programDetails['unit'] as String? ?? 'lbs';
    final oneRM = programDetails['1RM'] as double? ?? 100.0;
    final original1RM = programDetails['original1RM'] as double? ?? oneRM;
    final oneRMIncrement = programDetails['oneRMIncrement'] as double? ?? (unit == 'kg' ? 2.5 : 5.0);

    // Adjust 1RM based on weeks
    double adjusted1RM = oneRM;
    if (currentWeek == 2) {
      adjusted1RM += oneRMIncrement;
    } else if (currentWeek >= 3) {
      adjusted1RM += oneRMIncrement * 2;
    }

    final sessionType = (currentSession % 4); // 4 sessions per week
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
      'weight': calculateWorkingWeight(adjusted1RM, percentage, unit: unit),
    });

    return {
      'week': currentWeek,
      'session': currentSession,
      'workoutName': sessionType == 3 && currentWeek == 4 ? 'Test Max' : 'Squat Session ${sessionType + 1}',
      'exercises': exercises,
      'unit': unit,
    };
  }

  // Custom Program
  static Map<String, dynamic> generateCustomProgramWorkout(Map<String, dynamic> programDetails, int currentWeek, int currentSession) {
    // Custom Program: Defined by user
    // Movement, sets, reps, percentages, increment, isPercentageBased are stored in details

    final unit = programDetails['unit'] as String? ?? 'lbs';
    final details = programDetails['details'] as Map<String, dynamic>? ?? {};
    final movement = details['movement'] as String? ?? 'Squat';
    final sets = details['sets'] as int? ?? 5;
    final reps = details['reps'] as int? ?? 5;
    final percentages = (details['percentages'] as List<dynamic>?)?.cast<double>() ?? [65.0, 70.0, 75.0, 80.0, 85.0];
    final increment = details['increment'] as double? ?? 2.5;
    final isPercentageBased = details['isPercentageBased'] as bool? ?? true;
    final oneRM = details['1RM'] as double? ?? 100.0;

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
          'weight': calculateWorkingWeight(adjusted1RM, percentage, unit: unit),
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

  // Main method to generate workout based on program name
  static Map<String, dynamic> generateWorkout(String programName, Map<String, dynamic> programDetails, int currentWeek, int currentSession) {
    switch (programName) {
      case 'Starting Strength':
        return generateStartingStrengthWorkout(programDetails, currentWeek, currentSession);
      case 'Bodyweight Fitness':
        return generateBodyweightFitnessWorkout(programDetails, currentWeek, currentSession);
      case 'Madcow 5x5':
        return Madcow5x5Workout.generate(programDetails, currentWeek, currentSession);
      case 'Candito 6-Week Program':
        return generateCandito6WeekWorkout(programDetails, currentWeek, currentSession);
      case 'Texas Method':
        return generateTexasMethodWorkout(programDetails, currentWeek, currentSession);
      case '5/3/1 Program':
        return generate531Workout(programDetails, currentWeek, currentSession);
      case 'Push/Pull/Legs (PPL)':
        return generatePPLWorkout(programDetails, currentWeek, currentSession);
      case 'Bench Press Specialization':
        return generateBenchPressSpecializationWorkout(programDetails, currentWeek, currentSession);
      case 'Russian Squat Program':
        return generateRussianSquatWorkout(programDetails, currentWeek, currentSession);
      case 'Smolov Base Cycle':
        return generateSmolovBaseCycleWorkout(programDetails, currentWeek, currentSession);
      default:
        return generateCustomProgramWorkout(programDetails, currentWeek, currentSession);
    }
  }
}