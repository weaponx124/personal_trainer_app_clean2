import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_trainer_app_clean/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:personal_trainer_app_clean/utils/cross_painter.dart'; // Import CrossPainter

class WorkoutLogScreen extends StatefulWidget {
  final String unit;

  const WorkoutLogScreen({super.key, required this.unit});

  @override
  _WorkoutLogScreenState createState() => _WorkoutLogScreenState();
}

class _WorkoutLogScreenState extends State<WorkoutLogScreen> {
  late Future<List<Map<String, dynamic>>> _allWorkoutsFuture;
  List<Map<String, dynamic>> _filteredWorkouts = [];
  String _filterDateRange = 'All Time'; // Options: All Time, Last 7 Days, Last 30 Days
  String _filterExercise = 'All Exercises'; // Default: show all exercises
  List<String> _exerciseOptions = ['All Exercises'];
  String _sortOption = 'Date Descending'; // Options: Date Ascending, Date Descending, Weight Ascending, Weight Descending
  int _totalWorkouts = 0;
  double _averageWeight = 0.0;
  String _mostFrequentExercise = 'N/A';

  @override
  void initState() {
    super.initState();
    _allWorkoutsFuture = DatabaseHelper.getWorkouts();
    _loadWorkouts();
  }

  Future<void> _loadWorkouts() async {
    final workouts = await _allWorkoutsFuture;
    setState(() {
      _filteredWorkouts = List.from(workouts);
      _computeStatistics(workouts);
      _updateExerciseOptions(workouts);
      _applyFiltersAndSort();
    });
  }

