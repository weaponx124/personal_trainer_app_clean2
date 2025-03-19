import 'package:flutter/material.dart';
import 'package:personal_trainer_app_clean/database_helper.dart';
import 'package:personal_trainer_app_clean/main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart'; // Added for animation

class HomeScreen extends StatefulWidget {
  final String unit;

  const HomeScreen({super.key, required this.unit});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<Map<String, dynamic>?> _getLastWorkout() async {
    final workouts = await DatabaseHelper.getWorkouts();
    return workouts.isNotEmpty ? workouts.first : null;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: unitNotifier,
      builder: (context, unit, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [const Color(0xFF87CEEB).withOpacity(0.2), const Color(0xFF1C2526)],
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo and Tagline with Animation
                  Padding(
                    padding: const EdgeInsets.only(top: 40.0, bottom: 40.0),
                    child: Column(
                      children: [
                        FadeIn(
                          duration: const Duration(milliseconds: 800),
                          child: Image.asset(
                            'assets/logo_512_transparent.png',
                            height: 180,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Seek First, Lift Strong',
                          style: GoogleFonts.oswald(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFB22222), // Red
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  // Last Workout Card
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    color: const Color(0xFFB0B7BF), // Silver
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: FutureBuilder<Map<String, dynamic>?>(
                        future: _getLastWorkout(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator(color: const Color(0xFFB22222)); // Red
                          }
                          final lastWorkout = snapshot.data;
                          return Column(
                            children: [
                              Text(
                                lastWorkout != null
                                    ? 'Last Lift: ${lastWorkout['exercise']} ${lastWorkout['weight']} $unit'
                                    : 'No Lifts Yet',
                                style: GoogleFonts.roboto(
                                  fontSize: 18,
                                  color: const Color(0xFF1C2526), // Matte Black
                                ),
                              ),
                              const SizedBox(height: 12),
                              LinearProgressIndicator(
                                value: lastWorkout != null ? 0.6 : 0.0,
                                backgroundColor: Colors.grey[400],
                                color: const Color(0xFFB22222), // Red
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Streak Card
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    color: const Color(0xFFB0B7BF), // Silver
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        'Streak: 3 Days',
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          color: const Color(0xFF1C2526), // Matte Black
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Buttons
                  ElevatedButton.icon(
                    icon: const Icon(Icons.fitness_center, size: 24),
                    label: const Text('Start Today’s Lift', style: TextStyle(fontSize: 18)),
                    onPressed: () => Navigator.pushNamed(context, '/workout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB22222), // Red
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.list_alt, size: 24),
                    label: const Text('Choose a Program', style: TextStyle(fontSize: 18)),
                    onPressed: () => Navigator.pushNamed(context, '/program_selection'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB22222), // Red
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.settings, size: 24),
                    label: const Text('Settings', style: TextStyle(fontSize: 18)),
                    onPressed: () async {
                      await Navigator.pushNamed(context, '/settings');
                      if (mounted) setState(() {});
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB22222), // Red
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}