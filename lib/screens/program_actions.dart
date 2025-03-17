// lib/screens/program_actions.dart
import 'package:flutter/material.dart';
import '../database_helper.dart';
import 'custom_program_form.dart'; // Import the new CustomProgramForm file

void startProgram(
    BuildContext context,
    String programName,
    bool isNewInstance,
    String? programId,
    bool requires1RM,
    List<String>? lifts,
    Function() loadPrograms,
    String unit, // Pass unit directly to avoid context lookup
    ) {
  print('Starting program: $programName, isNewInstance: $isNewInstance, programId: $programId, requires1RM: $requires1RM, lifts: $lifts');
  Map<String, dynamic> programInputs = {};

  void _showProgramDialog(String programName, bool isNewInstance, String? programId, bool requires1RM, List<String>? lifts) async {
    if (!isNewInstance) {
      final result = await Navigator.pushNamed(
        context,
        '/program_details',
        arguments: {'programId': programId, 'unit': unit},
      );
      if (result == true) {
        loadPrograms();
      }
      return;
    }

    print('Showing dialog for program: $programName, unit: $unit, requires1RM: $requires1RM, lifts: $lifts');
    if (requires1RM && lifts != null && lifts.length == 4) {
      programInputs['1RMs'] = <String, double>{};
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Start ${programName} (New Cycle)'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: lifts.map((lift) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Enter $lift 1RM ($unit)',
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final parsedValue = double.tryParse(value);
                      final oneRMs = programInputs['1RMs'];
                      if (parsedValue != null && parsedValue > 0) {
                        oneRMs[lift] = parsedValue;
                      } else {
                        oneRMs.remove(lift);
                      }
                      print('Updated 1RMs in dialog: ${programInputs['1RMs']}');
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final oneRMs = programInputs['1RMs'] as Map<String, double>? ?? {};
                final allValid = oneRMs.length == 4 && oneRMs.values.every((v) => v is double && v > 0);
                if (allValid) {
                  programInputs['unit'] = unit;
                  try {
                    await DatabaseHelper.saveProgram(programName, programInputs);
                    loadPrograms();
                    final programs = await DatabaseHelper.getPrograms();
                    final newProgram = programs.lastWhere((p) => p['name'] == programName);
                    print('Saved program with 1RMs: ${newProgram['details']['1RMs']}'); // Debug print
                    Navigator.pop(context);
                    Navigator.pushNamed(
                      context,
                      '/program_details',
                      arguments: {'programId': newProgram['id'], 'unit': unit},
                    );
                    print('Program list refreshed after starting new $programName cycle');
                  } catch (e) {
                    print('Error saving new $programName cycle: $e');
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving program: $e')));
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter all 1RMs with valid values!')));
                }
              },
              child: const Text('Start'),
            ),
          ],
        ),
      );
    } else if (requires1RM && lifts != null && lifts.length == 3) {
      programInputs['1RMs'] = <String, double>{};
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Start ${programName} (New Cycle)'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: lifts.map((lift) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Enter $lift 1RM ($unit)',
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final parsedValue = double.tryParse(value);
                      final oneRMs = programInputs['1RMs'] as Map<String, double>;
                      if (parsedValue != null && parsedValue > 0) {
                        oneRMs[lift] = parsedValue;
                      } else {
                        oneRMs.remove(lift);
                      }
                      print('Updated 1RMs: ${programInputs['1RMs']}');
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final oneRMs = programInputs['1RMs'] as Map<String, double>? ?? {};
                final allValid = oneRMs.length == 3 && oneRMs.values.every((v) => v is double && v > 0);
                if (allValid) {
                  programInputs['unit'] = unit;
                  try {
                    await DatabaseHelper.saveProgram(programName, programInputs);
                    loadPrograms();
                    final programs = await DatabaseHelper.getPrograms();
                    final newProgram = programs.lastWhere((p) => p['name'] == programName);
                    print('Saved program with 1RMs: ${newProgram['details']['1RMs']}'); // Debug print
                    Navigator.pop(context);
                    Navigator.pushNamed(
                      context,
                      '/program_details',
                      arguments: {'programId': newProgram['id'], 'unit': unit},
                    );
                    print('Program list refreshed after starting new $programName cycle');
                  } catch (e) {
                    print('Error saving new $programName cycle: $e');
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving program: $e')));
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter all 1RMs with valid values!')));
                }
              },
              child: const Text('Start'),
            ),
          ],
        ),
      );
    } else if (requires1RM && lifts != null && lifts.length == 1) {
      double oneRMIncrement = unit == 'kg' ? 2.5 : 5.0;
      String? selectedIncrement;

      showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: Text('Start ${programName} (New Cycle)'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Enter 1RM ($unit)',
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final parsedValue = double.tryParse(value);
                      programInputs['1RM'] = parsedValue ?? 0.0;
                      print('Updated 1RM: ${programInputs['1RM']}');
                    },
                  ),
                  const SizedBox(height: 16),
                  Text('Select 1RM Increment After Cycle ($unit)'),
                  DropdownButton<String>(
                    value: selectedIncrement,
                    hint: const Text('Select Increment'),
                    items: unit == 'kg'
                        ? ['1.25', '2.5', '5'].map((value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList()
                        : ['2.5', '5', '10'].map((value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedIncrement = value;
                        oneRMIncrement = double.parse(value!);
                      });
                    },
                  ),
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
                  final oneRM = programInputs['1RM'] as double?;
                  if (oneRM != null && oneRM > 0 && selectedIncrement != null) {
                    programInputs['unit'] = unit;
                    programInputs['oneRMIncrement'] = oneRMIncrement;
                    try {
                      await DatabaseHelper.saveProgram(programName, programInputs);
                      loadPrograms();
                      final programs = await DatabaseHelper.getPrograms();
                      final newProgram = programs.lastWhere((p) => p['name'] == programName);
                      print('Saved program with 1RM: ${newProgram['details']['1RM']}, Increment: ${newProgram['details']['oneRMIncrement']}'); // Debug print
                      Navigator.pop(context);
                      Navigator.pushNamed(
                        context,
                        '/program_details',
                        arguments: {'programId': newProgram['id'], 'unit': unit},
                      );
                      print('Program list refreshed after starting new $programName cycle');
                    } catch (e) {
                      print('Error saving new $programName cycle: $e');
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving program: $e')));
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid 1RM and select an increment!')));
                  }
                },
                child: const Text('Start'),
              ),
            ],
          ),
        ),
      );
    } else {
      // For programs not requiring 1RM (e.g., PPL, Starting Strength, etc.)
      programInputs['unit'] = unit;
      try {
        await DatabaseHelper.saveProgram(programName, programInputs);
        loadPrograms();
        final programs = await DatabaseHelper.getPrograms();
        final newProgram = programs.lastWhere((p) => p['name'] == programName);
        Navigator.pushNamed(
          context,
          '/program_details',
          arguments: {'programId': newProgram['id'], 'unit': unit},
        );
        print('Program list refreshed after starting new $programName cycle');
      } catch (e) {
        print('Error saving new $programName cycle: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving program: $e')));
      }
    }
  }

  _showProgramDialog(programName, isNewInstance, programId, requires1RM, lifts);
}

