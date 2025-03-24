import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_trainer_app_clean/core/data/models/workout.dart';
import 'package:personal_trainer_app_clean/core/data/repositories/workout_repository.dart';
import 'package:personal_trainer_app_clean/main.dart';
import 'package:personal_trainer_app_clean/screens/program_logic.dart';
import 'package:personal_trainer_app_clean/widgets/common/app_snack_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WarmupSetDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;

  const WarmupSetDialog({super.key, required this.onSave});

  @override
  _WarmupSetDialogState createState() => _WarmupSetDialogState();
}

class _WarmupSetDialogState extends State<WarmupSetDialog> {
  final _nameController = TextEditingController();
  final _repsController = TextEditingController();
  final _weightController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _repsController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Warmup Set'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Exercise Name'),
            ),
            TextField(
              controller: _repsController,
              decoration: const InputDecoration(labelText: 'Reps'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _weightController,
              decoration: const InputDecoration(labelText: 'Weight (lbs)'),
              keyboardType: TextInputType.number,
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
          onPressed: () {
            final warmupSet = {
              'name': 'Warmup: ${_nameController.text}',
              'reps': int.tryParse(_repsController.text) ?? 0,
              'weight': double.tryParse(_weightController.text) ?? 0.0,
            };
            widget.onSave(warmupSet);
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class WorkingSetDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;

  const WorkingSetDialog({super.key, required this.onSave});

  @override
  _WorkingSetDialogState createState() => _WorkingSetDialogState();
}

class _WorkingSetDialogState extends State<WorkingSetDialog> {
  final _nameController = TextEditingController();
  final _setsController = TextEditingController();
  final _repsController = TextEditingController();
  final _weightController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Working Set'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Exercise Name'),
            ),
            TextField(
              controller: _setsController,
              decoration: const InputDecoration(labelText: 'Sets'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _repsController,
              decoration: const InputDecoration(labelText: 'Reps'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _weightController,
              decoration: const InputDecoration(labelText: 'Weight (lbs)'),
              keyboardType: TextInputType.number,
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
          onPressed: () {
            final workingSet = {
              'name': _nameController.text,
              'sets': int.tryParse(_setsController.text) ?? 0,
              'reps': int.tryParse(_repsController.text) ?? 0,
              'weight': double.tryParse(_weightController.text) ?? 0.0,
            };
            widget.onSave(workingSet);
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}