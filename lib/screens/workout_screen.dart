import 'package:flutter/material.dart';
import 'package:personal_trainer_app_clean/database_helper.dart';
import 'package:personal_trainer_app_clean/main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';

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

  Future<void> _logWorkout() async {
    await DatabaseHelper.insertWorkout({
      'exercise': _exerciseController.text,
      'weight': double.parse(_weightController.text),
      'date': DateTime.now().toIso8601String(),
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: unitNotifier,
      builder: (context, unit, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Log Your Workout'),
            backgroundColor: const Color(0xFF1C2526),
            foregroundColor: const Color(0xFFB0B7BF),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFFB0B7BF)),
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
                colors: [const Color(0xFF87CEEB).withOpacity(0.2), const Color(0xFF1C2526)],
              ),
            ),
            child: Stack(
              children: [
                // Subtle Cross Background (already present)
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.1,
                    child: CustomPaint(
                      painter: CrossPainter(),
                      child: Container(),
                    ),
                  ),
                ),
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FadeIn(
                        duration: const Duration(milliseconds: 800),
                        child: Text(
                          'Log Your Workout',
                          style: Theme.of(context).textTheme.headlineLarge,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _exerciseController,
                        decoration: InputDecoration(
                          labelText: 'Exercise',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _weightController,
                        decoration: InputDecoration(
                          labelText: 'Weight ($unit)',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.secondary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _logWorkout,
                        child: const Text('Save Workout'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Custom painter for cross background
class CrossPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF87CEEB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    const double crossSize = 100.0;
    for (double x = 0; x < size.width; x += crossSize * 1.5) {
      for (double y = 0; y < size.height; y += crossSize * 1.5) {
        canvas.drawLine(
          Offset(x + crossSize / 2, y),
          Offset(x + crossSize / 2, y + crossSize),
          paint,
        );
        canvas.drawLine(
          Offset(x + crossSize / 4, y + crossSize / 2),
          Offset(x + 3 * crossSize / 4, y + crossSize / 2),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}