void editProgram(
    BuildContext context,
    String programId,
    Function() loadPrograms,
    String unit, // Pass unit directly
    ) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Edit Program'),
      content: SingleChildScrollView(
        child: FutureBuilder<Map<String, dynamic>>(
          future: DatabaseHelper.getProgram(programId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const CircularProgressIndicator();
            final program = snapshot.data!;
            bool isCompleted = program['completed'] ?? false;
            TextEditingController oneRMController = TextEditingController(text: (program['details']?['1RM'] as double?)?.toString() ?? '');
            Map<String, TextEditingController> oneRMsControllers = {
              'Squat': TextEditingController(text: (program['details']?['1RMs']?['Squat'] as double?)?.toString() ?? ''),
              'Bench': TextEditingController(text: (program['details']?['1RMs']?['Bench'] as double?)?.toString() ?? ''),
              'Deadlift': TextEditingController(text: (program['details']?['1RMs']?['Deadlift'] as double?)?.toString() ?? ''),
              'Overhead': TextEditingController(text: (program['details']?['1RMs']?['Overhead'] as double?)?.toString() ?? ''),
            };

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  title: const Text('Mark as Completed'),
                  value: isCompleted,
                  onChanged: (value) async {
                    final programs = await DatabaseHelper.getPrograms();
                    final programIndex = programs.indexWhere((p) => p['id'] == programId);
                    if (programIndex >= 0) {
                      programs[programIndex]['completed'] = value;
                      await DatabaseHelper.savePrograms(programs);
                      Navigator.pop(context);
                      loadPrograms();
                      print('Program $programId ${value ? "completed" : "uncompleted"} with unit: $unit');
                    }
                  },
                ),
                if (program['details']?['1RM'] != null)
                  TextField(
                    controller: oneRMController,
                    decoration: InputDecoration(
                      labelText: '1RM ($unit)',
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final parsedValue = double.tryParse(value);
                      if (parsedValue != null && parsedValue > 0) {
                        program['details']['1RM'] = parsedValue;
                        program['details']['original1RM'] = parsedValue;
                        program['details']['originalUnit'] = unit;
                      }
                    },
                  ),
                if (program['details']?['1RMs'] != null)
                  ...['Squat', 'Bench', 'Deadlift', 'Overhead'].map((lift) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TextField(
                        controller: oneRMsControllers[lift]!,
                        decoration: InputDecoration(
                          labelText: '$lift 1RM ($unit)',
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          final parsedValue = double.tryParse(value);
                          final oneRMs = program['details']['1RMs'] as Map<String, dynamic>;
                          final original1RMs = program['details']['original1RMs'] as Map<String, dynamic>;
                          if (parsedValue != null && parsedValue > 0) {
                            oneRMs[lift] = parsedValue;
                            original1RMs[lift] = parsedValue;
                          } else {
                            oneRMs.remove(lift);
                            original1RMs.remove(lift);
                          }
                          program['details']['originalUnit'] = unit;
                        },
                      ),
                    );
                  }),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[700]),
                  onPressed: () async {
                    final programs = await DatabaseHelper.getPrograms();
                    final programIndex = programs.indexWhere((p) => p['id'] == programId);
                    if (programIndex >= 0) {
                      await DatabaseHelper.savePrograms(programs);
                      Navigator.pop(context);
                      loadPrograms();
                      print('Program $programId updated with unit: $unit');
                    }
                  },
                  child: const Text('Save Changes', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    ),
  );
}

void deleteProgram(
    BuildContext context,
    String programId,
    Function() loadPrograms,
    String unit,
    ) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete Program'),
      content: const Text('Are you sure you want to delete this program?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            try {
              await DatabaseHelper.deleteProgram(programId);
              Navigator.pop(context);
              loadPrograms();
              print('Program list refreshed after deleting program with unit: $unit');
            } catch (e) {
              print('Error deleting program: $e');
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting program: $e')));
            }
          },
          child: const Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}

void createCustomProgram(
    BuildContext context,
    String unit,
    Function(String, Map<String, dynamic>) onSave,
    ) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Create Custom Program'),
      content: CustomProgramForm(
        unit: unit,
        onSave: onSave,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    ),
  );
}