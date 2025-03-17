// database_helper.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';

class DatabaseHelper {
  static const String _programsKey = 'programs';
  static const String _programLogKeyPrefix = 'programLog_';
  static const String _workoutsKey = 'workouts';
  static const String _suggestedExercisesKey = 'suggestedExercises';
  static const String _mealsKey = 'meals';
  static const String _progressKey = 'progress';
  static const String _weightUnitKey = 'weightUnit';

  static Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  static Future<void> initialize() async {
    final prefs = await _prefs;
    await prefs.remove(_weightUnitKey); // Reset for testing
    if (!prefs.containsKey(_weightUnitKey)) {
      await prefs.setString(_weightUnitKey, 'lbs'); // Default to lbs
      print('Initialized default weight unit to lbs');
    }
    if (!prefs.containsKey(_programsKey)) {
      await _initializeDefaultData();
    }
  }

  static Future<void> _initializeDefaultData() async {
    await savePrograms([]);
    print('Initialized programs list as empty');
  }

  static Future<void> clearPrograms() async {
    await savePrograms([]);
    print('Cleared all programs');
  }

  static Future<List<Map<String, dynamic>>> getPrograms() async {
    final prefs = await _prefs;
    final programsJson = prefs.getString(_programsKey);
    return programsJson != null ? jsonDecode(programsJson).cast<Map<String, dynamic>>() : [];
  }

  static Future<void> savePrograms(List<Map<String, dynamic>> programs) async {
    final prefs = await _prefs;
    await prefs.setString(_programsKey, jsonEncode(programs));
    print('Saved programs to SharedPreferences: $programs');
  }

  static Future<Map<String, dynamic>> getProgram(String programId) async {
    final programs = await getPrograms();
    return programs.firstWhere((program) => program['id'] == programId, orElse: () => {});
  }

  static Future<void> saveProgram(String programName, Map<String, dynamic> details) async {
    final programs = await getPrograms();
    final programId = Uuid().v4();
    final startDate = DateTime.now().toIso8601String().split('T')[0];

    Map<String, dynamic> programDetails = Map.from(details);
    if (details.containsKey('1RM')) {
      programDetails['original1RM'] = details['1RM'];
      programDetails['originalUnit'] = details['unit'];
    }
    if (details.containsKey('1RMs')) {
      programDetails['original1RMs'] = Map<String, double>.from(details['1RMs']);
      programDetails['originalUnit'] = details['unit'];
    }

    final newProgram = {
      'name': programName,
      'id': programId,
      'details': programDetails,
      'completed': false,
      'startDate': startDate,
      'currentWeek': 1,
      'currentSession': 1,
      'sessionsCompleted': 0,
    };
    programs.add(newProgram);
    await savePrograms(programs);
    print('Saved new program instance: $newProgram');
  }

  static Future<void> deleteProgram(String programId) async {
    final programs = await getPrograms();
    final updatedPrograms = programs.where((p) => p['id'] != programId).toList();
    await savePrograms(updatedPrograms);
    print('Deleted program with ID: $programId');
  }

  static Future<void> incrementProgramWeek(String programId) async {
    final programs = await getPrograms();
    final programIndex = programs.indexWhere((p) => p['id'] == programId);
    if (programIndex >= 0) {
      final program = programs[programIndex];
      int currentWeek = program['currentWeek'] as int? ?? 1;

      currentWeek += 1;

      program['currentSession'] = 1;
      program['sessionsCompleted'] = 0;
      program['currentWeek'] = currentWeek;
      programs[programIndex] = program;
      await savePrograms(programs);
      print('Incremented week for program ID $programId to week $currentWeek');
    }
  }

