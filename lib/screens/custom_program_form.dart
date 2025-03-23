import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_trainer_app_clean/core/data/models/program.dart';
import 'package:personal_trainer_app_clean/core/data/repositories/program_repository.dart';
import 'package:personal_trainer_app_clean/main.dart';
import 'package:personal_trainer_app_clean/screens/program_details_widgets.dart';
import 'package:personal_trainer_app_clean/screens/program_selection_screen.dart' as programs;
import 'package:personal_trainer_app_clean/widgets/common/app_snack_bar.dart';
import 'package:uuid/uuid.dart';

class CustomProgramForm extends StatefulWidget {
  const CustomProgramForm({super.key});

  @override
  _CustomProgramFormState createState() => _CustomProgramFormState();
}

class _CustomProgramFormState extends State<CustomProgramForm> {
  final ProgramRepository _programRepository = ProgramRepository();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final List<Map<String, TextEditingController>> _exercises = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _addExercise();
  }

  void _addExercise() {
    setState(() {
      _exercises.add({
        'name': TextEditingController(),
        'sets': TextEditingController(),
        'reps': TextEditingController(),
        'weight': TextEditingController(),
      });
    });
  }

  Future<void> _saveProgram() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final programId = Uuid().v4();
      final startDate = DateTime.now().toIso8601String().split('T')[0];
      final exercises = _exercises.map((exercise) {
        return {
          'name': exercise['name']!.text,
          'sets': int.tryParse(exercise['sets']!.text) ?? 0,
          'reps': int.tryParse(exercise['reps']!.text) ?? 0,
          'weight': double.tryParse(exercise['weight']!.text) ?? 0.0,
        };
      }).toList();

      final newProgram = Program(
        id: programId,
        name: _nameController.text,
        description: _descriptionController.text,
        oneRMs: {},
        details: {
          'unit': unitNotifier.value, // Use the current unit
          'exercises': exercises,
        },
        completed: false,
        startDate: startDate,
        currentWeek: 1,
        currentSession: 1,
        sessionsCompleted: 0,
      );

      await _programRepository.insertProgram(newProgram);
      AppSnackBar.showSuccess(context, 'Custom program created successfully!');
      // Navigate back to ProgramSelectionScreen by updating childScreenNotifier
      childScreenNotifier.value = const programs.ProgramSelectionScreen();
    } catch (e) {
      AppSnackBar.showError(context, 'Failed to create program: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    for (var exercise in _exercises) {
      exercise['name']!.dispose();
      exercise['sets']!.dispose();
      exercise['reps']!.dispose();
      exercise['weight']!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Custom Program'),
        backgroundColor: const Color(0xFF1C2526),
        foregroundColor: const Color(0xFFB0B7BF),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFB0B7BF)),
          onPressed: () {
            // Navigate back to ProgramSelectionScreen by updating childScreenNotifier
            childScreenNotifier.value = const programs.ProgramSelectionScreen();
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [const Color(0xFF87CEEB).withOpacity(0.2), const Color(0xFF1C2526)],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ExerciseInputWidget(
                  controller: _nameController,
                  label: 'Program Name',
                ),
                ExerciseInputWidget(
                  controller: _descriptionController,
                  label: 'Description',
                ),
                const SizedBox(height: 16),
                Text(
                  'Exercises',
                  style: GoogleFonts.oswald(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFB22222),
                  ),
                ),
                const SizedBox(height: 8),
                ..._exercises.asMap().entries.map((entry) {
                  final index = entry.key;
                  final exercise = entry.value;
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          ExerciseInputWidget(
                            controller: exercise['name']!,
                            label: 'Exercise ${index + 1} Name',
                          ),
                          ExerciseInputWidget(
                            controller: exercise['sets']!,
                            label: 'Sets',
                            isNumeric: true,
                          ),
                          ExerciseInputWidget(
                            controller: exercise['reps']!,
                            label: 'Reps',
                            isNumeric: true,
                          ),
                          ExerciseInputWidget(
                            controller: exercise['weight']!,
                            label: 'Weight',
                            isNumeric: true,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add Exercise'),
                  onPressed: _addExercise,
                ),
                const SizedBox(height: 16),
                Center(
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Color(0xFFB22222))
                      : ElevatedButton(
                    onPressed: _saveProgram,
                    child: const Text('Save Program'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}