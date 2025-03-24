import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_trainer_app_clean/core/data/models/program.dart';
import 'package:personal_trainer_app_clean/core/data/repositories/program_repository.dart';
import 'package:personal_trainer_app_clean/main.dart';
import 'package:personal_trainer_app_clean/screens/program_details_widgets.dart'; // Changed import to program_details_widgets.dart
import 'package:personal_trainer_app_clean/screens/programs_overview_screen.dart';
import 'package:personal_trainer_app_clean/utils/cross_painter.dart';
import 'package:personal_trainer_app_clean/widgets/common/app_snack_bar.dart';

class CustomProgramForm extends StatefulWidget {
  const CustomProgramForm({super.key});

  @override
  _CustomProgramFormState createState() => _CustomProgramFormState();
}

class _CustomProgramFormState extends State<CustomProgramForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final ProgramRepository _programRepository = ProgramRepository();
  final List<Map<String, dynamic>> _exercises = [];
  final Map<String, dynamic> _oneRMs = {};
  String _unit = 'lbs';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _addExercise() {
    setState(() {
      _exercises.add({
        'name': TextEditingController(),
        'sets': TextEditingController(),
        'reps': TextEditingController(),
        'week': TextEditingController(),
        'day': TextEditingController(),
      });
    });
  }

  void _removeExercise(int index) {
    setState(() {
      _exercises.removeAt(index);
    });
  }

  Future<void> _saveProgram() async {
    if (_formKey.currentState!.validate()) {
      final programName = _nameController.text;
      final List<Map<String, dynamic>> workouts = [];
      for (int i = 0; i < _exercises.length; i++) {
        final exercise = _exercises[i];
        workouts.add({
          'name': exercise['name'].text as String,
          'sets': int.parse(exercise['sets'].text as String),
          'reps': int.parse(exercise['reps'].text as String),
          'week': int.parse(exercise['week'].text as String),
          'day': int.parse(exercise['day'].text as String),
        });
      }

      final program = Program(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: programName,
        details: {
          'unit': _unit,
        },
        oneRMs: _oneRMs,
        currentWeek: 1,
        currentSession: 1,
        sessionsCompleted: 0,
        startDate: DateTime.now().toIso8601String(),
        workouts: workouts,
      );

      await _programRepository.insertProgram(program);
      AppSnackBar.showSuccess(context, 'Program created successfully!');
      childScreenNotifier.value = const ProgramsOverviewScreen(programName: '');
    }
  }

  Future<void> _setOneRMs() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => OneRMDialog(),
    );

    if (result != null) {
      setState(() {
        _oneRMs
          ..clear()
          ..addAll(result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Color>(
      valueListenable: accentColorNotifier,
      builder: (context, accentColor, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [const Color(0xFF87CEEB).withOpacity(0.2), const Color(0xFF1C2526)],
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: 0.1,
                  child: CustomPaint(
                    painter: CrossPainter(),
                    child: Container(),
                  ),
                ),
              ),
              Scaffold(
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  title: const Text('Create Custom Program'),
                  backgroundColor: const Color(0xFF1C2526),
                  foregroundColor: const Color(0xFFB0B7BF),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFFB0B7BF)),
                    onPressed: () {
                      childScreenNotifier.value = const ProgramsOverviewScreen(programName: '');
                    },
                  ),
                ),
                body: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Program Name',
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
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a program name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Set 1RMs',
                                style: GoogleFonts.oswald(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: accentColor,
                                ),
                              ),
                              ElevatedButton(
                                onPressed: _setOneRMs,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: accentColor,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Set 1RMs'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Exercises',
                            style: GoogleFonts.oswald(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: accentColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ..._exercises.asMap().entries.map((entry) {
                            final index = entry.key;
                            final exercise = entry.value;
                            return Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              color: const Color(0xFFB0B7BF),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Exercise ${index + 1}',
                                          style: GoogleFonts.roboto(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF1C2526),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          onPressed: () => _removeExercise(index),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    ExerciseInputWidget(
                                      controller: exercise['name'],
                                      label: 'Exercise Name',
                                      isNumeric: false,
                                    ),
                                    ExerciseInputWidget(
                                      controller: exercise['sets'],
                                      label: 'Sets',
                                      isNumeric: true,
                                    ),
                                    ExerciseInputWidget(
                                      controller: exercise['reps'],
                                      label: 'Reps',
                                      isNumeric: true,
                                    ),
                                    ExerciseInputWidget(
                                      controller: exercise['week'],
                                      label: 'Week',
                                      isNumeric: true,
                                    ),
                                    ExerciseInputWidget(
                                      controller: exercise['day'],
                                      label: 'Day',
                                      isNumeric: true,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                          const SizedBox(height: 16),
                          Center(
                            child: ElevatedButton(
                              onPressed: _addExercise,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accentColor,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Add Exercise'),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: ElevatedButton(
                              onPressed: _saveProgram,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accentColor,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Save Program'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}