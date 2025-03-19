import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_trainer_app_clean/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class WorkoutLogScreen extends StatefulWidget {
  final String unit;

  const WorkoutLogScreen({super.key, required this.unit});

  @override
  _WorkoutLogScreenState createState() => _WorkoutLogScreenState();
}

class _WorkoutLogScreenState extends State<WorkoutLogScreen> {
  late Future<List<Map<String, dynamic>>> _allWorkoutsFuture;

  @override
  void initState() {
    super.initState();
    _allWorkoutsFuture = DatabaseHelper.getWorkouts();
  }

  Future<void> _deleteWorkout(String workoutId) async {
    await DatabaseHelper.deleteWorkout(workoutId);
    setState(() {
      _allWorkoutsFuture = DatabaseHelper.getWorkouts();
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
              final workouts = snapshot.data!;
              return ListView.builder(
                itemCount: workouts.length,
                itemBuilder: (context, index) {
                  final workout = workouts[index];
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
      ),
    );
  }
}