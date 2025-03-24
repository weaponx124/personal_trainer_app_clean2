import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_trainer_app_clean/core/data/models/program.dart';
import 'package:personal_trainer_app_clean/core/data/models/workout.dart';
import 'package:personal_trainer_app_clean/core/data/repositories/program_repository.dart';
import 'package:personal_trainer_app_clean/core/data/repositories/workout_repository.dart';
import 'package:personal_trainer_app_clean/main.dart';
import 'package:personal_trainer_app_clean/screens/program_details_dialogs.dart';
import 'package:personal_trainer_app_clean/screens/program_logic.dart';
import 'package:personal_trainer_app_clean/widgets/common/app_snack_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Madcow5x5 extends StatefulWidget {
  final Program program;
  final String unit;

  const Madcow5x5({super.key, required this.program, required this.unit});

  @override
  _Madcow5x5State createState() => _Madcow5x5State();
}

class _Madcow5x5State extends State<Madcow5x5> with TickerProviderStateMixin {
  final ProgramRepository _programRepository = ProgramRepository();
  Map<String, dynamic>? workoutDetails;
  late ProgramLogic _programLogic;
  int _restTime = 60; // Default rest time in seconds
  int _remainingTime = 0;
  bool _isTimerRunning = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Instantiate ProgramLogic with the program map
    _programLogic = ProgramLogic({
      'details': widget.program.details,
      'oneRMs': widget.program.oneRMs,
      'currentWeek': widget.program.currentWeek,
      'currentSession': widget.program.currentSession,
    });

    final oneRMs = widget.program.oneRMs;
    final week = widget.program.currentWeek;
    final session = widget.program.currentSession;
    final List<Map<String, dynamic>> exercises = [];

    if (session == 1) {
      // Heavy Day
      exercises.add({
        'name': 'Squat',
        'sets': 5,
        'reps': 5,
        'weight': _programLogic.calculateWorkingWeight(oneRMs['Squat'] ?? 0.0, 0.9, week, 5, session),
      });
      exercises.add({
        'name': 'Bench Press',
        'sets': 5,
        'reps': 5,
        'weight': _programLogic.calculateWorkingWeight(oneRMs['Bench'] ?? 0.0, 0.9, week, 5, session),
      });
      exercises.add({
        'name': 'Barbell Row',
        'sets': 5,
        'reps': 5,
        'weight': _programLogic.calculateWorkingWeight(oneRMs['Row'] ?? 0.0, 0.9, week, 5, session),
      });
    } else if (session == 2) {
      // Light Day
      exercises.add({
        'name': 'Squat',
        'sets': 4,
        'reps': 5,
        'weight': _programLogic.calculateWorkingWeight(oneRMs['Squat'] ?? 0.0, 0.8, week, 5, session),
      });
      exercises.add({
        'name': 'Overhead Press',
        'sets': 4,
        'reps': 5,
        'weight': _programLogic.calculateWorkingWeight(oneRMs['Overhead'] ?? 0.0, 0.9, week, 5, session),
      });
      exercises.add({
        'name': 'Deadlift',
        'sets': 4,
        'reps': 5,
        'weight': _programLogic.calculateWorkingWeight(oneRMs['Deadlift'] ?? 0.0, 0.9, week, 5, session),
      });
    } else if (session == 3) {
      // Volume Day
      exercises.add({
        'name': 'Squat',
        'sets': 5,
        'reps': 5,
        'weight': _programLogic.calculateWorkingWeight(oneRMs['Squat'] ?? 0.0, 0.85, week, 5, session),
      });
      exercises.add({
        'name': 'Bench Press',
        'sets': 5,
        'reps': 5,
        'weight': _programLogic.calculateWorkingWeight(oneRMs['Bench'] ?? 0.0, 0.85, week, 5, session),
      });
      exercises.add({
        'name': 'Barbell Row',
        'sets': 5,
        'reps': 5,
        'weight': _programLogic.calculateWorkingWeight(oneRMs['Row'] ?? 0.0, 0.85, week, 5, session),
      });
      exercises.add({
        'name': 'Incline Bench Press',
        'sets': 3,
        'reps': 8,
        'weight': _programLogic.calculateWorkingWeight(oneRMs['Bench'] ?? 0.0, 0.7, week, 8, session),
      });
    }

