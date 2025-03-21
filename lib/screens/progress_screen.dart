import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:personal_trainer_app_clean/core/data/models/workout.dart';
import 'package:personal_trainer_app_clean/core/data/repositories/workout_repository.dart';
import 'package:personal_trainer_app_clean/utils/cross_painter.dart';

class ProgressScreen extends StatefulWidget {
  final String unit;

  const ProgressScreen({super.key, required this.unit});

  @override
  _ProgressScreenState createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final WorkoutRepository _workoutRepository = WorkoutRepository();
  late Future<List<Workout>> _workoutsFuture;
  List<Workout> _workouts = [];
  String _selectedExercise = 'All Exercises';
  List<String> _exerciseOptions = ['All Exercises'];
  double _maxWeight = 0.0;
  double _totalWeight = 0.0;
  int _workoutCount = 0;

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
      _updateExerciseOptions(workouts);
      _updateStats();
    });
  }

  void _updateExerciseOptions(List<Workout> workouts) {
    final exercises = workouts.map((w) => w.name).toSet().toList();
    exercises.sort();
    _exerciseOptions = ['All Exercises', ...exercises];
    if (!_exerciseOptions.contains(_selectedExercise)) {
      _selectedExercise = 'All Exercises';
    }
  }

  void _updateStats() {
    List<Workout> filteredWorkouts = _workouts;
    if (_selectedExercise != 'All Exercises') {
      filteredWorkouts = _workouts.where((w) => w.name == _selectedExercise).toList();
    }

    if (filteredWorkouts.isEmpty) {
      _maxWeight = 0.0;
      _totalWeight = 0.0;
      _workoutCount = 0;
      return;
    }

    _workoutCount = filteredWorkouts.length;
    _totalWeight = filteredWorkouts.fold(0.0, (sum, w) {
      return sum + (w.exercises.isNotEmpty ? (w.exercises.first['weight'] as num?)?.toDouble() ?? 0.0 : 0.0);
    });
    _maxWeight = filteredWorkouts
        .map((w) => w.exercises.isNotEmpty ? (w.exercises.first['weight'] as num?)?.toDouble() ?? 0.0 : 0.0)
        .reduce((a, b) => a > b ? a : b);
  }

  List<FlSpot> _getSpots() {
    List<Workout> filteredWorkouts = _workouts;
    if (_selectedExercise != 'All Exercises') {
      filteredWorkouts = _workouts.where((w) => w.name == _selectedExercise).toList();
    }

    if (filteredWorkouts.isEmpty) return [];

    filteredWorkouts.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return filteredWorkouts.asMap().entries.map((entry) {
      final index = entry.key.toDouble();
      final weight = entry.value.exercises.isNotEmpty
          ? (entry.value.exercises.first['weight'] as num?)?.toDouble() ?? 0.0
          : 0.0;
      return FlSpot(index, weight);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress'),
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButton<String>(
                    value: _selectedExercise,
                    isExpanded: true,
                    items: _exerciseOptions.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            color: const Color(0xFF1C2526),
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedExercise = newValue;
                          _updateStats();
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    color: const Color(0xFFB0B7BF),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Progress Statistics',
                            style: GoogleFonts.oswald(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFB22222),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Workouts: $_workoutCount',
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              color: const Color(0xFF1C2526),
                            ),
                          ),
                          Text(
                            'Total Weight Lifted: ${_totalWeight.toStringAsFixed(1)} ${widget.unit}',
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              color: const Color(0xFF1C2526),
                            ),
                          ),
                          Text(
                            'Max Weight: ${_maxWeight.toStringAsFixed(1)} ${widget.unit}',
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              color: const Color(0xFF1C2526),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: FutureBuilder<List<Workout>>(
                      future: _workoutsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator(color: Color(0xFFB22222)));
                        }
                        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                          return Center(
                            child: Text(
                              'No workout data available.',
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                color: const Color(0xFF1C2526),
                              ),
                            ),
                          );
                        }
                        final spots = _getSpots();
                        if (spots.isEmpty) {
                          return Center(
                            child: Text(
                              'No data for selected exercise.',
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                color: const Color(0xFF1C2526),
                              ),
                            ),
                          );
                        }
                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          color: const Color(0xFFB0B7BF),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Weight Lifted Over Time',
                                  style: GoogleFonts.oswald(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFFB22222),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Expanded(
                                  child: LineChart(
                                    LineChartData(
                                      gridData: const FlGridData(show: false),
                                      titlesData: FlTitlesData(
                                        leftTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 40,
                                            getTitlesWidget: (value, meta) {
                                              return Text(
                                                value.toInt().toString(),
                                                style: GoogleFonts.roboto(
                                                  fontSize: 12,
                                                  color: const Color(0xFF808080),
                                                ),
                                              );
                                            },
                                          ),
                                          axisNameWidget: Text(
                                            'Weight (${widget.unit})',
                                            style: GoogleFonts.roboto(
                                              fontSize: 14,
                                              color: const Color(0xFF1C2526),
                                            ),
                                          ),
                                        ),
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            getTitlesWidget: (value, meta) {
                                              return Text(
                                                '',
                                              );
                                            },
                                          ),
                                          axisNameWidget: Text(
                                            'Workouts Over Time',
                                            style: GoogleFonts.roboto(
                                              fontSize: 14,
                                              color: const Color(0xFF1C2526),
                                            ),
                                          ),
                                        ),
                                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      ),
                                      borderData: FlBorderData(show: false),
                                      lineBarsData: [
                                        LineChartBarData(
                                          spots: spots,
                                          isCurved: true,
                                          color: const Color(0xFFB22222),
                                          barWidth: 3,
                                          dotData: const FlDotData(show: false),
                                          belowBarData: BarAreaData(
                                            show: true,
                                            color: const Color(0xFFB22222).withOpacity(0.2),
                                          ),
                                        ),
                                      ],
                                    ),
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
  }
}