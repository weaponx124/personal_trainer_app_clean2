import 'package:flutter/material.dart'; // Added for ThemeMode
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'package:personal_trainer_app_clean/main.dart'; // Import to access unitNotifier and themeNotifier

class DatabaseHelper {
  static const String _programsKey = 'programs';
  static const String _programLogKeyPrefix = 'programLog_';
  static const String _workoutsKey = 'workouts';
  static const String _suggestedExercisesKey = 'suggestedExercises';
  static const String _mealsKey = 'meals';
  static const String _progressKey = 'progress';
  static const String _weightUnitKey = 'weightUnit';
  static const String _themeModeKey = 'themeMode';
  static const String _weeklyWorkoutGoalKey = 'weeklyWorkoutGoal'; // Added for weekly goal
  static const String _milestoneCelebratedKey = 'milestoneCelebrated'; // Added for milestone tracking
  static const String _milestoneWeekKey = 'milestoneWeek'; // Added to track the week of the last celebration
  static const String _verseOfTheDayKey = 'verseOfTheDay'; // Added for verse of the day
  static const String _verseOfTheDayDateKey = 'verseOfTheDayDate'; // Added to track the date of the verse
  static const String _dietPreferencesKey = 'dietPreferences'; // Added for diet preferences
  static const String _waterIntakeKey = 'waterIntake'; // Added for water intake
  static const String _customFoodsKey = 'customFoods'; // Added for custom foods