    workoutDetails = {
      'week': week,
      'session': session,
      'workoutName': 'Madcow 5x5 Day $session',
      'exercises': exercises,
      'unit': widget.unit,
    };

    // Initialize rest timer
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: _restTime),
    )..addListener(() {
      setState(() {
        _remainingTime = (_controller.duration!.inSeconds * (1 - _controller.value)).round();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startRestTimer() {
    setState(() {
      _isTimerRunning = true;
      _remainingTime = _restTime;
      _controller.reset();
      _controller.forward();
    });
  }

  void _stopRestTimer() {
    setState(() {
      _isTimerRunning = false;
      _controller.stop();
    });
  }

  Future<void> _setRestTime() async {
    final TextEditingController restTimeController = TextEditingController(text: _restTime.toString());
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Rest Time'),
        content: TextField(
          controller: restTimeController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Rest Time (seconds)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final newRestTime = int.tryParse(restTimeController.text);
              if (newRestTime != null && newRestTime > 0) {
                Navigator.pop(context, true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid number of seconds')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == true) {
      setState(() {
        _restTime = int.parse(restTimeController.text);
        _controller.duration = Duration(seconds: _restTime);
      });
    }
  }

  Future<void> _completeSession(Map<String, dynamic> workoutDetails) async {
    final exercises = workoutDetails['exercises'] as List<Map<String, dynamic>>;
    final workoutName = workoutDetails['workoutName'] as String;

    final workout = Workout(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      programId: widget.program.id,
      name: workoutName,
      exercises: exercises,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );

    await WorkoutRepository().insertWorkout(widget.program.id, workout);
    await _programLogic.logWorkout(widget.program.id, {
      'exercises': exercises,
      'completed': true,
    });

    // Update program session and week
    var updatedProgram = widget.program.copyWith(
      currentSession: widget.program.currentSession + 1,
      sessionsCompleted: widget.program.sessionsCompleted + 1,
    );
    if (updatedProgram.currentSession > 3) {
      updatedProgram = updatedProgram.copyWith(
        currentSession: 1,
        currentWeek: updatedProgram.currentWeek + 1,
      );
    }
    await _programRepository.updateProgram(updatedProgram);

    AppSnackBar.showSuccess(context, 'Session completed successfully!');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (workoutDetails == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final exercises = workoutDetails!['exercises'] as List<Map<String, dynamic>>;
    final workoutName = workoutDetails!['workoutName'] as String;

    return ValueListenableBuilder<Color>(
      valueListenable: accentColorNotifier,
      builder: (context, accentColor, child) {
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
                  workoutName,
                  style: GoogleFonts.oswald(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
                const SizedBox(height: 8),
                if (exercises.isNotEmpty)
                  ...exercises.asMap().entries.map<Widget>((entry) {
                    final index = entry.key;
                    final exercise = entry.value;
                    final sets = exercise['sets'] as int;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exercise['name'],
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1C2526),
                          ),
                        ),
                        ...List.generate(sets, (setIndex) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Set ${setIndex + 1}: ${exercise['reps']} reps @ ${exercise['weight']} ${widget.unit}',
                                        style: GoogleFonts.roboto(
                                          fontSize: 16,
                                          color: const Color(0xFF1C2526),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      ElevatedButton(
                                        onPressed: _isTimerRunning ? _stopRestTimer : _startRestTimer,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: accentColor,
                                          foregroundColor: Colors.white,
                                        ),
                                        child: Text(_isTimerRunning ? 'Stop Rest ($_remainingTime s)' : 'Start Rest ($_restTime s)'),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.timer, color: accentColor),
                                        onPressed: _setRestTime,
                                        tooltip: 'Set Rest Time',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    );
                  }).toList()
                else
                  Text(
                    'No exercises logged.',
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      color: const Color(0xFF808080),
                    ),
                  ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: () => _completeSession(workoutDetails!),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Complete Session'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}