import 'package:flutter/material.dart';
import 'body_weight_progress_screen.dart'; // Fixed relative import

class ProgressScreen extends StatefulWidget {
  final String unit;

  const ProgressScreen({super.key, required this.unit});

  @override
  _ProgressScreenState createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  @override
  Widget build(BuildContext context) {
    return Padding(
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
            child: BodyWeightProgressScreen(unit: widget.unit), // Fixed widget usage
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              // Add logging navigation or refresh logic later
            },
            child: const Text('Log New Progress'),
          ),
        ],
      ),
    );
  }
}