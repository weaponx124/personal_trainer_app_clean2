import 'package:flutter/material.dart';
import 'package:personal_trainer_app_clean/core/data/models/program.dart';
import 'package:personal_trainer_app_clean/core/data/repositories/program_repository.dart';

void startProgram(
    BuildContext context,
    String programName,
    bool requires1RM,
    Map<String, dynamic>? oneRMs,
    bool requires1RMInput,
    List<String>? lifts,
    Function refreshCallback,
    String unit,
    ) {
  if (requires1RMInput && (oneRMs == null || oneRMs.isEmpty)) {
    _show1RMDialog(context, programName, lifts ?? [], refreshCallback, unit);
  } else {
    _saveAndStartProgram(context, programName, oneRMs, refreshCallback);
  }
}

void _show1RMDialog(
    BuildContext context,
    String programName,
    List<String> lifts,
    Function refreshCallback,
    String unit,
    ) {
  final oneRMs = <String, double>{};
  final controllers = lifts.map((lift) => TextEditingController()).toList();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Enter Your 1RMs ($unit)'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(lifts.length, (index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextField(
                controller: controllers[index],
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: '${lifts[index]} 1RM ($unit)',
                  border: const OutlineInputBorder(),
                ),
              ),
            );
          }),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            for (int i = 0; i < lifts.length; i++) {
              final value = double.tryParse(controllers[i].text) ?? 0.0;
              oneRMs[lifts[i]] = value;
            }
            Navigator.pop(context);
            _saveAndStartProgram(context, programName, oneRMs, refreshCallback);
          },
          child: const Text('Start Program'),
        ),
      ],
    ),
  );
}

void _saveAndStartProgram(
    BuildContext context,
    String programName,
    Map<String, dynamic>? oneRMs,
    Function refreshCallback,
    ) async {
  final programRepository = ProgramRepository();
  final program = Program(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    name: programName,
    description: oneRMs != null ? '1RMs: ${oneRMs.toString()}' : '',
  );
  await programRepository.insertProgram(program);
  refreshCallback();
  Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
}