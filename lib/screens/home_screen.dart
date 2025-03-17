import 'package:flutter/material.dart';
import 'program_selection_screen.dart';
import 'workout_screen.dart';
import '../database_helper.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<Map<String, dynamic>?> _getLastWorkout() async {
    final workouts = await DatabaseHelper.getWorkouts(); // Fixed to static call
    return workouts.isNotEmpty ? workouts.first : null; // Most recent (DESC order)
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Ready to Crush It?',
              style: Theme.of(context).textTheme.headlineLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FutureBuilder<Map<String, dynamic>?>(
              future: _getLastWorkout(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                final lastWorkout = snapshot.data;
                return Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          lastWorkout != null
                              ? 'Last Workout: ${lastWorkout['exercise']} ${lastWorkout['weight']} lbs'
                              : 'No Workouts Yet',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: lastWorkout != null ? 0.6 : 0.0, // Placeholder
                          backgroundColor: Colors.grey[300],
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Streak: 3 Days', // Placeholder
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WorkoutScreen()),
                );
              },
              child: const Text('Start Today’s Workout'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProgramSelectionScreen(unit: 'lbs')),
                );
              },
              child: const Text('Choose a Program'),
            ),
          ],
        ),
      ),
    );
  }
}