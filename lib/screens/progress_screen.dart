import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_trainer_app_clean/database_helper.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:personal_trainer_app_clean/utils/cross_painter.dart';

class ProgressScreen extends StatefulWidget {
  final String unit;

  const ProgressScreen({super.key, required this.unit});

  @override
  _ProgressScreenState createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  late Future<List<Map<String, dynamic>>> _workoutsFuture;
  List<Map<String, dynamic>> _workouts = [];
  String _selectedExercise = 'All Exercises';
  List<String> _exerciseOptions = ['All Exercises'];
  double _maxWeight = 0.0;
  double _totalWeight = 0.0;
  int _workoutCount = 0;

  @override
  void initState() {
    super.initState();
    _workoutsFuture = DatabaseHelper.getWorkouts();
    _loadWorkouts();
  }

  Future<void> _loadWorkouts() async {
    final workouts = await _workoutsFuture;
    setState(() {
      _workouts = List.from(workouts);
      _updateExerciseOptions(workouts);
      _updateStats();
    });
  }

  void _updateExerciseOptions(List<Map<String, dynamic>> workouts) {
    final exercises = workouts.map((w) => w['exercise'] as String).toSet().toList();
    exercises.sort();
    _exerciseOptions = ['All Exercises', ...exercises];
    if (!_exerciseOptions.contains(_selectedExercise)) {
      _selectedExercise = 'All Exercises';
    }
  }

  void _updateStats() {
    List<Map<String, dynamic>> filteredWorkouts = _workouts;
    if (_selectedExercise != 'All Exercises') {
      filteredWorkouts = _workouts.where((w) => w['exercise'] == _selectedExercise).toList();
    }

    if (filteredWorkouts.isEmpty) {
      _maxWeight = 0.0;
      _totalWeight = 0.0;
      _workoutCount = 0;
      return;
    }

    _workoutCount = filteredWorkouts.length;
    _totalWeight = filteredWorkouts.fold(0.0, (sum, w) => sum + (w['weight'] as num).toDouble());
    _maxWeight = filteredWorkouts
        .map((w) => (w['weight'] as num).toDouble())
        .reduce((a, b) => a > b ? a : b);
  }

  List<FlSpot> _getSpots() {
    List<Map<String, dynamic>> filteredWorkouts = _workouts;
    if (_selectedExercise != 'All Exercises') {
      filteredWorkouts = _workouts.where((w) => w['exercise'] == _selectedExercise).toList();
    }

    if (filteredWorkouts.isEmpty) return [];

    // Sort by timestamp to ensure chronological order
    filteredWorkouts.sort((a, b) => (a['timestamp'] as int).compareTo(b['timestamp'] as int));

    // Normalize timestamps to x-axis (0 to length-1)
    return filteredWorkouts.asMap().entries.map((entry) {
      final index = entry.key.toDouble();
      final weight = (entry.value['weight'] as num).toDouble();
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
                  // Exercise Selection Dropdown
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
                  // Statistics Section
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
                  // Line Graph Section
                  Expanded(
                    child: FutureBuilder<List<Map<String, dynamic>>>(
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
                                                '', // Hide x-axis labels for simplicity
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
          // Refresh workouts after adding a new one
          setState(() {
            _workoutsFuture = DatabaseHelper.getWorkouts();
            _loadWorkouts();
          });
        },
        backgroundColor: const Color(0xFFB22222),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}