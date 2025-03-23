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

class ProgramDetailsWidget extends StatelessWidget {
  final Map<String, dynamic> program;
  final String unit;

  const ProgramDetailsWidget({super.key, required this.program, required this.unit});

  @override
  Widget build(BuildContext context) {
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
                  program['name'] ?? 'Program Details',
                  style: GoogleFonts.oswald(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Started: ${program['startDate'] ?? 'Unknown'}',
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    color: const Color(0xFF1C2526),
                  ),
                ),
                const SizedBox(height: 8),
                if (program['oneRMs'] != null)
                  ...program['oneRMs'].entries.map<Widget>((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Text(
                        '${entry.key} 1RM: ${entry.value} $unit',
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          color: const Color(0xFF1C2526),
                        ),
                      ),
                    );
                  }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }
}

class WorkoutCard extends StatefulWidget {
  final Program program;
  final String unit;
  final VoidCallback onTap;
  final Function(Workout) onLogWorkout;

  const WorkoutCard({
    super.key,
    required this.program,
    required this.unit,
    required this.onTap,
    required this.onLogWorkout,
  });

  @override
  _WorkoutCardState createState() => _WorkoutCardState();
}

class _WorkoutCardState extends State<WorkoutCard> with TickerProviderStateMixin {
  final ProgramRepository _programRepository = ProgramRepository();
  Map<String, dynamic>? workoutDetails;
  bool isWarmupExpanded = true;
  bool isWorkingExpanded = true;
  int _restTime = 60; // Default rest time in seconds
  int _remainingTime = 0;
  bool _isTimerRunning = false;
  late AnimationController _controller;

  Map<String, dynamic> getTodayWorkout(Program program) {
    switch (program.name) {
      case 'Madcow 5x5':
        return ProgramLogic.calculateMadcow(
          {
            'details': program.details,
            'oneRMs': program.oneRMs,
          },
          program.currentWeek,
          program.currentSession,
        );
      case '5/3/1 Program':
        final lift = program.currentSession == 1
            ? 'Squat'
            : program.currentSession == 2
            ? 'Bench'
            : program.currentSession == 3
            ? 'Deadlift'
            : 'Overhead';
        final workoutDetails = ProgramLogic.calculate531(
          program.oneRMs,
          program.currentWeek,
          lift,
        );
        return {
          'week': program.currentWeek,
          'session': program.currentSession,
          'workoutName': '$lift Day',
          'exercises': workoutDetails['sets'].asMap().entries.map<Map<String, dynamic>>((entry) {
            final set = entry.value;
            return {
              'name': lift,
              'sets': 1,
              'reps': set['reps'],
              'weight': set['weight'],
            };
          }).toList(),
          'unit': widget.unit,
        };
      default:
        return {
          'week': program.currentWeek,
          'session': program.currentSession,
          'workoutName': 'Default Workout',
          'exercises': [
            {
              'name': 'Squat',
              'sets': 3,
              'reps': 5,
              'weight': program.oneRMs['Squat'] ?? 0.0,
            },
            {
              'name': 'Bench',
              'sets': 3,
              'reps': 5,
              'weight': program.oneRMs['Bench'] ?? 0.0,
            },
          ],
          'unit': widget.unit,
        };
    }
  }

  Future<void> _loadSavedReps() async {
    final prefs = await SharedPreferences.getInstance();
    workoutDetails!['exercises'].forEach((exercise) {
      final sets = exercise['sets'] as int;
      for (int setIndex = 0; setIndex < sets; setIndex++) {
        final key = '${widget.program.id}_${exercise['name']}_$setIndex';
        final savedReps = prefs.getInt(key);
        if (savedReps != null) {
          _actualRepsControllers[key]?.text = savedReps.toString();
        }
      }
    });
  }

  Future<void> _saveReps(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    final reps = int.tryParse(value);
    if (reps != null) {
      await prefs.setInt(key, reps);
    }
  }

  Future<void> _completeSession(Map<String, dynamic> workoutDetails) async {
    final exercises = workoutDetails['exercises'] as List<Map<String, dynamic>>;
    final workoutName = workoutDetails['workoutName'] as String;

    // Update each exercise with the actual reps completed
    for (var exercise in exercises) {
      final sets = exercise['sets'] as int;
      final reps = exercise['reps'] as int;
      exercise['actualReps'] = List.generate(sets, (_) => reps); // Default to programmed reps
      for (int setIndex = 0; setIndex < sets; setIndex++) {
        final controller = _actualRepsControllers['${exercise['name']}_$setIndex'];
        final actualReps = int.tryParse(controller?.text ?? '$reps') ?? reps;
        exercise['actualReps'][setIndex] = actualReps;
      }
    }

    final workout = Workout(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      programId: widget.program.id,
      name: workoutName,
      exercises: exercises,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );

    await WorkoutRepository().insertWorkout(widget.program.id, workout);

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

    // Clear saved reps after completing the session
    final prefs = await SharedPreferences.getInstance();
    for (var exercise in exercises) {
      final sets = exercise['sets'] as int;
      for (int setIndex = 0; setIndex < sets; setIndex++) {
        final key = '${widget.program.id}_${exercise['name']}_$setIndex';
        await prefs.remove(key);
      }
    }

    AppSnackBar.showSuccess(context, 'Session completed successfully!');
    setState(() {});
  }

  final Map<String, TextEditingController> _actualRepsControllers = {};

