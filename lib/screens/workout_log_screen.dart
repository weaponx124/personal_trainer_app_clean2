import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_trainer_app_clean/core/data/models/workout.dart';
import 'package:personal_trainer_app_clean/core/data/repositories/workout_repository.dart';
import 'package:personal_trainer_app_clean/main.dart';
import 'package:personal_trainer_app_clean/utils/cross_painter.dart';

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
            backgroundColor: const Color(0xFF1C2526),
            foregroundColor: const Color(0xFFB0B7BF),
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
                      return const Center(child: CircularProgressIndicator(color: Color(0xFFB22222)));
                    }
                    if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Text(
                          'No workouts logged.',
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            color: const Color(0xFF1C2526),
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _workouts.length,
                      itemBuilder: (context, index) {
                        final workout = _workouts[index];
                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          color: const Color(0xFFB0B7BF),
                          child: ListTile(
                            title: Text(
                              workout.name,
                              style: GoogleFonts.oswald(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFB22222),
                              ),
                            ),
                            subtitle: Text(
                              'Date: ${DateTime.fromMillisecondsSinceEpoch(workout.timestamp).toString()}',
                              style: GoogleFonts.roboto(
                                fontSize: 14,
                                color: const Color(0xFF808080),
                              ),
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
            backgroundColor: const Color(0xFFB22222),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }
}