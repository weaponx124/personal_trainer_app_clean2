import 'package:flutter/material.dart';
import 'package:personal_trainer_app_clean/main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'body_weight_progress_screen.dart';

class ProgressScreen extends StatefulWidget {
  final String unit;

  const ProgressScreen({super.key, required this.unit});

  @override
  _ProgressScreenState createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: unitNotifier,
      builder: (context, unit, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Progress'),
            backgroundColor: const Color(0xFF1C2526), // Matte Black
            foregroundColor: const Color(0xFFB0B7BF), // Silver
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
              },
            ),
          ),
          body: Container(
            color: const Color(0xFF1C2526), // Matte Black
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Your Progress',
                  style: Theme.of(context).textTheme.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: BodyWeightProgressScreen(unit: widget.unit),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB22222), // Red
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    // Add logging navigation or refresh logic later
                  },
                  child: const Text('Log New Progress'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}