  @override
  void initState() {
    super.initState();
    workoutDetails = getTodayWorkout(widget.program);
    // Initialize controllers for actual reps
    for (var exercise in workoutDetails!['exercises'] as List<Map<String, dynamic>>) {
      final sets = exercise['sets'] as int;
      for (int setIndex = 0; setIndex < sets; setIndex++) {
        final key = '${exercise['name']}_$setIndex';
        _actualRepsControllers[key] = TextEditingController(text: '${exercise['reps']}');
      }
    }
    // Load saved reps
    _loadSavedReps();
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
    _actualRepsControllers.forEach((key, controller) => controller.dispose());
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

  @override
  Widget build(BuildContext context) {
    final exercises = workoutDetails!['exercises'] as List<Map<String, dynamic>>;
    final workoutName = workoutDetails!['workoutName'] as String;

    // Separate warmups and working sets
    final warmups = exercises.where((exercise) => exercise['name'].toString().startsWith('Warmup:')).toList();
    final workingSets = exercises.where((exercise) => !exercise['name'].toString().startsWith('Warmup:')).toList();

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
                if (warmups.isNotEmpty)
                  ExpansionTile(
                    title: Text(
                      'Warmup Sets',
                      style: GoogleFonts.oswald(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                    ),
                    initiallyExpanded: isWarmupExpanded,
                    onExpansionChanged: (expanded) {
                      setState(() {
                        isWarmupExpanded = expanded;
                      });
                    },
                    children: warmups.asMap().entries.map<Widget>((entry) {
                      final index = entry.key;
                      final exercise = entry.value;
                      final sets = exercise['sets'] as int;
                      final isWarmup = exercise['name'].toString().startsWith('Warmup:');
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exercise['name'],
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isWarmup ? Colors.grey[600] : const Color(0xFF1C2526),
                            ),
                          ),
                          ...List.generate(sets, (setIndex) {
                            final key = '${exercise['name']}_$setIndex';
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Set ${setIndex + 1}: ${exercise['reps']} reps @ ${exercise['weight']} ${widget.unit}',
                                      style: GoogleFonts.roboto(
                                        fontSize: 16,
                                        color: isWarmup ? Colors.grey[600] : const Color(0xFF1C2526),
                                      ),
                                    ),
                                  ),
                                  if (!isWarmup)
                                    SizedBox(
                                      width: 80,
                                      child: TextField(
                                        controller: _actualRepsControllers[key],
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          labelText: 'Reps Done',
                                          labelStyle: GoogleFonts.roboto(
                                            fontSize: 12,
                                            color: const Color(0xFF808080),
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                        ),
                                        style: GoogleFonts.roboto(
                                          fontSize: 14,
                                          color: const Color(0xFF1C2526),
                                        ),
                                        onChanged: (value) {
                                          _saveReps('${widget.program.id}_$key', value);
                                        },
                                      ),
                                    ),
                                ],
                              ),
                            );
                          }),
                        ],
                      );
                    }).toList(),
                  ),
                if (workingSets.isNotEmpty)
                  ExpansionTile(
                    title: Text(
                      'Working Sets',
                      style: GoogleFonts.oswald(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                    ),
                    initiallyExpanded: isWorkingExpanded,
                    onExpansionChanged: (expanded) {
                      setState(() {
                        isWorkingExpanded = expanded;
                      });
                    },
                    children: workingSets.asMap().entries.map<Widget>((entry) {
                      final index = entry.key;
                      final exercise = entry.value;
                      final sets = exercise['sets'] as int;
                      final isWarmup = exercise['name'].toString().startsWith('Warmup:');
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exercise['name'],
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isWarmup ? Colors.grey[600] : const Color(0xFF1C2526),
                            ),
                          ),
                          ...List.generate(sets, (setIndex) {
                            final key = '${exercise['name']}_$setIndex';
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
                                            color: isWarmup ? Colors.grey[600] : const Color(0xFF1C2526),
                                          ),
                                        ),
                                      ),
                                      if (!isWarmup)
                                        SizedBox(
                                          width: 80,
                                          child: TextField(
                                            controller: _actualRepsControllers[key],
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                              labelText: 'Reps Done',
                                              labelStyle: GoogleFonts.roboto(
                                                fontSize: 12,
                                                color: const Color(0xFF808080),
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                            ),
                                            style: GoogleFonts.roboto(
                                              fontSize: 14,
                                              color: const Color(0xFF1C2526),
                                            ),
                                            onChanged: (value) {
                                              _saveReps('${widget.program.id}_$key', value);
                                            },
                                          ),
                                        ),
                                    ],
                                  ),
                                  if (!isWarmup)
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
                    }).toList(),
                  ),
                if (exercises.isEmpty)
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

class ExerciseInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool isNumeric;

  const ExerciseInputWidget({
    super.key,
    required this.controller,
    required this.label,
    this.isNumeric = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
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
    );
  }
}

class ProgramProgressWidget extends StatelessWidget {
  final String programId;

  const ProgramProgressWidget({super.key, required this.programId});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Color>(
      valueListenable: accentColorNotifier,
      builder: (context, accentColor, child) {
        return FutureBuilder<List<Workout>>(
          future: WorkoutRepository().getWorkouts(programId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: accentColor));
            }
            if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
              return Text(
                'No workouts logged for this program.',
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  color: const Color(0xFF808080),
                ),
              );
            }

            final workouts = snapshot.data!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Program Progress',
                  style: GoogleFonts.oswald(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Total Workouts Logged: ${workouts.length}',
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    color: const Color(0xFF1C2526),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}