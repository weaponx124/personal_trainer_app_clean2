import 'package:flutter/material.dart';
import 'package:personal_trainer_app_clean/database_helper.dart';
import 'package:personal_trainer_app_clean/screens/program_details_logic.dart';
import 'package:personal_trainer_app_clean/screens/program_details_widgets.dart';
import 'package:personal_trainer_app_clean/screens/program_details_dialogs.dart';
import 'package:personal_trainer_app_clean/main.dart';
import 'package:animate_do/animate_do.dart';

class ProgramDetailsScreen extends StatefulWidget {
  final String programId;

  const ProgramDetailsScreen({super.key, required this.programId});

  @override
  _ProgramDetailsScreenState createState() => _ProgramDetailsScreenState();
}

class _ProgramDetailsScreenState extends State<ProgramDetailsScreen> {
  Map<String, dynamic> program = {};
  List<Map<String, dynamic>> workoutLog = [];
  bool isLoading = true;
  List<Map<String, dynamic>> currentSessionSets = [];
  List<TextEditingController> repsControllers = [];
  List<bool> setCompleted = [];
  Map<String, dynamic>? currentWorkout;
  late ProgramDetailsLogic _logic;

  @override
  void initState() {
    super.initState();
    print('ProgramDetailsScreen initState with unit: ${unitNotifier.value}');
    _logic = ProgramDetailsLogic(
      programId: widget.programId,
      unit: unitNotifier.value,
      onSessionInitialized: (sets, controllers, completed, workout) {
        setState(() {
          currentSessionSets = sets ?? [];
          repsControllers = controllers ?? [];
          setCompleted = completed ?? [];
          currentWorkout = workout;
          print('Initialized sets: ${currentSessionSets.length}, controllers: ${repsControllers.length}, completed: ${setCompleted.length}');
        });
      },
    );
    _loadProgram();
    _loadWorkoutLog();
  }

  Future<void> _loadProgram() async {
    try {
      setState(() => isLoading = true);
      program = await DatabaseHelper.getProgram(widget.programId);
      await _addTotalSessions();
      print('Loaded program in ProgramDetailsScreen: $program');
      print('Loaded program 1RMs: ${program['details']?['1RMs']}');
      _logic.initializeSessionSets(program);
      setState(() => isLoading = false);
    } catch (e) {
      print('Error loading program details: $e');
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading program details: $e')));
    }
  }