  static Future<void> incrementProgramSession(String programId) async {
    final programs = await getPrograms();
    final programIndex = programs.indexWhere((p) => p['id'] == programId);
    if (programIndex >= 0) {
      final program = programs[programIndex];
      bool isCompleted = program['completed'] as bool? ?? false;
      int sessionsCompleted = program['sessionsCompleted'] as int? ?? 0;
      int currentSession = program['currentSession'] as int? ?? 1;
      int currentWeek = program['currentWeek'] as int? ?? 1;

      if (isCompleted) {
        print('Program with ID $programId is already completed. No further increments allowed.');
        return;
      }

      // Define total sessions and deload period
      const totalRegularSessions = 36; // 12 weeks * 3 sessions per week
      const deloadSessions = 6; // 2 weeks * 3 sessions per week
      const totalProgramSessions = totalRegularSessions + deloadSessions; // 42 sessions

      // Check completion *before* incrementing
      if (sessionsCompleted >= totalProgramSessions - 1) { // Complete at 42 sessions
        program['completed'] = true;
        program['currentWeek'] = 14; // Final week
        program['currentSession'] = 3; // Final session of Week 14
        program['sessionsCompleted'] = totalProgramSessions;
        programs[programIndex] = program;
        await savePrograms(programs);
        print('Program completed after deload period for program ID $programId');
        return; // Exit to prevent further increments
      }

      // Increment session and week
      sessionsCompleted += 1;
      currentSession += 1;

      // Madcow 5x5 has 3 sessions per week
      if (currentSession > 3) {
        currentSession = 1;
        currentWeek += 1;
      }

      // Track deload sessions separately
      int deloadSessionsCompleted = sessionsCompleted > totalRegularSessions ? sessionsCompleted - totalRegularSessions : 0;

      if (sessionsCompleted > totalRegularSessions) { // Deload period (Weeks 13-14)
        if (deloadSessionsCompleted <= deloadSessions) {
          currentWeek = 13 + ((deloadSessionsCompleted - 1) ~/ 3); // Weeks 13-14
          if (currentSession > 3) {
            currentSession = 1;
          }
        }
      } else if (sessionsCompleted <= totalRegularSessions && currentWeek > 12) { // Regular period (Weeks 1-12)
        currentWeek = 12;
        if (currentSession > 3) {
          currentSession = 1;
        }
      }

      program['sessionsCompleted'] = sessionsCompleted;
      program['currentSession'] = currentSession;
      program['currentWeek'] = currentWeek;
      programs[programIndex] = program;
      await savePrograms(programs);
      print('Incremented session for program ID $programId: sessionsCompleted=$sessionsCompleted, currentWeek=$currentWeek, currentSession=$currentSession');
    } else {
      print('Error: Program with ID $programId not found.');
    }
  }

  static double _roundWeight(double weight, String unit) {
    if (unit == 'lbs') {
      return (weight / 5).round() * 5;
    } else {
      return weight.roundToDouble();
    }
  }

