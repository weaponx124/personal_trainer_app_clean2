import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_trainer_app_clean/core/data/models/program.dart';
import 'package:personal_trainer_app_clean/core/data/models/workout.dart';
import 'package:personal_trainer_app_clean/core/data/repositories/program_repository.dart';
import 'package:personal_trainer_app_clean/core/data/repositories/workout_repository.dart';
import 'package:personal_trainer_app_clean/main.dart';
import 'package:personal_trainer_app_clean/screens/program_details_dialogs.dart';
import 'package:personal_trainer_app_clean/screens/program_details_logic.dart';
import 'package:personal_trainer_app_clean/screens/program_details_widgets.dart';
import 'package:personal_trainer_app_clean/utils/cross_painter.dart';
import 'package:personal_trainer_app_clean/widgets/common/app_snack_bar.dart';
import 'package:personal_trainer_app_clean/widgets/common/loading_indicator.dart';

class ProgramDetailsScreen extends StatefulWidget {
  final String programId;

  const ProgramDetailsScreen({super.key, required this.programId});

  @override
  _ProgramDetailsScreenState createState() => _ProgramDetailsScreenState();
}

class _ProgramDetailsScreenState extends State<ProgramDetailsScreen> {
  final ProgramRepository _programRepository = ProgramRepository();
  final WorkoutRepository _workoutRepository = WorkoutRepository();
  late Future<Program> _programFuture;
  Program? _program;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _programFuture = _loadProgram();
    _loadProgramData();
  }

  Future<Program> _loadProgram() async {
    try {
      final program = await _programRepository.getProgram(widget.programId);
      if (program == null) {
        throw Exception('Program not found');
      }
      return program;
    } catch (e) {
      print('Error loading program: $e');
      AppSnackBar.showError(context, 'Failed to load program: $e');
      throw e;
    }
  }

  Future<void> _loadProgramData() async {
    final program = await _programFuture;
    setState(() {
      _program = program;
    });
  }

  Future<void> _updateProgram(Program updatedProgram) async {
    setState(() {
      _isLoading = true;
    });
    try {
      await _programRepository.updateProgram(updatedProgram);
      setState(() {
        _program = updatedProgram;
      });
      AppSnackBar.showSuccess(context, 'Program updated successfully!');
    } catch (e) {
      AppSnackBar.showError(context, 'Failed to update program: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logWorkout(Workout workout) async {
    setState(() {
      _isLoading = true;
    });
    try {
      await _workoutRepository.insertWorkout(widget.programId, workout);
      final updatedProgram = Program(
        id: _program!.id,
        name: _program!.name,
        description: _program!.description,
        oneRMs: _program!.oneRMs,
        details: _program!.details,
        completed: _program!.completed,
        startDate: _program!.startDate,
        currentWeek: _program!.currentWeek,
        currentSession: _program!.currentSession + 1,
        sessionsCompleted: _program!.sessionsCompleted + 1,
      );
      await _programRepository.updateProgram(updatedProgram);
      setState(() {
        _program = updatedProgram;
      });
      AppSnackBar.showSuccess(context, 'Workout logged successfully!');
    } catch (e) {
      AppSnackBar.showError(context, 'Failed to log workout: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: unitNotifier,
      builder: (context, unit, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Program Details'),
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
                if (_isLoading)
                  const Center(child: LoadingIndicator())
                else
                  FutureBuilder<Program>(
                    future: _programFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const LoadingIndicator();
                      }
                      if (snapshot.hasError || !snapshot.hasData) {
                        return Center(
                          child: Text(
                            'Error loading program.',
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              color: const Color(0xFF1C2526),
                            ),
                          ),
                        );
                      }
                      final program = _program ?? snapshot.data!;
                      return SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                program.name,
                                style: GoogleFonts.oswald(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFB22222),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Week ${program.currentWeek}, Session ${program.currentSession}',
                                style: GoogleFonts.roboto(
                                  fontSize: 16,
                                  color: const Color(0xFF808080),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                color: const Color(0xFFB0B7BF),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Current 1RMs (${unit}):',
                                        style: GoogleFonts.oswald(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFFB22222),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      if (program.oneRMs.isEmpty)
                                        Text(
                                          'No 1RMs set for this program.',
                                          style: GoogleFonts.roboto(
                                            fontSize: 14,
                                            color: const Color(0xFF808080),
                                          ),
                                        )
                                      else
                                        ...program.oneRMs.entries.map((entry) {
                                          return Padding(
                                            padding: const EdgeInsets.only(bottom: 4.0),
                                            child: Text(
                                              '${entry.key}: ${entry.value} $unit',
                                              style: GoogleFonts.roboto(
                                                fontSize: 14,
                                                color: const Color(0xFF808080),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      const SizedBox(height: 16),
                                      ElevatedButton(
                                        onPressed: () => showUpdate1RMsDialog(context, program, _updateProgram),
                                        child: const Text('Update 1RMs'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                color: const Color(0xFFB0B7BF),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Today\'s Workout',
                                        style: GoogleFonts.oswald(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFFB22222),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      WorkoutCard(
                                        program: program,
                                        unit: unit,
                                        onTap: () {
                                          Navigator.pushNamed(context, '/workout');
                                        },
                                        onLogWorkout: _logWorkout,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => showEndProgramDialog(context, program, _updateProgram),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text('End Program'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}