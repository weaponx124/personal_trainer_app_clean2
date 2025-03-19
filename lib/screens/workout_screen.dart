import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_trainer_app_clean/database_helper.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  _WorkoutScreenState createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  final TextEditingController _exerciseController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  @override
  void dispose() {
    _exerciseController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _saveWorkout() async {
    final exercise = _exerciseController.text;
    final weight = double.tryParse(_weightController.text) ?? 0.0;

    if (exercise.isNotEmpty && weight > 0) {
      await DatabaseHelper.insertWorkout({
        'exercise': exercise,
        'weight': weight,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid exercise and weight')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Workout'),
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
          child: Column(
            children: [
              TextField(
                controller: _exerciseController,
                decoration: InputDecoration(
                  labelText: 'Exercise',
                  labelStyle: GoogleFonts.roboto(
                    fontSize: 16,
                    color: const Color(0xFF808080),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFB0B7BF),
                ),
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  color: const Color(0xFF1C2526),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Weight',
                  labelStyle: GoogleFonts.roboto(
                    fontSize: 16,
                    color: const Color(0xFF808080),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFB0B7BF),
                ),
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  color: const Color(0xFF1C2526),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveWorkout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB22222),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Save Workout', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}