  static Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  static Future<void> initialize() async {
    final prefs = await _prefs;
    await prefs.remove(_weightUnitKey); // Reset for testing
    if (!prefs.containsKey(_weightUnitKey)) {
      await prefs.setString(_weightUnitKey, 'lbs');
      print('Initialized default weight unit to lbs');
    }
    if (!prefs.containsKey(_themeModeKey)) {
      await prefs.setString(_themeModeKey, 'system');
      print('Initialized default theme mode to system');
    }
    if (!prefs.containsKey(_weeklyWorkoutGoalKey)) {
      await prefs.setInt(_weeklyWorkoutGoalKey, 3); // Default weekly goal: 3 workouts
      print('Initialized default weekly workout goal to 3');
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

      const totalRegularSessions = 36; // 12 weeks * 3 sessions per week
      const deloadSessions = 6; // 2 weeks * 3 sessions per week
      const totalProgramSessions = totalRegularSessions + deloadSessions; // 42 sessions

      if (sessionsCompleted >= totalProgramSessions - 1) { // Complete at 42 sessions
        program['completed'] = true;
        program['currentWeek'] = 14; // Final week
        program['currentSession'] = 3; // Final session of Week 14
        program['sessionsCompleted'] = totalProgramSessions;
        programs[programIndex] = program;
        await savePrograms(programs);
        print('Program completed after deload period for program ID $programId');
        return;
      }

      sessionsCompleted += 1;
      currentSession += 1;

      if (currentSession > 3) {
        currentSession = 1;
        currentWeek += 1;
      }

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

  static Future<void> convertProgramWeights(String oldUnit, String unit) async {
    final programs = await getPrograms();
    if (programs.isEmpty) return;

    const double kgToLbs = 2.20462;
    const double lbsToKg = 1 / 2.20462;

    for (var program in programs) {
      var details = program['details'] as Map<String, dynamic>;
      String originalUnit = details['originalUnit'] as String? ?? oldUnit;
      double original1RM = details['original1RM'] as double? ?? (details['1RM'] as double? ?? 0.0);
      Map<String, dynamic> original1RMs = details['original1RMs'] as Map<String, dynamic>? ?? (details['1RMs'] as Map<String, dynamic>? ?? {});

      print('Attempting to convert program ${program['id']} from $oldUnit to $unit, originalUnit: $originalUnit, original1RM: $original1RM, current 1RM: ${details['1RM']}');

      if (oldUnit != unit) {
        double conversionFactor;
        if (originalUnit == 'kg' && unit == 'lbs') {
          conversionFactor = kgToLbs;
        } else if (originalUnit == 'lbs' && unit == 'kg') {
          conversionFactor = lbsToKg;
        } else {
          conversionFactor = 1.0;
          print('Warning: No valid conversion factor for program ${program['id']}: originalUnit=$originalUnit, unit=$unit');
        }

        if (details.containsKey('1RM') && conversionFactor != 1.0) {
          double current1RM = details['1RM'] as double;
          double converted1RM = original1RM * conversionFactor;
          converted1RM = _roundWeight(converted1RM, unit);
          print('Before update: 1RM=$current1RM, converted1RM=$converted1RM');
          details['1RM'] = converted1RM;
          details['original1RM'] = converted1RM;
          details['originalUnit'] = unit;
          print('After update: 1RM=${details['1RM']}, original1RM=${details['original1RM']}, originalUnit=${details['originalUnit']}');
          print('Converted program ${program['id']} 1RM: $original1RM $originalUnit to $converted1RM $unit');
        } else if (details.containsKey('1RM')) {
          print('No conversion applied for program ${program['id']} 1RM: conversionFactor=$conversionFactor');
        }

        if (details.containsKey('1RMs') && conversionFactor != 1.0) {
          var oneRMs = details['1RMs'] as Map<String, dynamic>;
          for (var lift in original1RMs.keys) {
            double value = original1RMs[lift] as double;
            double convertedValue = value * conversionFactor;
            convertedValue = _roundWeight(convertedValue, unit);
            oneRMs[lift] = convertedValue;
            print('Converted program ${program['id']} $lift 1RM: $value $originalUnit to $convertedValue $unit');
          }
          details['original1RMs'] = oneRMs;
          details['originalUnit'] = unit;
        }

        if (details.containsKey('oneRMIncrement') && conversionFactor != 1.0) {
          double increment = details['oneRMIncrement'] as double;
          double convertedIncrement = increment * conversionFactor;
          convertedIncrement = _roundWeight(convertedIncrement, unit);
          details['oneRMIncrement'] = convertedIncrement;
          print('Converted program ${program['id']} oneRMIncrement: $increment $originalUnit to $convertedIncrement $unit');
        }
      } else {
        print('No conversion needed for program ${program['id']}: oldUnit ($oldUnit) matches unit ($unit)');
      }

      details['unit'] = unit;
      program['details'] = details;
    }

    await savePrograms(programs);
    print('Converted program weights from $oldUnit to $unit');
  }

  static Future<void> convertProgressWeights(String oldUnit, String unit) async {
    final progress = await getProgress();
    if (progress.isEmpty) return;

    const double kgToLbs = 2.20462;
    const double lbsToKg = 1 / 2.20462;
    double conversionFactor = oldUnit == 'kg' && unit == 'lbs' ? kgToLbs : lbsToKg;

    for (var entry in progress) {
      if (entry['weight'] != null) {
        double weight = entry['weight'] as double;
        double convertedWeight = weight * conversionFactor;
        convertedWeight = _roundWeight(convertedWeight, unit);
        entry['weight'] = convertedWeight;
      }
    }
    await saveProgress(progress);
    print('Converted progress weights from $oldUnit to $unit');
  }

  static Future<List<Map<String, dynamic>>> getProgramLog(String programId) async {
    final prefs = await _prefs;
    final logJson = prefs.getString(_programLogKeyPrefix + programId);
    if (logJson == null) return [];

    final decodedLog = jsonDecode(logJson) as List;
    final typedLog = decodedLog.map((entry) {
      final typedEntry = (entry as Map).cast<String, dynamic>();
      if (!typedEntry.containsKey('workoutName')) {
        typedEntry['workoutName'] = 'Unknown Workout';
      }
      if (typedEntry.containsKey('sets')) {
        final sets = (typedEntry['sets'] as List?)?.map((set) {
          final typedSet = (set as Map).cast<String, dynamic>();
          if (!typedSet.containsKey('name') || typedSet['name'] == null) {
            typedSet['name'] = 'Unknown Exercise';
          }
          return typedSet;
        }).toList() ?? [];
        typedEntry['sets'] = sets;
      }
      return typedEntry;
    }).toList();

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
    final workoutWithId = Map<String, dynamic>.from(workout);
    workoutWithId['id'] = Uuid().v4();
    workouts.add(workoutWithId);
    await prefs.setString(_workoutsKey, jsonEncode(workouts));
    print('Inserted workout: $workoutWithId');
  }

  static Future<void> deleteWorkout(String workoutId) async {
    final prefs = await _prefs;
    final workouts = await getWorkouts();
    final updatedWorkouts = workouts.where((w) => w['id'] != workoutId).toList();
    await prefs.setString(_workoutsKey, jsonEncode(updatedWorkouts));
    print('Deleted workout with ID: $workoutId');
  }

  static Future<List<Map<String, dynamic>>> getMeals() async {
    final prefs = await _prefs;
    final mealsJson = prefs.getString(_mealsKey);
    return mealsJson != null ? jsonDecode(mealsJson).cast<Map<String, dynamic>>() : [];
  }

  static Future<void> insertMeal(Map<String, dynamic> meal) async {
    final prefs = await _prefs;
    final meals = await getMeals();
    final mealWithId = Map<String, dynamic>.from(meal);
    mealWithId['id'] = Uuid().v4();
    meals.add(mealWithId);
    await prefs.setString(_mealsKey, jsonEncode(meals));
    print('Inserted meal: $mealWithId');
  }

  static Future<void> deleteMeal(String mealId) async {
    final prefs = await _prefs;
    final meals = await getMeals();
    final updatedMeals = meals.where((m) => m['id'] != mealId).toList();
    await prefs.setString(_mealsKey, jsonEncode(updatedMeals));
    print('Deleted meal with ID: $mealId');
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
    final oldUnit = currentUnit ?? await getWeightUnit();
    print('Setting weight unit from $oldUnit to $unit (currentUnit provided: $currentUnit)');
    if (oldUnit != unit) {
      print('Converting weights from $oldUnit to $unit');
      await convertProgramWeights(oldUnit, unit);
      await convertProgressWeights(oldUnit, unit);
    }
    await prefs.setString(_weightUnitKey, unit);
    print('Set weight unit to: $unit');
    unitNotifier.value = unit; // Now accessible due to import
  }

  static Future<List<Map<String, dynamic>>> getWorkoutsForWeek(DateTime startOfWeek, DateTime endOfWeek) async {
    final workouts = await getWorkouts();
    final startTimestamp = startOfWeek.millisecondsSinceEpoch;
    final endTimestamp = endOfWeek.millisecondsSinceEpoch;
    final weeklyWorkouts = workouts.where((workout) {
      final timestamp = workout['timestamp'] as int?;
      if (timestamp == null) {
        print('Skipping workout with null timestamp: $workout'); // Debug log
        return false;
      }
      return timestamp >= startTimestamp && timestamp <= endTimestamp;
    }).toList();
    print('Workouts for week ${startOfWeek.toIso8601String()} to ${endOfWeek.toIso8601String()}: $weeklyWorkouts'); // Debug log
    return weeklyWorkouts;
  }

  static Future<void> setWeeklyWorkoutGoal(int goal) async {
    final prefs = await _prefs;
    await prefs.setInt(_weeklyWorkoutGoalKey, goal);
    print('Set weekly workout goal to: $goal');
  }

  static Future<int> getWeeklyWorkoutGoal() async {
    final prefs = await _prefs;
    return prefs.getInt(_weeklyWorkoutGoalKey) ?? 3; // Default to 3 if not set
  }

  static Future<bool> hasCelebratedMilestoneThisWeek(DateTime startOfWeek) async {
    final prefs = await _prefs;
    final lastCelebratedWeek = prefs.getString(_milestoneWeekKey);
    final currentWeek = startOfWeek.toIso8601String().split('T')[0]; // Use date as week identifier
    if (lastCelebratedWeek == currentWeek) {
      return prefs.getBool(_milestoneCelebratedKey) ?? false;
    }
    return false;
  }

  static Future<void> setCelebratedMilestoneThisWeek(DateTime startOfWeek, bool celebrated) async {
    final prefs = await _prefs;
    final currentWeek = startOfWeek.toIso8601String().split('T')[0];
    await prefs.setString(_milestoneWeekKey, currentWeek);
    await prefs.setBool(_milestoneCelebratedKey, celebrated);
    print('Set milestone celebrated for week $currentWeek: $celebrated');
  }

  static Future<Map<String, dynamic>?> getVerseOfTheDay() async {
    final prefs = await _prefs;
    final verseJson = prefs.getString(_verseOfTheDayKey);
    final verseDate = prefs.getString(_verseOfTheDayDateKey);
    final currentDate = DateTime.now().toIso8601String().split('T')[0];

    if (verseJson != null && verseDate == currentDate) {
      return jsonDecode(verseJson) as Map<String, dynamic>;
    }
    return null;
  }

  static Future<void> setVerseOfTheDay(Map<String, dynamic> verse) async {
    final prefs = await _prefs;
    final currentDate = DateTime.now().toIso8601String().split('T')[0];
    await prefs.setString(_verseOfTheDayKey, jsonEncode(verse));
    await prefs.setString(_verseOfTheDayDateKey, currentDate);
    print('Set verse of the day for $currentDate: $verse');
  }

  static Future<List<Map<String, dynamic>>> getAllPrograms() async {
    // Static list matching ProgramSelectionScreen for duration reference
    return [
      {'name': '5/3/1 Program', 'duration': 'Ongoing', 'requires1RM': true, 'lifts': ['Squat', 'Bench', 'Deadlift', 'Overhead']},
      {'name': 'Texas Method', 'duration': 'Ongoing', 'requires1RM': true, 'lifts': ['Squat', 'Bench', 'Deadlift']},
      {'name': 'Madcow 5x5', 'duration': '12-16 weeks', 'requires1RM': true, 'lifts': ['Squat', 'Bench', 'Deadlift']},
      {'name': 'Sheiko Beginner', 'duration': '8-12 weeks', 'requires1RM': true, 'lifts': ['Squat', 'Bench', 'Deadlift']},
      {'name': 'Sheiko Intermediate', 'duration': '8-12 weeks', 'requires1RM': true, 'lifts': ['Squat', 'Bench', 'Deadlift']},
      {'name': 'Sheiko Advanced', 'duration': '8-12 weeks', 'requires1RM': true, 'lifts': ['Squat', 'Bench', 'Deadlift']},
      {'name': 'Smolov Base Cycle', 'duration': '13 weeks', 'requires1RM': true, 'lifts': ['Squat']},
      {'name': 'Smolov Jr. (Bench)', 'duration': '3-4 weeks', 'requires1RM': true, 'lifts': ['Bench']},
      {'name': 'Candito 6-Week Program', 'duration': '6 weeks', 'requires1RM': true, 'lifts': ['Squat', 'Bench', 'Deadlift']},
      {'name': 'Push/Pull/Legs (PPL)', 'duration': 'Ongoing', 'requires1RM': false},
      {'name': 'Arnold Split', 'duration': 'Ongoing', 'requires1RM': false},
      {'name': 'Bro Split', 'duration': 'Ongoing', 'requires1RM': false},
      {'name': 'PHUL', 'duration': 'Ongoing', 'requires1RM': true, 'lifts': ['Squat', 'Bench', 'Deadlift']},
      {'name': 'PHAT', 'duration': 'Ongoing', 'requires1RM': true, 'lifts': ['Squat', 'Bench', 'Deadlift']},
      {'name': 'German Volume Training', 'duration': '4-6 weeks', 'requires1RM': true, 'lifts': ['Squat', 'Bench', 'Deadlift']},
      {'name': 'Starting Strength', 'duration': '3-6 months', 'requires1RM': false},
      {'name': 'StrongLifts 5x5', 'duration': '3-6 months', 'requires1RM': false},
      {'name': 'Greyskull LP', 'duration': '3-6 months', 'requires1RM': false},
      {'name': 'Full Body 3x/Week', 'duration': 'Ongoing', 'requires1RM': false},
      {'name': 'Couch to 5K', 'duration': '9 weeks', 'requires1RM': false},
      {'name': 'Bodyweight Fitness', 'duration': 'Ongoing', 'requires1RM': false},
      {'name': 'Russian Squat Program', 'duration': '6 weeks', 'requires1RM': true, 'lifts': ['Squat']},
      {'name': 'Super Squats', 'duration': '6 weeks', 'requires1RM': true, 'lifts': ['Squat']},
      {'name': '30-Day Squat Challenge', 'duration': '30 days', 'requires1RM': false},
      {'name': 'Bench Press Specialization', 'duration': '3 weeks', 'requires1RM': true, 'lifts': ['Bench']},
      {'name': 'Deadlift Builder', 'duration': '6 weeks', 'requires1RM': true, 'lifts': ['Deadlift']},
      {'name': 'Arm Blaster', 'duration': '4 weeks', 'requires1RM': false},
      {'name': 'Shoulder Sculptor', 'duration': '6 weeks', 'requires1RM': false},
      {'name': 'Pull-Up Progression', 'duration': '6 weeks', 'requires1RM': false},
    ];
  }

  static Future<ThemeMode> getThemeMode() async {
    final prefs = await _prefs;
    final mode = prefs.getString(_themeModeKey) ?? 'system';
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  static Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await _prefs;
    String modeString;
    switch (mode) {
      case ThemeMode.light:
        modeString = 'light';
        break;
      case ThemeMode.dark:
        modeString = 'dark';
        break;
      case ThemeMode.system:
      default:
        modeString = 'system';
        break;
    }
    await prefs.setString(_themeModeKey, modeString);
    print('Set theme mode to: $modeString');
    themeNotifier.value = mode; // Now accessible due to import
  }

  // Diet Preferences Management
  static Future<Map<String, dynamic>> getDietPreferences() async {
    final prefs = await _prefs;
    final preferencesJson = prefs.getString(_dietPreferencesKey);
    return preferencesJson != null ? jsonDecode(preferencesJson) as Map<String, dynamic> : {
      'goal': 'maintain', // Options: lose, gain, maintain
      'dietaryPreference': 'none', // Options: none, vegan, vegetarian, low-carb, high-protein
      'calorieGoal': 2000, // Default calorie goal
      'macroGoals': {'protein': 25, 'carbs': 50, 'fat': 25}, // Default macro percentages
      'allergies': [] // List of allergies (e.g., ['peanuts', 'dairy'])
    };
  }

  static Future<void> setDietPreferences(Map<String, dynamic> preferences) async {
    final prefs = await _prefs;
    await prefs.setString(_dietPreferencesKey, jsonEncode(preferences));
    print('Set diet preferences: $preferences');
  }

  // Water Intake Management
  static Future<List<Map<String, dynamic>>> getWaterIntake() async {
    final prefs = await _prefs;
    final waterIntakeJson = prefs.getString(_waterIntakeKey);
    return waterIntakeJson != null ? jsonDecode(waterIntakeJson).cast<Map<String, dynamic>>() : [];
  }

  static Future<void> addWaterIntake(double amount) async {
    final prefs = await _prefs;
    final waterIntake = await getWaterIntake();
    final entry = {
      'id': Uuid().v4(),
      'amount': amount,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    waterIntake.add(entry);
    await prefs.setString(_waterIntakeKey, jsonEncode(waterIntake));
    print('Added water intake: $entry');
  }

  static Future<void> clearWaterIntake() async {
    final prefs = await _prefs;
    await prefs.setString(_waterIntakeKey, jsonEncode([]));
    print('Cleared water intake');
  }

  // Custom Foods Management
  static Future<List<Map<String, dynamic>>> getCustomFoods() async {
    final prefs = await _prefs;
    final customFoodsJson = prefs.getString(_customFoodsKey);
    return customFoodsJson != null ? jsonDecode(customFoodsJson).cast<Map<String, dynamic>>() : [];
  }

  static Future<void> addCustomFood(Map<String, dynamic> food) async {
    final prefs = await _prefs;
    final customFoods = await getCustomFoods();
    final foodWithId = Map<String, dynamic>.from(food);
    foodWithId['id'] = Uuid().v4();
    customFoods.add(foodWithId);
    await prefs.setString(_customFoodsKey, jsonEncode(customFoods));
    print('Added custom food: $foodWithId');
  }

  static Future<void> deleteCustomFood(String foodId) async {
    final prefs = await _prefs;
    final customFoods = await getCustomFoods();
    final updatedFoods = customFoods.where((f) => f['id'] != foodId).toList();
    await prefs.setString(_customFoodsKey, jsonEncode(updatedFoods));
    print('Deleted custom food with ID: $foodId');
  }
}