  static Future<void> convertProgramWeights(String oldUnit, String newUnit) async {
    final programs = await getPrograms();
    if (programs.isEmpty) return;

    const double kgToLbs = 2.20462;
    const double lbsToKg = 1 / 2.20462;

    for (var program in programs) {
      var details = program['details'] as Map<String, dynamic>;
      String originalUnit = details['originalUnit'] as String? ?? oldUnit; // Fallback to oldUnit
      double original1RM = details['original1RM'] as double? ?? (details['1RM'] as double? ?? 0.0);
      Map<String, dynamic> original1RMs = details['original1RMs'] as Map<String, dynamic>? ?? (details['1RMs'] as Map<String, dynamic>? ?? {});

      print('Attempting to convert program ${program['id']} from $oldUnit to $newUnit, originalUnit: $originalUnit, original1RM: $original1RM, current 1RM: ${details['1RM']}');

      if (oldUnit != newUnit) {
        double conversionFactor;
        if (originalUnit == 'kg' && newUnit == 'lbs') {
          conversionFactor = kgToLbs;
        } else if (originalUnit == 'lbs' && newUnit == 'kg') {
          conversionFactor = lbsToKg;
        } else {
          conversionFactor = 1.0; // No conversion if units mismatch unexpectedly
          print('Warning: No valid conversion factor for program ${program['id']}: originalUnit=$originalUnit, newUnit=$newUnit');
        }

        if (details.containsKey('1RM') && conversionFactor != 1.0) {
          double current1RM = details['1RM'] as double;
          double converted1RM = original1RM * conversionFactor;
          converted1RM = _roundWeight(converted1RM, newUnit);
          print('Before update: 1RM=$current1RM, converted1RM=$converted1RM');
          details['1RM'] = converted1RM;
          details['original1RM'] = converted1RM; // Update original1RM to the new value
          details['originalUnit'] = newUnit; // Update originalUnit to the new unit
          print('After update: 1RM=${details['1RM']}, original1RM=${details['original1RM']}, originalUnit=${details['originalUnit']}');
          print('Converted program ${program['id']} 1RM: $original1RM $originalUnit to $converted1RM $newUnit');
        } else if (details.containsKey('1RM')) {
          print('No conversion applied for program ${program['id']} 1RM: conversionFactor=$conversionFactor');
        }

        if (details.containsKey('1RMs') && conversionFactor != 1.0) {
          var oneRMs = details['1RMs'] as Map<String, dynamic>;
          for (var lift in original1RMs.keys) {
            double value = original1RMs[lift] as double;
            double convertedValue = value * conversionFactor;
            convertedValue = _roundWeight(convertedValue, newUnit);
            oneRMs[lift] = convertedValue;
            print('Converted program ${program['id']} $lift 1RM: $value $originalUnit to $convertedValue $newUnit');
          }
          details['original1RMs'] = oneRMs; // Update original1RMs
          details['originalUnit'] = newUnit; // Update originalUnit
        }

        if (details.containsKey('oneRMIncrement') && conversionFactor != 1.0) {
          double increment = details['oneRMIncrement'] as double;
          double convertedIncrement = increment * conversionFactor;
          convertedIncrement = _roundWeight(convertedIncrement, newUnit);
          details['oneRMIncrement'] = convertedIncrement;
          print('Converted program ${program['id']} oneRMIncrement: $increment $originalUnit to $convertedIncrement $newUnit');
        }
      } else {
        print('No conversion needed for program ${program['id']}: oldUnit ($oldUnit) matches newUnit ($newUnit)');
      }

      details['unit'] = newUnit;
      program['details'] = details;
    }

    await savePrograms(programs);
    print('Converted program weights from $oldUnit to $newUnit');
  }

  static Future<void> convertProgressWeights(String oldUnit, String newUnit) async {
    final progress = await getProgress();
    if (progress.isEmpty) return;

    const double kgToLbs = 2.20462;
    const double lbsToKg = 1 / 2.20462;
    double conversionFactor = oldUnit == 'kg' && newUnit == 'lbs' ? kgToLbs : lbsToKg;

    for (var entry in progress) {
      if (entry['weight'] != null) {
        double weight = entry['weight'] as double;
        double convertedWeight = weight * conversionFactor;
        convertedWeight = _roundWeight(convertedWeight, newUnit);
        entry['weight'] = convertedWeight;
      }
    }
    await saveProgress(progress);
    print('Converted progress weights from $oldUnit to $newUnit');
  }

  static Future<List<Map<String, dynamic>>> getProgramLog(String programId) async {
    final prefs = await _prefs;
    final logJson = prefs.getString(_programLogKeyPrefix + programId);
    if (logJson == null) return [];

    final decodedLog = jsonDecode(logJson) as List;
    final typedLog = decodedLog.map((entry) {
      final typedEntry = (entry as Map).cast<String, dynamic>();
      if (!typedEntry.containsKey('workoutName')) {
        typedEntry['workoutName'] = 'Unknown Workout'; // Add default workoutName for legacy entries
      }
      if (typedEntry.containsKey('sets')) {
        final sets = (typedEntry['sets'] as List?)?.map((set) {
          final typedSet = (set as Map).cast<String, dynamic>();
          if (!typedSet.containsKey('name') || typedSet['name'] == null) {
            typedSet['name'] = 'Unknown Exercise'; // Add default name for legacy set entries
          }
          return typedSet;
        }).toList() ?? [];
        typedEntry['sets'] = sets;
      }
      return typedEntry;
    }).toList();

    // Save updated log entries with workoutName and set names
    await prefs.setString(_programLogKeyPrefix + programId, jsonEncode(typedLog));
    print('Updated program log for program ID $programId with default workoutName and set names for legacy entries');
    return typedLog.cast<Map<String, dynamic>>();
  }

