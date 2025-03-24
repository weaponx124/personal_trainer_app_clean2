import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_trainer_app_clean/core/data/models/program.dart';
import 'package:personal_trainer_app_clean/core/data/repositories/program_repository.dart';
import 'package:personal_trainer_app_clean/core/utils/cross_painter.dart';
import 'package:personal_trainer_app_clean/main.dart';
import 'package:personal_trainer_app_clean/screens/custom_program_form.dart';
import 'package:personal_trainer_app_clean/screens/program_details_widgets.dart'; // Changed import to program_details_widgets.dart
import 'package:personal_trainer_app_clean/screens/programs_overview_screen.dart';
import 'package:personal_trainer_app_clean/widgets/common/app_snack_bar.dart';

class ProgramSelectionScreen extends StatefulWidget {
  const ProgramSelectionScreen({super.key});

  @override
  _ProgramSelectionScreenState createState() => _ProgramSelectionScreenState();
}

class _ProgramSelectionScreenState extends State<ProgramSelectionScreen> {
  final ProgramRepository _programRepository = ProgramRepository();
  final List<String> _programs = [
    'Madcow 5x5',
    '5/3/1 Program',
    'Starting Strength',
    'Texas Method',
    'Candito 6 Week',
    'Bench Press Specialization',
    'Russian Squat',
    'Smolov Base Cycle',
    'PPL',
    'Bodyweight Fitness',
  ];

  void _selectProgram(String programName, Map<String, dynamic> oneRMs) async {
    final program = Program(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: programName,
      details: {
        'unit': 'lbs', // Default unit, can be changed in settings
      },
      oneRMs: oneRMs,
      currentWeek: 1,
      currentSession: 1,
      sessionsCompleted: 0,
      startDate: DateTime.now().toIso8601String(),
      workouts: [], // Added to match Program model
    );

    await _programRepository.insertProgram(program);
    AppSnackBar.showSuccess(context, 'Program selected successfully!');
    childScreenNotifier.value = const ProgramsOverviewScreen(programName: '');
  }

  void _createCustomProgram() {
    childScreenNotifier.value = const CustomProgramForm();
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
                  title: const Text('Select Program'),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Choose a Program',
                          style: GoogleFonts.oswald(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ..._programs.map((program) {
                          return Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            color: const Color(0xFFB0B7BF),
                            child: ListTile(
                              title: Text(
                                program,
                                style: GoogleFonts.roboto(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1C2526),
                                ),
                              ),
                              trailing: const Icon(Icons.arrow_forward, color: Color(0xFF1C2526)),
                              onTap: () async {
                                final oneRMs = await showDialog<Map<String, dynamic>>(
                                  context: context,
                                  builder: (context) => OneRMDialog(),
                                );
                                if (oneRMs != null) {
                                  _selectProgram(program, oneRMs);
                                }
                              },
                            ),
                          );
                        }).toList(),
                        const SizedBox(height: 16),
                        Center(
                          child: ElevatedButton(
                            onPressed: _createCustomProgram,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentColor,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Create Custom Program'),
                          ),
                        ),
                      ],
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