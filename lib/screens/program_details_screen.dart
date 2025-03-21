import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_trainer_app_clean/core/data/models/program.dart';
import 'package:personal_trainer_app_clean/core/data/models/workout.dart';
import 'package:personal_trainer_app_clean/core/data/repositories/program_repository.dart';
import 'package:personal_trainer_app_clean/core/data/repositories/workout_repository.dart';
import 'package:personal_trainer_app_clean/core/utils/locator.dart';
import 'package:personal_trainer_app_clean/main.dart';
import 'package:personal_trainer_app_clean/screens/program_details_dialogs.dart';
import 'package:personal_trainer_app_clean/screens/program_details_logic.dart';
import 'package:personal_trainer_app_clean/screens/program_details_widgets.dart';

class ProgramDetailsScreen extends StatefulWidget {
  final String programId;

  const ProgramDetailsScreen({super.key, required this.programId});

  @override
  _ProgramDetailsScreenState createState() => _ProgramDetailsScreenState();
}

class _ProgramDetailsScreenState extends State<ProgramDetailsScreen> {
  final ProgramRepository _programRepository = ProgramRepository();
  final WorkoutRepository _workoutRepository = WorkoutRepository();
  final ProgramDetailsLogic _programDetailsLogic = locator<ProgramDetailsLogic>();
  Program? _program;
  List<Workout> _workouts = [];
  Map<String, dynamic>? _currentWorkout;
  int _currentWeek = 1;
  int _currentDay = 1;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgramDetails();
  }

  Future<void> _loadProgramDetails() async {
    setState(() {
      _isLoading = true;
    });

    final programs = await _programRepository.getPrograms();
    final program = programs.firstWhere(
          (p) => p.id == widget.programId,
      orElse: () => Program(id: widget.programId, name: 'Unknown', description: ''),
    );
    final workouts = await _workoutRepository.getWorkouts(widget.programId);
    final currentWorkoutData = await _programDetailsLogic.getCurrentWorkout(widget.programId, _currentWeek, _currentDay);

    setState(() {
      _program = program;
      _workouts = workouts;
      _currentWorkout = currentWorkoutData['workout'] as Map<String, dynamic>?;
      _currentWeek = currentWorkoutData['currentWeek'] as int;
      _currentDay = currentWorkoutData['currentDay'] as int;
      _isLoading = false;
    });
  }

  Future<void> _logWorkout() async {
    if (_currentWorkout != null) {
      await _programDetailsLogic.logWorkout(widget.programId, _currentWorkout!);
      await _loadProgramDetails();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: unitNotifier,
      builder: (context, unit, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(_program?.name ?? 'Program Details'),
            backgroundColor: const Color(0xFF1C2526),
            foregroundColor: const Color(0xFFB0B7BF),
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFFB22222)))
              : Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [const Color(0xFF87CEEB).withOpacity(0.2), const Color(0xFF1C2526)],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
                            'Current Workout',
                            style: GoogleFonts.oswald(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFB22222),
                            ),
                          ),
                          const SizedBox(height: 8),
                          _currentWorkout != null && !_currentWorkout!.containsKey('error')
                              ? WorkoutCard(
                            workout: _currentWorkout!,
                            unit: unit,
                            onTap: () => showWorkoutDetailsDialog(
                              context,
                              _currentWorkout!,
                              unit,
                              _loadProgramDetails,
                            ),
                          )
                              : Text(
                            'No workout found for Week $_currentWeek, Day $_currentDay',
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              color: const Color(0xFF808080),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _currentWorkout != null ? _logWorkout : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB22222),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Log Workout', style: TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => showAddExerciseDialog(
                      context,
                      widget.programId,
                      _currentWorkout?['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
                      unit,
                      _loadProgramDetails,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB22222),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Add Exercise', style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}