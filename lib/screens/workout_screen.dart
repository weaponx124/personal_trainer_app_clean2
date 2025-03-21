import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_trainer_app_clean/core/data/models/workout.dart';
import 'package:personal_trainer_app_clean/core/data/repositories/workout_repository.dart';
import 'package:personal_trainer_app_clean/utils/cross_painter.dart';
import 'package:personal_trainer_app_clean/widgets/common/loading_indicator.dart';
import 'package:personal_trainer_app_clean/widgets/common/app_snack_bar.dart';
import 'package:personal_trainer_app_clean/core/theme/app_theme.dart'; // Added import

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  _WorkoutScreenState createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  final WorkoutRepository _workoutRepository = WorkoutRepository();
  final TextEditingController _exerciseController = TextEditingController();
  final TextEditingController _setsController = TextEditingController();
  final TextEditingController _repsController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  List<Map<String, dynamic>> _exercises = [];
  bool _isSaving = false;

  void _addExercise() {
    if (_exerciseController.text.isNotEmpty &&
        _setsController.text.isNotEmpty &&
        _repsController.text.isNotEmpty &&
        _weightController.text.isNotEmpty) {
      setState(() {
        _exercises.add({
          'name': _exerciseController.text,
          'sets': int.tryParse(_setsController.text) ?? 0,
          'reps': int.tryParse(_repsController.text) ?? 0,
          'weight': double.tryParse(_weightController.text) ?? 0.0,
        });
        _exerciseController.clear();
        _setsController.clear();
        _repsController.clear();
        _weightController.clear();
      });
      AppSnackBar.showSuccess(context, 'Exercise added to workout');
    } else {
      AppSnackBar.showError(context, 'Please fill in all fields');
    }
  }

  Future<void> _saveWorkout() async {
    if (_exercises.isNotEmpty) {
      setState(() {
        _isSaving = true;
      });
      try {
        final workout = Workout(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          programId: 'default_program',
          name: _exercises.first['name'],
          exercises: _exercises,
          timestamp: DateTime.now().millisecondsSinceEpoch,
        );
        await _workoutRepository.insertWorkout('default_program', workout);
        AppSnackBar.showSuccess(context, 'Workout saved successfully');
        Navigator.pop(context);
      } catch (e) {
        AppSnackBar.showError(context, 'Failed to save workout: $e');
      } finally {
        setState(() {
          _isSaving = false;
        });
      }
    } else {
      AppSnackBar.showError(context, 'Please add at least one exercise');
    }
  }

  @override
  void dispose() {
    _exerciseController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Workout'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.lightBlue.withOpacity(0.2), AppTheme.matteBlack],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.1,
                child: CustomPaint(
                  painter: CrossPainter(),
                  child: Container(),
                ),
              ),
            ),
            if (_isSaving)
              const Center(child: LoadingIndicator())
            else
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _exerciseController,
                      decoration: InputDecoration(
                        labelText: 'Exercise Name',
                        labelStyle: Theme.of(context).textTheme.bodySmall,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                      ),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _setsController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Sets',
                              labelStyle: Theme.of(context).textTheme.bodySmall,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surface,
                            ),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _repsController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Reps',
                              labelStyle: Theme.of(context).textTheme.bodySmall,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surface,
                            ),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _weightController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Weight',
                              labelStyle: Theme.of(context).textTheme.bodySmall,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surface,
                            ),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _addExercise,
                      child: const Text('Add Exercise'),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _exercises.length,
                        itemBuilder: (context, index) {
                          final exercise = _exercises[index];
                          return Card(
                            child: ListTile(
                              title: Text(
                                exercise['name'],
                                style: Theme.of(context).textTheme.headlineMedium,
                              ),
                              subtitle: Text(
                                '${exercise['sets']} sets x ${exercise['reps']} reps @ ${exercise['weight']}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _saveWorkout,
                      child: const Text('Save Workout'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}