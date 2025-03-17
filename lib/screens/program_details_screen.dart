import 'package:flutter/material.dart';
import '../database_helper.dart';
import 'program_details_logic.dart';
import 'program_details_widgets.dart';
import 'program_details_dialogs.dart';

class ProgramDetailsScreen extends StatefulWidget {
  final String programId;
  final String unit;

  const ProgramDetailsScreen({super.key, required this.programId, required this.unit});

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
    print('ProgramDetailsScreen initState with unit: ${widget.unit}');
    _logic = ProgramDetailsLogic(
      programId: widget.programId,
      unit: widget.unit,
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

  @override
  void didUpdateWidget(ProgramDetailsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.unit != widget.unit) {
      print('Unit changed from ${oldWidget.unit} to ${widget.unit}, reloading program');
      _logic.updateUnit(widget.unit);
      _loadProgram();
      _loadWorkoutLog();
    }
  }

  Future<void> _loadProgram() async {
    try {
      setState(() => isLoading = true);
      program = await DatabaseHelper.getProgram(widget.programId);
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
      print('Loaded workout log with unit: ${widget.unit}');
      setState(() {});
    } catch (e) {
      print('Error loading workout log: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading workout log: $e')));
    }
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
              Navigator.pop(context, true); // Return to previous screen
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final is531Program = program['name'] == '5/3/1 Program';
    final isRussianSquat = program['name'] == 'Russian Squat Program';

    return Scaffold(
      appBar: AppBar(
        title: Text(program['name'] ?? 'Program Details'),
        backgroundColor: Theme.of(context).colorScheme.primary, // Use theme primary
        foregroundColor: Colors.white, // White icons/text
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => ProgramDetailsDialogs.showUpdate1RMDialog(
              context: context,
              program: program,
              unit: widget.unit,
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
              onComplete: () => Navigator.pop(context, true),
            ),
            tooltip: 'Mark as Completed',
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProgramDetailsCard(
              program: program,
              unit: widget.unit,
              is531Program: is531Program,
              isRussianSquat: isRussianSquat,
            ),
            const SizedBox(height: 20),
            if (currentSessionSets.isNotEmpty && !(program['completed'] as bool? ?? false)) ...[
              SessionSetsCard(
                currentSession: program['currentSession'] as int? ?? 1,
                workoutName: currentWorkout?['workoutName'] ?? '',
                currentSessionSets: currentSessionSets,
                repsControllers: repsControllers,
                setCompleted: setCompleted,
                unit: widget.unit,
                onRepsChanged: (index, value) {
                  setState(() {
                    final completedReps = int.tryParse(value) ?? 0;
                    currentSessionSets[index]['completedReps'] = completedReps;
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
                        backgroundColor: Theme.of(context).colorScheme.primary, // Theme primary
                        foregroundColor: Colors.white, // White text
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
                      backgroundColor: Theme.of(context).colorScheme.primary, // Theme primary
                      foregroundColor: Colors.white, // White text
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
                      backgroundColor: Theme.of(context).colorScheme.primary, // Theme primary
                      foregroundColor: Colors.white, // White text
                    ),
                    onPressed: _completeAllSets,
                    child: const Text('Complete All Sets'),
                  ),
                ],
              ),
            ],
            if (workoutLog.isNotEmpty) ...[
              const SizedBox(height: 20),
              WorkoutLogCard(
                workoutLog: workoutLog,
                unit: widget.unit,
                onDelete: (index) => ProgramDetailsDialogs.showDeleteWorkoutLogDialog(
                  context: context,
                  programId: widget.programId,
                  index: index,
                  onDelete: () => _loadWorkoutLog(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}