import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_trainer_app_clean/core/data/models/workout.dart';
import 'package:personal_trainer_app_clean/core/data/repositories/workout_repository.dart';
import 'package:personal_trainer_app_clean/main.dart';
import 'package:personal_trainer_app_clean/utils/cross_painter.dart';
import 'package:personal_trainer_app_clean/widgets/common/loading_indicator.dart';
import 'package:personal_trainer_app_clean/widgets/common/app_snack_bar.dart';
import 'package:personal_trainer_app_clean/core/theme/app_theme.dart';

class WorkoutLogScreen extends StatefulWidget {
  final String unit;

  const WorkoutLogScreen({super.key, required this.unit});

  @override
  _WorkoutLogScreenState createState() => _WorkoutLogScreenState();
}

class _WorkoutLogScreenState extends State<WorkoutLogScreen> {
  final WorkoutRepository _workoutRepository = WorkoutRepository();
  late Future<List<Workout>> _workoutsFuture;
  List<Workout> _workouts = [];

  @override
  void initState() {
    super.initState();
    _workoutsFuture = _loadAllWorkouts();
    _loadWorkouts();
  }

  Future<List<Workout>> _loadAllWorkouts() async {
    try {
      final programs = ['default_program'];
      List<Workout> allWorkouts = [];
      for (var programId in programs) {
        final workouts = await _workoutRepository.getWorkouts(programId);
        allWorkouts.addAll(workouts);
      }
      return allWorkouts;
    } catch (e) {
      print('Error loading workouts: $e');
      AppSnackBar.showError(context, 'Failed to load workouts: $e');
      return [];
    }
  }

  Future<void> _loadWorkouts() async {
    final workouts = await _workoutsFuture;
    setState(() {
      _workouts = List.from(workouts);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: unitNotifier,
      builder: (context, unit, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Workout Log'),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            foregroundColor: Theme.of(context).colorScheme.onSurface,
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
                FutureBuilder<List<Workout>>(
                  future: _workoutsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const LoadingIndicator();
                    }
                    if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Text(
                          'No workouts logged.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _workouts.length,
                      itemBuilder: (context, index) {
                        final workout = _workouts[index];
                        return Card(
                          child: ListTile(
                            title: Text(
                              workout.name,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            subtitle: Text(
                              'Date: ${DateTime.fromMillisecondsSinceEpoch(workout.timestamp).toString()}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              await Navigator.pushNamed(context, '/workout');
              setState(() {
                _workoutsFuture = _loadAllWorkouts();
                _loadWorkouts();
              });
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}