import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_trainer_app_clean/core/data/models/workout.dart';
import 'package:personal_trainer_app_clean/core/data/repositories/workout_repository.dart';

Future<Map<String, dynamic>?> showLogWorkoutDialog(BuildContext context, List<Map<String, dynamic>> workouts, String unit) async {
  final List<Map<String, dynamic>> loggedExercises = [];
  bool completed = false;

  for (var workout in workouts) {
    final name = workout['name'] as String;
    final sets = workout['sets'] as int;
    final reps = workout['reps'] as int;
    final weight = workout['weight'] as double;
    final List<TextEditingController> repsControllers = List.generate(sets, (index) => TextEditingController(text: reps.toString()));
    final List<TextEditingController> weightControllers = List.generate(sets, (index) => TextEditingController(text: weight.toString()));

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Log $name'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...List.generate(sets, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: repsControllers[index],
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Reps',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: weightControllers[index],
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Weight ($unit)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != true) {
      return null;
    }

    final List<Map<String, dynamic>> setsData = [];
    for (int i = 0; i < sets; i++) {
      final loggedReps = int.tryParse(repsControllers[i].text) ?? reps;
      final loggedWeight = double.tryParse(weightControllers[i].text) ?? weight;
      setsData.add({
        'reps': loggedReps,
        'weight': loggedWeight,
      });
    }

    loggedExercises.add({
      'name': name,
      'sets': sets,
      'reps': setsData.map((set) => set['reps']).toList(),
      'weight': setsData.map((set) => set['weight']).toList(),
    });

    // Dispose controllers
    for (var controller in repsControllers) {
      controller.dispose();
    }
    for (var controller in weightControllers) {
      controller.dispose();
    }
  }

  completed = true;

  final workoutData = {
    'exercises': loggedExercises,
    'completed': completed,
  };

  return workoutData;
}

Future<Map<String, dynamic>?> showAddWorkoutDialog(BuildContext context, String unit) async {
  final TextEditingController exerciseController = TextEditingController();
  final TextEditingController setsController = TextEditingController();
  final TextEditingController repsController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Add Workout'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: exerciseController,
              decoration: InputDecoration(
                labelText: 'Exercise Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: const Color(0xFFB0B7BF),
              ),
              style: GoogleFonts.roboto(
                fontSize: 16,
                color: const Color(0xFF1C2526),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: setsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Sets',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: const Color(0xFFB0B7BF),
              ),
              style: GoogleFonts.roboto(
                fontSize: 16,
                color: const Color(0xFF1C2526),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: repsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Reps',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: const Color(0xFFB0B7BF),
              ),
              style: GoogleFonts.roboto(
                fontSize: 16,
                color: const Color(0xFF1C2526),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Weight ($unit)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: const Color(0xFFB0B7BF),
              ),
              style: GoogleFonts.roboto(
                fontSize: 16,
                color: const Color(0xFF1C2526),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (exerciseController.text.isEmpty ||
                setsController.text.isEmpty ||
                repsController.text.isEmpty ||
                weightController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please fill in all fields')),
              );
              return;
            }
            Navigator.pop(context, true);
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );

  if (result != true) {
    return null;
  }

  final workoutData = {
    'name': exerciseController.text,
    'sets': int.parse(setsController.text),
    'reps': int.parse(repsController.text),
    'weight': double.parse(weightController.text),
  };

  // Dispose controllers
  exerciseController.dispose();
  setsController.dispose();
  repsController.dispose();
  weightController.dispose();

  return workoutData;
}

Future<Map<String, dynamic>?> showEditWorkoutDialog(BuildContext context, String programId, Workout workout, String unit) async {
  final workoutRepository = WorkoutRepository();
  final TextEditingController exerciseController = TextEditingController(text: workout.name);
  final List<Map<String, dynamic>> loggedExercises = [];
  bool completed = false;

  for (var exercise in workout.exercises) {
    final name = exercise['name'] as String;
    final sets = exercise['sets'] as int;
    final List<dynamic> repsList = exercise['reps'] as List<dynamic>;
    final List<dynamic> weightList = exercise['weight'] as List<dynamic>;
    final List<TextEditingController> repsControllers = List.generate(sets, (index) => TextEditingController(text: repsList[index].toString()));
    final List<TextEditingController> weightControllers = List.generate(sets, (index) => TextEditingController(text: weightList[index].toString()));

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $name'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...List.generate(sets, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: repsControllers[index],
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Reps',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: weightControllers[index],
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Weight ($unit)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != true) {
      return null;
    }

    final List<Map<String, dynamic>> setsData = [];
    for (int i = 0; i < sets; i++) {
      final loggedReps = int.tryParse(repsControllers[i].text) ?? repsList[i] as int;
      final loggedWeight = double.tryParse(weightControllers[i].text) ?? weightList[i] as double;
      setsData.add({
        'reps': loggedReps,
        'weight': loggedWeight,
      });
    }

    loggedExercises.add({
      'name': name,
      'sets': sets,
      'reps': setsData.map((set) => set['reps']).toList(),
      'weight': setsData.map((set) => set['weight']).toList(),
    });

    // Dispose controllers
    for (var controller in repsControllers) {
      controller.dispose();
    }
    for (var controller in weightControllers) {
      controller.dispose();
    }
  }

  completed = true;

  final workoutData = {
    'exercises': loggedExercises,
    'completed': completed,
  };

  final updatedWorkout = Workout(
    id: workout.id,
    programId: programId,
    name: exerciseController.text,
    exercises: loggedExercises,
    timestamp: workout.timestamp,
  );

  await workoutRepository.updateWorkout(programId, updatedWorkout);

  exerciseController.dispose();

  return workoutData;
}