  void _computeStatistics(List<Map<String, dynamic>> workouts) {
    if (workouts.isEmpty) {
      _totalWorkouts = 0;
      _averageWeight = 0.0;
      _mostFrequentExercise = 'N/A';
      return;
    }

    // Total workouts
    _totalWorkouts = workouts.length;

    // Average weight
    double totalWeight = 0.0;
    for (var workout in workouts) {
      totalWeight += (workout['weight'] as num).toDouble();
    }
    _averageWeight = totalWeight / workouts.length;

    // Most frequent exercise
    Map<String, int> exerciseCount = {};
    for (var workout in workouts) {
      final exercise = workout['exercise'] as String;
      exerciseCount[exercise] = (exerciseCount[exercise] ?? 0) + 1;
    }
    _mostFrequentExercise = exerciseCount.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  void _updateExerciseOptions(List<Map<String, dynamic>> workouts) {
    final exercises = workouts.map((w) => w['exercise'] as String).toSet().toList();
    exercises.sort();
    _exerciseOptions = ['All Exercises', ...exercises];
  }

  void _applyFiltersAndSort() {
    List<Map<String, dynamic>> filtered = List.from(_filteredWorkouts);

    // Apply date range filter
    if (_filterDateRange != 'All Time') {
      final now = DateTime.now();
      DateTime startDate;
      if (_filterDateRange == 'Last 7 Days') {
        startDate = now.subtract(const Duration(days: 7));
      } else {
        startDate = now.subtract(const Duration(days: 30));
      }
      filtered = filtered.where((workout) {
        final timestamp = workout['timestamp'] as int?;
        if (timestamp == null) return false;
        final workoutDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
        return workoutDate.isAfter(startDate) || workoutDate.isAtSameMomentAs(startDate);
      }).toList();
    }

    // Apply exercise filter
    if (_filterExercise != 'All Exercises') {
      filtered = filtered.where((workout) => workout['exercise'] == _filterExercise).toList();
    }

    // Apply sorting
    switch (_sortOption) {
      case 'Date Ascending':
        filtered.sort((a, b) => (a['timestamp'] as int).compareTo(b['timestamp'] as int));
        break;
      case 'Date Descending':
        filtered.sort((a, b) => (b['timestamp'] as int).compareTo(a['timestamp'] as int));
        break;
      case 'Weight Ascending':
        filtered.sort((a, b) => (a['weight'] as num).compareTo(b['weight'] as num));
        break;
      case 'Weight Descending':
        filtered.sort((a, b) => (b['weight'] as num).compareTo(a['weight'] as num));
        break;
    }

    setState(() {
      _filteredWorkouts = filtered;
    });
  }

  Future<void> _deleteWorkout(String workoutId) async {
    await DatabaseHelper.deleteWorkout(workoutId);
    setState(() {
      _allWorkoutsFuture = DatabaseHelper.getWorkouts();
      _loadWorkouts();
    });
  }

  Future<void> _editWorkout(Map<String, dynamic> workout) async {
    final TextEditingController exerciseController = TextEditingController(text: workout['exercise']);
    final TextEditingController weightController = TextEditingController(text: workout['weight'].toString());

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Workout'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: exerciseController,
              decoration: InputDecoration(
                labelText: 'Exercise',
                labelStyle: GoogleFonts.roboto(
                  fontSize: 16,
                  color: const Color(0xFF808080),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              style: GoogleFonts.roboto(
                fontSize: 16,
                color: const Color(0xFF1C2526),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Weight (${widget.unit})',
                labelStyle: GoogleFonts.roboto(
                  fontSize: 16,
                  color: const Color(0xFF808080),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              style: GoogleFonts.roboto(
                fontSize: 16,
                color: const Color(0xFF1C2526),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final updatedWorkout = {
                'id': workout['id'],
                'exercise': exerciseController.text.trim(),
                'weight': double.tryParse(weightController.text.trim()) ?? workout['weight'],
                'timestamp': workout['timestamp'],
              };
              Navigator.pop(context, updatedWorkout);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null) {
      final workouts = await DatabaseHelper.getWorkouts();
      final index = workouts.indexWhere((w) => w['id'] == workout['id']);
      if (index != -1) {
        workouts[index] = result;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('workouts', jsonEncode(workouts));
        setState(() {
          _allWorkoutsFuture = DatabaseHelper.getWorkouts();
          _loadWorkouts();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
                            'Statistics',
                            style: GoogleFonts.oswald(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFB22222),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Total Workouts: $_totalWorkouts',
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              color: const Color(0xFF1C2526),
                            ),
                          ),
                          Text(
                            'Average Weight: ${_averageWeight.toStringAsFixed(1)} ${widget.unit}',
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              color: const Color(0xFF1C2526),
                            ),
                          ),
                          Text(
                            'Most Frequent Exercise: $_mostFrequentExercise',
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
                  // Filter and Sort Section
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButton<String>(
                          value: _filterDateRange,
                          isExpanded: true,
                          items: <String>['All Time', 'Last 7 Days', 'Last 30 Days'].map((String value) {
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
                                _filterDateRange = newValue;
                                _applyFiltersAndSort();
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButton<String>(
                          value: _filterExercise,
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
                                _filterExercise = newValue;
                                _applyFiltersAndSort();
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    value: _sortOption,
                    isExpanded: true,
                    items: <String>['Date Ascending', 'Date Descending', 'Weight Ascending', 'Weight Descending'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          'Sort by: $value',
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
                          _sortOption = newValue;
                          _applyFiltersAndSort();
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  // Workout List
                  Expanded(
                    child: FutureBuilder<List<Map<String, dynamic>>>(
                      future: _allWorkoutsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator(color: Color(0xFFB22222)));
                        }
                        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                          return Center(
                            child: Text(
                              'No workouts logged yet.',
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                color: const Color(0xFF1C2526),
                              ),
                            ),
                          );
                        }
                        return ListView.builder(
                          itemCount: _filteredWorkouts.length,
                          itemBuilder: (context, index) {
                            final workout = _filteredWorkouts[index];
                            final timestamp = workout['timestamp'] as int?;
                            final date = timestamp != null
                                ? DateTime.fromMillisecondsSinceEpoch(timestamp).toString().split(' ')[0]
                                : 'Unknown Date';
                            return Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              color: const Color(0xFFB0B7BF),
                              child: ListTile(
                                title: Text(
                                  '${workout['exercise']}: ${workout['weight']} ${widget.unit}',
                                  style: GoogleFonts.roboto(
                                    fontSize: 16,
                                    color: const Color(0xFF1C2526),
                                  ),
                                ),
                                subtitle: Text(
                                  'Date: $date',
                                  style: GoogleFonts.roboto(
                                    fontSize: 14,
                                    color: const Color(0xFF808080),
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Color(0xFFB22222)),
                                      onPressed: () => _editWorkout(workout),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Color(0xFFB22222)),
                                      onPressed: () => _deleteWorkout(workout['id']),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
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
            _allWorkoutsFuture = DatabaseHelper.getWorkouts();
            _loadWorkouts();
          });
        },
        backgroundColor: const Color(0xFFB22222),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}