  static Future<void> saveProgramLog(String programId, List<Map<String, dynamic>> log) async {
    final prefs = await _prefs;
    await prefs.setString(_programLogKeyPrefix + programId, jsonEncode(log));
    print('Saved program log for program ID $programId: $log');
  }

  static Future<List<Map<String, dynamic>>> getWorkouts() async {
    final prefs = await _prefs;
    final workoutsJson = prefs.getString(_workoutsKey);
    return workoutsJson != null ? jsonDecode(workoutsJson).cast<Map<String, dynamic>>() : [];
  }

  static Future<List<String>> getSuggestedExercises() async {
    final prefs = await _prefs;
    final exercisesJson = prefs.getString(_suggestedExercisesKey);
    return exercisesJson != null ? jsonDecode(exercisesJson).cast<String>() : [];
  }

  static Future<void> insertWorkout(Map<String, dynamic> workout) async {
    final prefs = await _prefs;
    final workouts = await getWorkouts();
    workouts.add(workout);
    await prefs.setString(_workoutsKey, jsonEncode(workouts));
  }

  static Future<void> deleteWorkout(String workoutId) async {
    final prefs = await _prefs;
    final workouts = await getWorkouts();
    final updatedWorkouts = workouts.where((w) => w['id'] != workoutId).toList();
    await prefs.setString(_workoutsKey, jsonEncode(updatedWorkouts));
  }

  static Future<List<Map<String, dynamic>>> getMeals() async {
    final prefs = await _prefs;
    final mealsJson = prefs.getString(_mealsKey);
    return mealsJson != null ? jsonDecode(mealsJson).cast<Map<String, dynamic>>() : [];
  }

  static Future<void> insertMeal(Map<String, dynamic> meal) async {
    final prefs = await _prefs;
    final meals = await getMeals();
    meals.add(meal);
    await prefs.setString(_mealsKey, jsonEncode(meals));
  }

  static Future<void> deleteMeal(String mealId) async {
    final prefs = await _prefs;
    final meals = await getMeals();
    final updatedMeals = meals.where((m) => m['id'] != mealId).toList();
    await prefs.setString(_mealsKey, jsonEncode(updatedMeals));
  }

  static Future<List<Map<String, dynamic>>> getProgress() async {
    final prefs = await _prefs;
    final progressJson = prefs.getString(_progressKey);
    return progressJson != null ? jsonDecode(progressJson).cast<Map<String, dynamic>>() : [];
  }

  static Future<void> saveProgress(List<Map<String, dynamic>> progress) async {
    final prefs = await _prefs;
    await prefs.setString(_progressKey, jsonEncode(progress));
  }

  static Future<void> insertProgress(Map<String, dynamic> progress) async {
    final prefs = await _prefs;
    final progressList = await getProgress();
    progressList.add(progress);
    await prefs.setString(_progressKey, jsonEncode(progressList));
  }

  static Future<void> deleteProgress(String progressId) async {
    final prefs = await _prefs;
    final progressList = await getProgress();
    final updatedProgress = progressList.where((p) => p['id'] != progressId).toList();
    await prefs.setString(_progressKey, jsonEncode(updatedProgress));
  }

  static Future<String> getWeightUnit() async {
    final prefs = await _prefs;
    await initialize();
    final unit = prefs.getString(_weightUnitKey) ?? 'lbs';
    print('Retrieved weight unit from prefs: $unit');
    return unit;
  }

  static Future<void> setWeightUnit(String unit, {String? currentUnit}) async {
    final prefs = await _prefs;
    final oldUnit = currentUnit ?? await getWeightUnit(); // Use provided currentUnit or fetch from prefs
    print('Setting weight unit from $oldUnit to $unit (currentUnit provided: $currentUnit)');
    if (oldUnit != unit) {
      print('Converting weights from $oldUnit to $unit');
      await convertProgramWeights(oldUnit, unit);
      await convertProgressWeights(oldUnit, unit);
    }
    await prefs.setString(_weightUnitKey, unit);
    print('Set weight unit to: $unit');
  }
}