  Future<void> _loadWorkoutLog() async {
    try {
      workoutLog = await DatabaseHelper.getProgramLog(widget.programId);
      print('Loaded workout log with unit: ${unitNotifier.value}');
      setState(() {});
    } catch (e) {
      print('Error loading workout log: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading workout log: $e')));
    }
  }

  Future<void> _addTotalSessions() async {
    final allPrograms = await DatabaseHelper.getAllPrograms();
    final programData = allPrograms.firstWhere((p) => p['name'] == program['name'], orElse: () => {'duration': 'Ongoing'});
    String duration = programData['duration'] ?? 'Ongoing';

    int sessionsPerWeek = 3;
    if (program['name'] == '5/3/1 Program') sessionsPerWeek = 4;

    if (duration == 'Ongoing') {
      program['totalSessions'] = 999;
    } else {
      final match = RegExp(r'(\d+)(?:-(\d+))?\s*weeks').firstMatch(duration);
      if (match != null) {
        int minWeeks = int.parse(match.group(1)!);
        int? maxWeeks = match.group(2) != null ? int.parse(match.group(2)!) : null;
        int weeks = maxWeeks != null ? (minWeeks + maxWeeks) ~/ 2 : minWeeks;
        program['totalSessions'] = weeks * sessionsPerWeek;
      } else {
        program['totalSessions'] = 1;
      }
    }
    print('Set totalSessions for ${program['name']}: ${program['totalSessions']}');
  }

  void _completeAllSets() {
    print('Attempting to complete all sets. Current lengths: sets=${currentSessionSets.length}, controllers=${repsControllers.length}, completed=${setCompleted.length}');
    if (currentSessionSets.isEmpty || repsControllers.length != currentSessionSets.length || setCompleted.length != currentSessionSets.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Session sets data is inconsistent. Please reload the program.')),
      );
      return;
    }

    setState(() {
      for (int i = 0; i < currentSessionSets.length; i++) {
        if (!currentSessionSets[i]['name'].toString().startsWith('Warmup')) {
          setCompleted[i] = true;
          repsControllers[i].text = currentSessionSets[i]['reps'].toString();
          print('Completed set $i: name=${currentSessionSets[i]['name']}, reps=${repsControllers[i].text}');
        }
      }
    });
    _logic.completeSession(
      context: context,
      setCompleted: setCompleted,
      currentSessionSets: currentSessionSets,
      repsControllers: repsControllers,
      programId: widget.programId,
      onComplete: () async {
        await _loadProgram();
        await _loadWorkoutLog();
        if (program['completed'] == true) {
          _showCompletionDialog();
        }
      },
      currentWorkout: currentWorkout,
    )();
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Program Completed!'),
        content: Text('Congratulations! You have completed the ${program['name']} program.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: unitNotifier,
      builder: (context, unit, child) {
        _logic.updateUnit(unit);
        final is531Program = program['name'] == '5/3/1 Program';
        final isRussianSquat = program['name'] == 'Russian Squat Program';

        return Scaffold(
          appBar: AppBar(
            title: Text(program['name'] ?? 'Program Details'),
            backgroundColor: const Color(0xFF1C2526), // Matte Black
            foregroundColor: const Color(0xFFB0B7BF), // Silver
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
              },
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => ProgramDetailsDialogs.showUpdate1RMDialog(
                  context: context,
                  program: program,
                  unit: unit,
                  onUpdate: () => _loadProgram(),
                ),
                tooltip: 'Update 1RM',
              ),
              IconButton(
                icon: const Icon(Icons.check),
                onPressed: () => ProgramDetailsDialogs.showMarkAsCompletedDialog(
                  context: context,
                  program: program,
                  programId: widget.programId,
                  onComplete: () => Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false),
                ),
                tooltip: 'Mark as Completed',
              ),
            ],
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
                // Subtle Cross Background
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.1,
                    child: CustomPaint(
                      painter: CrossPainter(),
                      child: Container(),
                    ),
                  ),
                ),
                isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFFB22222)))
                    : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeIn(
                        duration: const Duration(milliseconds: 800),
                        child: ExpansionTile(
                          title: Text('Program Details', style: Theme.of(context).textTheme.headlineLarge),
                          initiallyExpanded: true,
                          children: [
                            ProgramDetailsCard(
                              program: program,
                              unit: unit,
                              is531Program: is531Program,
                              isRussianSquat: isRussianSquat,
                            ),
                            if (program['sessionsCompleted'] != null && program['totalSessions'] != null) ...[
                              const SizedBox(height: 16),
                              Text('Progress', style: Theme.of(context).textTheme.headlineLarge),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: (program['sessionsCompleted'] as int) / (program['totalSessions'] as int),
                                color: Theme.of(context).colorScheme.secondary, // Red
                                backgroundColor: Colors.grey[300],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              const SizedBox(height: 4),
                              Text('${program['sessionsCompleted']}/${program['totalSessions']} sessions completed',
                                  style: Theme.of(context).textTheme.bodyMedium),
                            ],
                          ],
                        ),
                      ),
                      if (currentSessionSets.isNotEmpty && !(program['completed'] as bool? ?? false)) ...[
                        const SizedBox(height: 20),
                        FadeIn(
                          duration: const Duration(milliseconds: 800),
                          child: ExpansionTile(
                            title: Text('Current Session', style: Theme.of(context).textTheme.headlineLarge),
                            initiallyExpanded: true,
                            children: [
                              SessionSetsCard(
                                currentSession: program['currentSession'] as int? ?? 1,
                                workoutName: currentWorkout?['workoutName'] ?? '',
                                currentSessionSets: currentSessionSets,
                                repsControllers: repsControllers,
                                setCompleted: setCompleted,
                                unit: unit,
                                onRepsChanged: (index, value) {
                                  setState(() {
                                    repsControllers[index].text = value.toString();
                                    currentSessionSets[index]['completedReps'] = value;
                                  });
                                },
                                onSetCompletedChanged: (index, value) {
                                  setState(() {
                                    setCompleted[index] = value ?? false;
                                  });
                                },
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  if (is531Program)
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(context).colorScheme.secondary, // Red
                                        foregroundColor: Colors.white,
                                      ),
                                      onPressed: () => ProgramDetailsDialogs.showCompleteWeekDialog(
                                        context: context,
                                        programName: program['name'] as String,
                                        programId: widget.programId,
                                        onComplete: () => _loadProgram(),
                                      ),
                                      child: const Text('Complete Week'),
                                    ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context).colorScheme.secondary, // Red
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: _logic.completeSession(
                                      context: context,
                                      setCompleted: setCompleted,
                                      currentSessionSets: currentSessionSets,
                                      repsControllers: repsControllers,
                                      programId: widget.programId,
                                      onComplete: () async {
                                        await _loadProgram();
                                        await _loadWorkoutLog();
                                        if (program['completed'] == true) {
                                          _showCompletionDialog();
                                        }
                                      },
                                      currentWorkout: currentWorkout,
                                    ),
                                    child: const Text('Complete Session'),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context).colorScheme.secondary, // Red
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: _completeAllSets,
                                    child: const Text('Complete All Sets'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (workoutLog.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        FadeIn(
                          duration: const Duration(milliseconds: 800),
                          child: ExpansionTile(
                            title: Text('Workout Log', style: Theme.of(context).textTheme.headlineLarge),
                            children: [
                              WorkoutLogCard(
                                workoutLog: workoutLog,
                                unit: unit,
                                onDelete: (index) => ProgramDetailsDialogs.showDeleteWorkoutLogDialog(
                                  context: context,
                                  programId: widget.programId,
                                  index: index,
                                  onDelete: () => _loadWorkoutLog(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
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

// Custom painter for cross background
class CrossPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF87CEEB) // Soft Sky Blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw a subtle cross pattern
    const double crossSize = 100.0;
    for (double x = 0; x < size.width; x += crossSize * 1.5) {
      for (double y = 0; y < size.height; y += crossSize * 1.5) {
        // Vertical line of cross
        canvas.drawLine(
          Offset(x + crossSize / 2, y),
          Offset(x + crossSize / 2, y + crossSize),
          paint,
        );
        // Horizontal line of cross
        canvas.drawLine(
          Offset(x + crossSize / 4, y + crossSize / 2),
          Offset(x + 3 * crossSize / 4, y + crossSize / 2),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}