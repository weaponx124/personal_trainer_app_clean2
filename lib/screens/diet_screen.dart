import 'package:flutter/material.dart';
import 'package:personal_trainer_app_clean/main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';

class DietScreen extends StatefulWidget {
  const DietScreen({super.key});

  @override
  _DietScreenState createState() => _DietScreenState();
}

class _DietScreenState extends State<DietScreen> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: unitNotifier,
      builder: (context, unit, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Nutrition Hub'),
            backgroundColor: const Color(0xFF1C2526), // Matte Black
            foregroundColor: const Color(0xFFB0B7BF), // Silver
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
                // Subtle Cross Background
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
                      FadeIn(
                        duration: const Duration(milliseconds: 800),
                        child: Text(
                          'Nutrition Hub',
                          style: Theme.of(context).textTheme.headlineLarge,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        color: Theme.of(context).colorScheme.surface, // Silver
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Daily Goal: 2000 kcal (Coming Soon)',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.secondary, // Red
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          // Add meal logging navigation later
                        },
                        child: const Text('Log a Meal'),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.secondary, // Red
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          // Add planner navigation later
                        },
                        child: const Text('View Meal Plan'),
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
      ..color = const Color(0xFF87CEEB) // Soft Sky Blue
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