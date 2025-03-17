import 'package:flutter/material.dart';
import '../database_helper.dart';

class ProgramDetailsCard extends StatelessWidget {
  final Map<String, dynamic> program;
  final String unit;
  final bool is531Program;
  final bool isRussianSquat;

  const ProgramDetailsCard({
    Key? key,
    required this.program,
    required this.unit,
    required this.is531Program,
    required this.isRussianSquat,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Theme.of(context).colorScheme.surface, // Theme surface
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Program: ${program['name']}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary, // Theme primary
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Start Date: ${(program['startDate'] as String?)?.toString() ?? 'Not started'}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 10),
            if (program['currentWeek'] != null)
              Text(
                'Current Week: ${program['currentWeek']}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            if (isRussianSquat && program['sessionsCompleted'] != null)
              Text(
                'Sessions This Week: ${program['sessionsCompleted']}/3',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            if (isRussianSquat && program['currentSession'] != null)
              Text(
                'Current Session: ${program['currentSession']}/18',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            if (program['details'] != null) ...[
              const SizedBox(height: 20),
              Text(
                'Program Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary, // Theme primary
                ),
              ),
              const SizedBox(height: 10),
              if (program['details']['1RM'] != null)
                Text(
                  '1RM: ${(program['details']['1RM'] as double?)?.toString() ?? 'Not set'} $unit',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              if (program['details']['1RMs'] != null)
                ...((program['details']['1RMs'] as Map<String, dynamic>).entries.map((entry) {
                  return Text(
                    '${entry.key} 1RM: ${entry.value} $unit',
                    style: Theme.of(context).textTheme.bodyMedium,
                  );
                })),
              Text(
                'Sets: ${(program['details']['sets'] as int?)?.toString() ?? 'N/A'}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                'Reps: ${(program['details']['reps'] as int?)?.toString() ?? 'N/A'}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class SessionSetsCard extends StatelessWidget {
  final int currentSession;
  final String workoutName;
  final List<Map<String, dynamic>> currentSessionSets;
  final List<TextEditingController> repsControllers;
  final List<bool> setCompleted;
  final String unit;
  final Function(int, String) onRepsChanged;
  final Function(int, bool?) onSetCompletedChanged;

  const SessionSetsCard({
    Key? key,
    required this.currentSession,
    required this.workoutName,
    required this.currentSessionSets,
    required this.repsControllers,
    required this.setCompleted,
    required this.unit,
    required this.onRepsChanged,
    required this.onSetCompletedChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('SessionSetsCard - Current session sets: $currentSessionSets');

    final exerciseGroups = <String, List<Map<String, dynamic>>>{};
    for (var set in currentSessionSets) {
      final name = set['name'] as String;
      exerciseGroups.putIfAbsent(name, () => []).add(set);
    }

    print('SessionSetsCard - Exercise groups: $exerciseGroups');

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Theme.of(context).colorScheme.surface, // Theme surface
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Session $currentSession: $workoutName',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary, // Theme primary
              ),
            ),
            const SizedBox(height: 10),
            ...exerciseGroups.entries.map((entry) {
              final exerciseName = entry.key;
              final sets = entry.value;
              return ExpansionTile(
                title: Text(
                  exerciseName,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                children: sets.asMap().entries.map((setEntry) {
                  final index = setEntry.key;
                  final set = setEntry.value;
                  final globalIndex = currentSessionSets.indexOf(set);
                  final weight = set['weight'] as double;
                  final reps = set['reps'] as int;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Set ${index + 1}: $weight $unit x $reps reps',
                            style: TextStyle(
                              color: setCompleted[globalIndex]
                                  ? Theme.of(context).colorScheme.secondary // Green for completed
                                  : Theme.of(context).colorScheme.onSurface, // Default text color
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 80,
                          child: TextField(
                            controller: repsControllers[globalIndex],
                            decoration: InputDecoration(
                              labelText: 'Reps Done',
                              border: const OutlineInputBorder(),
                              hintText: '',
                            ),
                            keyboardType: TextInputType.number,
                            onTap: () {
                              if (repsControllers[globalIndex].text.isEmpty || repsControllers[globalIndex].text == '0') {
                                repsControllers[globalIndex].clear();
                              }
                            },
                            onChanged: (value) => onRepsChanged(globalIndex, value),
                          ),
                        ),
                        Checkbox(
                          value: setCompleted[globalIndex],
                          onChanged: (value) => onSetCompletedChanged(globalIndex, value),
                          activeColor: Theme.of(context).colorScheme.secondary, // Green checkmark
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

class WorkoutLogCard extends StatefulWidget {
  final List<Map<String, dynamic>> workoutLog;
  final String unit;
  final Function(int) onDelete;

  const WorkoutLogCard({
    Key? key,
    required this.workoutLog,
    required this.unit,
    required this.onDelete,
  }) : super(key: key);

  @override
  _WorkoutLogCardState createState() => _WorkoutLogCardState();
}

class _WorkoutLogCardState extends State<WorkoutLogCard> {
  late List<List<TextEditingController>> repsControllersList;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  @override
  void didUpdateWidget(WorkoutLogCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.workoutLog != oldWidget.workoutLog) {
      print('WorkoutLogCard: workoutLog updated, reinitializing controllers');
      _initializeControllers();
    }
  }

  void _initializeControllers() {
    repsControllersList = widget.workoutLog.map((logEntry) {
      final sets = (logEntry['sets'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      return List<TextEditingController>.generate(sets.length, (index) {
        return TextEditingController(text: (sets[index]['completedReps'] as num?)?.toString() ?? '');
      });
    }).toList();
    print('Initialized repsControllersList with ${repsControllersList.length} entries');
  }

  void _updateCompletedReps(int logIndex, int setIndex, String value) {
    if (logIndex < 0 || logIndex >= widget.workoutLog.length) {
      print('Error: Invalid logIndex $logIndex for workoutLog length ${widget.workoutLog.length}');
      return;
    }
    if (setIndex < 0 || setIndex >= (widget.workoutLog[logIndex]['sets'] as List).length) {
      print('Error: Invalid setIndex $setIndex for sets length ${(widget.workoutLog[logIndex]['sets'] as List).length}');
      return;
    }

    setState(() {
      final completedReps = int.tryParse(value) ?? 0;
      (widget.workoutLog[logIndex]['sets'] as List)[setIndex]['completedReps'] = completedReps;
    });
    DatabaseHelper.saveProgramLog(widget.workoutLog[logIndex]['programId'] as String, widget.workoutLog);
    print('Updated completed reps for logIndex=$logIndex, setIndex=$setIndex: $value');
  }

  @override
  Widget build(BuildContext context) {
    print('Building WorkoutLogCard with ${widget.workoutLog.length} log entries');
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Theme.of(context).colorScheme.surface, // Theme surface
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Workout Log',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary, // Theme primary
              ),
            ),
            const SizedBox(height: 10),
            ...widget.workoutLog.asMap().entries.map((entry) {
              final logIndex = entry.key;
              final log = entry.value;
              final date = log['date'] as String? ?? 'Unknown Date';
              final sets = (log['sets'] as List?)?.cast<Map<String, dynamic>>() ?? [];

              final sessionNumber = logIndex + 1;
              final weekNumber = ((sessionNumber - 1) ~/ 3) + 1;
              final dayNumber = ((sessionNumber - 1) % 3) + 1;

              final mainLifts = sets
                  .where((set) => !(set['name'] as String).startsWith('Warmup'))
                  .map((set) => set['name'] as String)
                  .toSet()
                  .join(', ');

              double totalVolume = sets.fold(0.0, (sum, set) {
                final weight = (set['weight'] as num? ?? 0).toDouble();
                final completedReps = (set['completedReps'] as num? ?? 0).toDouble();
                return sum + (weight * completedReps);
              });

              return ExpansionTile(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Week $weekNumber, Day $dayNumber - Session $sessionNumber ($date)',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      mainLifts.isNotEmpty ? mainLifts : 'No main lifts',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                    ),
                    Text(
                      'Total Volume: ${totalVolume.toStringAsFixed(0)} ${widget.unit}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic, color: Colors.grey),
                    ),
                  ],
                ),
                children: [
                  ListTile(
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: sets.asMap().entries.map((setEntry) {
                        final setIndex = setEntry.key;
                        final set = setEntry.value;
                        final weight = set['weight'] as num? ?? 0;
                        final reps = set['reps'] as num? ?? 0;
                        final completedReps = set['completedReps'] as num? ?? 0;
                        final diff = completedReps - reps;
                        final color = completedReps < reps
                            ? Colors.red
                            : completedReps > reps
                            ? Theme.of(context).colorScheme.secondary // Green
                            : Colors.blue;
                        final icon = completedReps < reps
                            ? Icons.arrow_downward
                            : completedReps > reps
                            ? Icons.arrow_upward
                            : Icons.check;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Set ${setIndex + 1}: $weight ${widget.unit} x $reps reps',
                                  style: TextStyle(color: color),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(
                                width: 100,
                                child: TextField(
                                  controller: repsControllersList.length > logIndex && repsControllersList[logIndex].length > setIndex
                                      ? repsControllersList[logIndex][setIndex]
                                      : TextEditingController(text: completedReps.toString()),
                                  decoration: InputDecoration(
                                    labelText: 'Reps Done',
                                    border: const OutlineInputBorder(),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                    isDense: true,
                                  ),
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  onTap: () {
                                    if (repsControllersList.length > logIndex && repsControllersList[logIndex].length > setIndex) {
                                      final controller = repsControllersList[logIndex][setIndex];
                                      if (controller.text.isEmpty || controller.text == '0') {
                                        controller.clear();
                                      }
                                    }
                                  },
                                  onChanged: (value) => _updateCompletedReps(logIndex, setIndex, value),
                                ),
                              ),
                              SizedBox(width: 8),
                              Checkbox(
                                value: false, // Placeholder, use log data if needed
                                onChanged: (value) {},
                                activeColor: Theme.of(context).colorScheme.secondary, // Green
                              ),
                              if (completedReps != reps)
                                Padding(
                                  padding: const EdgeInsets.only(left: 4.0),
                                  child: Row(
                                    children: [
                                      Icon(icon, size: 16, color: color),
                                      const SizedBox(width: 4),
                                      Text(
                                        '(${diff > 0 ? '+' : ''}$diff)',
                                        style: TextStyle(color: color, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => widget.onDelete(logIndex),
                    ),
                  ),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

Widget buildProgramList({
  required BuildContext context,
  required List<Map<String, dynamic>> currentPrograms,
  required List<Map<String, dynamic>> completedPrograms,
  required String unit,
  required Function(
      BuildContext context,
      String programName,
      bool isNewInstance,
      String? programId,
      bool requires1RM,
      List<String>? lifts,
      Function() refreshPrograms,
      String unit,
      ) startProgram,
  required Function(
      BuildContext context,
      String programId,
      Function() refreshPrograms,
      String unit,
      ) editProgram,
  required Function(
      BuildContext context,
      String programId,
      Function() refreshPrograms,
      String unit,
      ) deleteProgram,
  required Function() refreshPrograms,
}) {
  return Column(
    children: [
      Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Theme.of(context).colorScheme.surface, // Theme surface
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current Cycles',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary, // Green
                ),
              ),
              const SizedBox(height: 10),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 200),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: currentPrograms.length,
                  itemBuilder: (context, index) {
                    final program = currentPrograms[index];
                    final String startDate = (program['startDate'] as String?) ?? 'Not started';
                    final Map<String, dynamic>? details = program['details'] as Map<String, dynamic>?;
                    String oneRM;
                    if (details != null) {
                      if (details['1RM'] != null) {
                        oneRM = (details['1RM'] as double).toString();
                      } else if (details['1RMs'] != null && (details['1RMs'] as Map<String, dynamic>).isNotEmpty) {
                        final oneRMs = details['1RMs'] as Map<String, dynamic>;
                        final rmList = oneRMs.entries.map((entry) => '${entry.key}: ${entry.value}').join(', ');
                        oneRM = '1RMs: $rmList $unit';
                      } else {
                        oneRM = 'Not set';
                      }
                    } else {
                      oneRM = 'Not set';
                    }
                    print('Rendering current program $index: 1RM: $oneRM, unit: $unit, details: $details');
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: Theme.of(context).colorScheme.surface, // Theme surface
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      child: ListTile(
                        title: Text(
                          '${program['name']} (${startDate})',
                          style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.secondary), // Green
                        ),
                        subtitle: Text('Started: $startDate | $oneRM', style: Theme.of(context).textTheme.bodyMedium),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.play_arrow, color: Theme.of(context).colorScheme.secondary), // Green
                              onPressed: () => startProgram(
                                context,
                                program['name'] as String,
                                false,
                                program['id'] as String,
                                false,
                                null,
                                refreshPrograms,
                                unit,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => editProgram(
                                context,
                                program['id'] as String,
                                refreshPrograms,
                                unit,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => deleteProgram(
                                context,
                                program['id'] as String,
                                refreshPrograms,
                                unit,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 20),
      Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Theme.of(context).colorScheme.surface, // Theme surface
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Completed Cycles',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700], // Keep red for completed
                ),
              ),
              const SizedBox(height: 10),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 200),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: completedPrograms.length,
                  itemBuilder: (context, index) {
                    final program = completedPrograms[index] as Map<String, dynamic>;
                    final String startDate = (program['startDate'] as String?)?.toString() ?? 'Unknown';
                    final Map<String, dynamic>? details = program['details'] as Map<String, dynamic>?;
                    String oneRM;
                    if (details != null) {
                      if (details['1RM'] != null) {
                        oneRM = (details['1RM'] as double).toString();
                      } else if (details['1RMs'] != null && (details['1RMs'] as Map<String, dynamic>).isNotEmpty) {
                        final oneRMs = details['1RMs'] as Map<String, dynamic>;
                        final rmList = oneRMs.entries.map((entry) => '${entry.key}: ${entry.value}').join(', ');
                        oneRM = '1RMs: $rmList $unit';
                      } else {
                        oneRM = 'Not set';
                      }
                    } else {
                      oneRM = 'Not set';
                    }
                    print('Rendering completed program $index: 1RM: $oneRM, unit: $unit, details.unit: ${program['details']?['unit']}');
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: Theme.of(context).colorScheme.surface, // Theme surface
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      child: ListTile(
                        title: Text(
                          '${program['name']} (${startDate})',
                          style: const TextStyle(fontSize: 16, color: Colors.red),
                        ),
                        subtitle: Text('Started: $startDate | $oneRM', style: Theme.of(context).textTheme.bodyMedium),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check, color: Theme.of(context).colorScheme.secondary), // Green check
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => editProgram(
                                context,
                                program['id'] as String,
                                refreshPrograms,
                                unit,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => deleteProgram(
                                context,
                                program['id'] as String,
                                refreshPrograms,
                                unit,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}