import 'package:flutter/material.dart';
import '../database_helper.dart';

class ProgramDetailsDialogs {
  static void showMarkAsCompletedDialog({
    required BuildContext context,
    required Map<String, dynamic> program,
    required String programId,
    required VoidCallback onComplete,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark Program as Completed'),
        content: Text('Are you sure you want to mark "${program['name']}" as completed?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final programs = await DatabaseHelper.getPrograms();
                final programIndex = programs.indexWhere((p) => p['id'] == programId);
                if (programIndex >= 0) {
                  programs[programIndex]['completed'] = true;
                  await DatabaseHelper.savePrograms(programs);
                  Navigator.pop(context);
                  onComplete();
                  print('Marked ${program['name']} as completed');
                }
              } catch (e) {
                print('Error marking program as completed: $e');
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error marking program as completed: $e')));
              }
            },
            child: const Text('Complete', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  static void showUpdate1RMDialog({
    required BuildContext context,
    required Map<String, dynamic> program,
    required String unit,
    required VoidCallback onUpdate,
  }) {
    final current1RM = (program['details']?['1RM'] as double?)?.toString() ?? 'Not set';
    final current1RMs = program['details']?['1RMs'] as Map<String, dynamic>? ?? {};

    TextEditingController oneRMController = TextEditingController(text: current1RM != 'Not set' ? current1RM : '');
    Map<String, TextEditingController> oneRMsControllers = {
      'Squat': TextEditingController(text: current1RMs['Squat']?.toString() ?? ''),
      'Bench': TextEditingController(text: current1RMs['Bench']?.toString() ?? ''),
      'Deadlift': TextEditingController(text: current1RMs['Deadlift']?.toString() ?? ''),
      'Overhead': TextEditingController(text: current1RMs['Overhead']?.toString() ?? ''),
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update 1RM for ${program['name']}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (current1RM != 'Not set')
                TextField(
                  controller: oneRMController,
                  decoration: InputDecoration(
                    labelText: 'Update 1RM ($unit)',
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              if (current1RMs.isNotEmpty)
                ...current1RMs.keys.map((lift) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextField(
                      controller: oneRMsControllers[lift],
                      decoration: InputDecoration(
                        labelText: 'Update $lift 1RM ($unit)',
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  );
                }).toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final programs = await DatabaseHelper.getPrograms();
                final programIndex = programs.indexWhere((p) => p['id'] == program['id']);
                if (programIndex >= 0) {
                  var details = programs[programIndex]['details'] as Map<String, dynamic>;
                  if (details.containsKey('1RM')) {
                    final new1RM = double.tryParse(oneRMController.text);
                    if (new1RM != null && new1RM > 0) {
                      details['1RM'] = new1RM;
                      details['original1RM'] = new1RM;
                      details['originalUnit'] = unit;
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid 1RM')));
                      return;
                    }
                  }
                  if (details.containsKey('1RMs')) {
                    Map<String, double> updated1RMs = {};
                    Map<String, double> updatedOriginal1RMs = {};
                    bool allValid = true;
                    for (var lift in oneRMsControllers.keys) {
                      final value = double.tryParse(oneRMsControllers[lift]!.text);
                      if (value != null && value > 0) {
                        updated1RMs[lift] = value;
                        updatedOriginal1RMs[lift] = value;
                      } else {
                        allValid = false;
                        break;
                      }
                    }
                    if (allValid && (updated1RMs.length == current1RMs.length)) {
                      details['1RMs'] = updated1RMs;
                      details['original1RMs'] = updatedOriginal1RMs;
                      details['originalUnit'] = unit;
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter valid 1RMs for all lifts')));
                      return;
                    }
                  }
                  details['unit'] = unit;
                  programs[programIndex]['details'] = details;
                  await DatabaseHelper.savePrograms(programs);
                  Navigator.pop(context);
                  onUpdate();
                  print('Updated 1RM for ${program['name']} with unit: $unit');
                }
              } catch (e) {
                print('Error updating 1RM: $e');
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating 1RM: $e')));
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  static void showCompleteWeekDialog({
    required BuildContext context,
    required String programName,
    required String programId,
    required VoidCallback onComplete,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Week'),
        content: Text('Are you sure you want to complete the current week for "$programName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await DatabaseHelper.incrementProgramWeek(programId);
                Navigator.pop(context);
                onComplete();
                print('Completed week for $programName');
              } catch (e) {
                print('Error completing week: $e');
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error completing week: $e')));
              }
            },
            child: const Text('Complete', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  static void showDeleteWorkoutLogDialog({
    required BuildContext context,
    required String programId,
    required int index,
    required VoidCallback onDelete,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Workout Log'),
        content: const Text('Are you sure you want to delete this workout log entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final currentLog = await DatabaseHelper.getProgramLog(programId);
                currentLog.removeAt(index);
                await DatabaseHelper.saveProgramLog(programId, currentLog);
                Navigator.pop(context);
                onDelete();
                print('Deleted workout log entry at index $index');
              } catch (e) {
                print('Error deleting workout log: $e');
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting workout log: $e')));
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  static void showLogWorkoutDialog({
    required BuildContext context,
    required String lift,
    required List<Map<String, dynamic>> sets,
    required String unit,
    required String programId,
    required VoidCallback onSave,
  }) {
    final date = DateTime.now().toIso8601String().split('T')[0];
    final logEntry = {
      'date': date,
      'lift': lift,
      'sets': sets.map((set) {
        return {
          'weight': set['weight'] as double,
          'reps': set['reps'] as int,
          'completedReps': 0,
        };
      }).toList(),
    };

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text('Log $lift Workout'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: (logEntry['sets'] as List?)?.asMap().entries.map<Widget>((entry) {
                  if (entry.value == null) return const SizedBox.shrink();
                  final setIndex = entry.key + 1;
                  final set = entry.value as Map<String, dynamic>;
                  final weight = set['weight'] as double;
                  final reps = set['reps'] as int;
                  TextEditingController repsController = TextEditingController(text: '');

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text('Set $setIndex: $weight $unit x $reps reps'),
                        ),
                        SizedBox(
                          width: 100,
                          child: TextField(
                            controller: repsController,
                            decoration: InputDecoration(
                              labelText: 'Reps Done',
                              border: const OutlineInputBorder(),
                              hintText: '',
                            ),
                            keyboardType: TextInputType.number,
                            onTap: () {
                              if (repsController.text.isEmpty || repsController.text == '0') {
                                repsController.clear();
                              }
                            },
                            onChanged: (value) {
                              final completedReps = int.tryParse(value) ?? 0;
                              set['completedReps'] = completedReps;
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList() ?? <Widget>[],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    final currentLog = await DatabaseHelper.getProgramLog(programId);
                    currentLog.add(logEntry);
                    await DatabaseHelper.saveProgramLog(programId, currentLog);
                    Navigator.pop(context);
                    onSave();
                    print('Logged workout for $lift with sets: $logEntry, unit: $unit');
                  } catch (e) {
                    print('Error logging workout: $e');
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error logging workout: $e')));
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }
}