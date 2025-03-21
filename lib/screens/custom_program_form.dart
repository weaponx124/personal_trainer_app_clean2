import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_trainer_app_clean/core/data/models/program.dart';
import 'package:personal_trainer_app_clean/core/data/repositories/program_repository.dart';

class CustomProgramForm extends StatefulWidget {
  const CustomProgramForm({super.key});

  @override
  _CustomProgramFormState createState() => _CustomProgramFormState();
}

class _CustomProgramFormState extends State<CustomProgramForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _programNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  List<Map<String, dynamic>> _workouts = [];

  void _addWorkout() {
    setState(() {
      _workouts.add({
        'day': 'Day ${_workouts.length + 1}',
        'exercises': <Map<String, dynamic>>[],
      });
    });
  }

  void _addExercise(int workoutIndex) {
    setState(() {
      _workouts[workoutIndex]['exercises'].add({
        'name': '',
        'sets': 0,
        'reps': 0,
        'weight': 0.0,
      });
    });
  }

  Future<void> _saveProgram() async {
    if (_formKey.currentState!.validate()) {
      final programRepository = ProgramRepository();
      final program = Program(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _programNameController.text,
        description: _descriptionController.text + '\nDuration: ${_durationController.text}\nWorkouts: ${_workouts.toString()}',
      );
      await programRepository.insertProgram(program);
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _programNameController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Custom Program'),
        backgroundColor: const Color(0xFF1C2526),
        foregroundColor: const Color(0xFFB0B7BF),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [const Color(0xFF87CEEB).withOpacity(0.2), const Color(0xFF1C2526)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _programNameController,
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
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
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
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _durationController,
                    decoration: InputDecoration(
                      labelText: 'Duration (e.g., 8 weeks)',
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
                  const SizedBox(height: 24),
                  Text(
                    'Workouts',
                    style: GoogleFonts.oswald(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFB22222),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._workouts.asMap().entries.map((entry) {
                    final index = entry.key;
                    final workout = entry.value;
                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      color: const Color(0xFFB0B7BF),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              workout['day'],
                              style: GoogleFonts.oswald(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFB22222),
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...List.generate(workout['exercises'].length, (exIndex) {
                              final exercise = workout['exercises'][exIndex];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        decoration: InputDecoration(
                                          labelText: 'Exercise ${exIndex + 1}',
                                          labelStyle: GoogleFonts.roboto(
                                            fontSize: 14,
                                            color: const Color(0xFF808080),
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          filled: true,
                                          fillColor: Colors.white,
                                        ),
                                        onChanged: (value) {
                                          setState(() {
                                            workout['exercises'][exIndex]['name'] = value;
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    SizedBox(
                                      width: 60,
                                      child: TextField(
                                        decoration: InputDecoration(
                                          labelText: 'Sets',
                                          labelStyle: GoogleFonts.roboto(
                                            fontSize: 14,
                                            color: const Color(0xFF808080),
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          filled: true,
                                          fillColor: Colors.white,
                                        ),
                                        keyboardType: TextInputType.number,
                                        onChanged: (value) {
                                          setState(() {
                                            workout['exercises'][exIndex]['sets'] = int.tryParse(value) ?? 0;
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    SizedBox(
                                      width: 60,
                                      child: TextField(
                                        decoration: InputDecoration(
                                          labelText: 'Reps',
                                          labelStyle: GoogleFonts.roboto(
                                            fontSize: 14,
                                            color: const Color(0xFF808080),
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          filled: true,
                                          fillColor: Colors.white,
                                        ),
                                        keyboardType: TextInputType.number,
                                        onChanged: (value) {
                                          setState(() {
                                            workout['exercises'][exIndex]['reps'] = int.tryParse(value) ?? 0;
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    SizedBox(
                                      width: 80,
                                      child: TextField(
                                        decoration: InputDecoration(
                                          labelText: 'Weight',
                                          labelStyle: GoogleFonts.roboto(
                                            fontSize: 14,
                                            color: const Color(0xFF808080),
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          filled: true,
                                          fillColor: Colors.white,
                                        ),
                                        keyboardType: TextInputType.number,
                                        onChanged: (value) {
                                          setState(() {
                                            workout['exercises'][exIndex]['weight'] = double.tryParse(value) ?? 0.0;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () => _addExercise(index),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFB22222),
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Add Exercise'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _addWorkout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB22222),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Add Workout Day', style: TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _saveProgram,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB22222),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Save Program', style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}