import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_trainer_app_clean/core/data/models/program.dart';
import 'package:personal_trainer_app_clean/core/data/repositories/program_repository.dart';
import 'package:personal_trainer_app_clean/utils/cross_painter.dart';
import 'package:personal_trainer_app_clean/widgets/common/app_snack_bar.dart';
import 'package:personal_trainer_app_clean/widgets/common/loading_indicator.dart';
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
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveProgram() async {
    if (_nameController.text.isEmpty) {
      AppSnackBar.showError(context, 'Please enter a program name');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final programId = Uuid().v4();
      final startDate = DateTime.now().toIso8601String().split('T')[0];
      final newProgram = Program(
        id: programId,
        name: _nameController.text,
        description: _descriptionController.text,
        oneRMs: {}, // Custom programs typically don't require 1RMs
        details: {}, // Add any custom details if needed
        completed: false,
        startDate: startDate,
        currentWeek: 1,
        currentSession: 1,
        sessionsCompleted: 0,
      );

      await _programRepository.insertProgram(newProgram);
      AppSnackBar.showSuccess(context, 'Custom program created successfully!');
      Navigator.pop(context);
    } catch (e) {
      AppSnackBar.showError(context, 'Failed to create program: $e');
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
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
            if (_isSaving)
              const Center(child: LoadingIndicator())
            else
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Program Name',
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
                        style: GoogleFonts.oswald(
                          fontSize: 18,
                          color: const Color(0xFFB22222),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description',
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
                        maxLines: 3,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _saveProgram,
                        child: const Text('Save Program'),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}