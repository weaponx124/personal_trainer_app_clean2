import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_trainer_app_clean/core/data/models/program.dart';
import 'package:personal_trainer_app_clean/core/data/models/workout.dart';
import 'package:personal_trainer_app_clean/core/data/repositories/workout_repository.dart';
import 'package:personal_trainer_app_clean/main.dart'; // For unitNotifier

void showWorkoutDetailsDialog(
    BuildContext context,
    Map<String, dynamic> workout,
    String unit,
    Function refreshCallback,
    ) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        workout['name'] ?? 'Workout Details',
        style: GoogleFonts.oswald(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: const Color(0xFFB22222),
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (workout['exercises'] != null && workout['exercises'].isNotEmpty)
              ...workout['exercises'].map<Widget>((exercise) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    '${exercise['name']}: ${exercise['sets']} sets x ${exercise['reps']} reps @ ${exercise['weight']} $unit',
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      color: const Color(0xFF1C2526),
                    ),
                  ),
                );
              }).toList()
            else
              Text(
                'No exercises logged for this workout.',
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  color: const Color(0xFF808080),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

void showAddExerciseDialog(
    BuildContext context,
    String programId,
    String workoutId,
    String unit,
    Function refreshCallback,
    ) {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController setsController = TextEditingController();
  final TextEditingController repsController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        'Add Exercise',
        style: GoogleFonts.oswald(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: const Color(0xFFB22222),
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Exercise Name',
                labelStyle: GoogleFonts.roboto(
                  fontSize: 16,
                  color: const Color(0xFF808080),
                ),
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
                labelStyle: GoogleFonts.roboto(
                  fontSize: 16,
                  color: const Color(0xFF808080),
                ),
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
                labelStyle: GoogleFonts.roboto(
                  fontSize: 16,
                  color: const Color(0xFF808080),
                ),
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
                labelStyle: GoogleFonts.roboto(
                  fontSize: 16,
                  color: const Color(0xFF808080),
                ),
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
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            if (nameController.text.isNotEmpty &&
                setsController.text.isNotEmpty &&
                repsController.text.isNotEmpty &&
                weightController.text.isNotEmpty) {
              final exercise = {
                'name': nameController.text,
                'sets': int.tryParse(setsController.text) ?? 0,
                'reps': int.tryParse(repsController.text) ?? 0,
                'weight': double.tryParse(weightController.text) ?? 0.0,
              };

              final workoutRepository = WorkoutRepository();
              final workouts = await workoutRepository.getWorkouts(programId);
              final workoutIndex = workouts.indexWhere((w) => w.id == workoutId);
              if (workoutIndex != -1) {
                final workout = workouts[workoutIndex];
                final updatedExercises = List<Map<String, dynamic>>.from(workout.exercises ?? [])..add(exercise);
                final updatedWorkout = Workout(
                  id: workout.id,
                  programId: workout.programId,
                  name: workout.name,
                  exercises: updatedExercises,
                  timestamp: workout.timestamp,
                );
                await workoutRepository.updateWorkout(programId, updatedWorkout);
                refreshCallback();
                Navigator.pop(context);
              } else {
                // If the workout doesn't exist, create a new one
                final newWorkout = Workout(
                  id: workoutId,
                  programId: programId,
                  name: 'Custom Workout',
                  exercises: [exercise],
                  timestamp: DateTime.now().millisecondsSinceEpoch,
                );
                await workoutRepository.insertWorkout(programId, newWorkout);
                refreshCallback();
                Navigator.pop(context);
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please fill in all fields')),
              );
            }
          },
          child: const Text('Add'),
        ),
      ],
    ),
  );
}

// Added missing methods
Future<void> showUpdate1RMsDialog(
    BuildContext context, Program program, Function(Program) onUpdate) async {
  final unit = unitNotifier.value; // Use unitNotifier directly
  final controllers = <String, TextEditingController>{};
  program.oneRMs.forEach((key, value) {
    controllers[key] = TextEditingController(text: value.toString());
  });

  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        'Update 1RMs ($unit)',
        style: GoogleFonts.oswald(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: const Color(0xFFB22222),
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: program.oneRMs.keys.map((lift) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: TextField(
                controller: controllers[lift],
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: '$lift 1RM',
                  labelStyle: GoogleFonts.roboto(
                    fontSize: 14,
                    color: const Color(0xFF808080),
                  ),
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
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final updated1RMs = <String, double>{};
            controllers.forEach((lift, controller) {
              updated1RMs[lift] = double.tryParse(controller.text) ?? program.oneRMs[lift];
            });
            final updatedProgram = Program(
              id: program.id,
              name: program.name,
              description: program.description,
              oneRMs: updated1RMs,
              details: program.details,
              completed: program.completed,
              startDate: program.startDate,
              currentWeek: program.currentWeek,
              currentSession: program.currentSession,
              sessionsCompleted: program.sessionsCompleted,
            );
            onUpdate(updatedProgram);
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );

  controllers.forEach((key, controller) => controller.dispose());
}

Future<void> showEndProgramDialog(
    BuildContext context, Program program, Function(Program) onUpdate) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        'End Program',
        style: GoogleFonts.oswald(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: const Color(0xFFB22222),
        ),
      ),
      content: Text(
        'Are you sure you want to end this program? This action cannot be undone.',
        style: GoogleFonts.roboto(
          fontSize: 14,
          color: const Color(0xFF808080),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('End'),
        ),
      ],
    ),
  );

  if (confirm == true) {
    final updatedProgram = Program(
      id: program.id,
      name: program.name,
      description: program.description,
      oneRMs: program.oneRMs,
      details: program.details,
      completed: true,
      startDate: program.startDate,
      currentWeek: program.currentWeek,
      currentSession: program.currentSession,
      sessionsCompleted: program.sessionsCompleted,
    );
    onUpdate(updatedProgram);
  }
}