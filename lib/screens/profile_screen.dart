import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_trainer_app_clean/core/data/models/progress.dart';
import 'package:personal_trainer_app_clean/core/data/repositories/progress_repository.dart';
import 'package:personal_trainer_app_clean/main.dart';
import 'package:personal_trainer_app_clean/screens/body_weight_progress_screen.dart';
import 'package:personal_trainer_app_clean/screens/settings_screen.dart';
import 'package:personal_trainer_app_clean/utils/cross_painter.dart';
import 'package:personal_trainer_app_clean/widgets/common/loading_indicator.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProgressRepository _progressRepository = ProgressRepository();
  late Future<List<Progress>> _progressFuture;
  List<Progress> _progressData = [];

  @override
  void initState() {
    super.initState();
    _progressFuture = _loadProgress();
    _loadProgressData();
  }

  Future<List<Progress>> _loadProgress() async {
    try {
      final progress = await _progressRepository.getProgress();
      return progress;
    } catch (e) {
      print('Error loading progress: $e');
      return [];
    }
  }

  Future<void> _loadProgressData() async {
    final progress = await _progressFuture;
    setState(() {
      _progressData = List.from(progress);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xFFB0B7BF),
                    child: Text(
                      'U',
                      style: GoogleFonts.oswald(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFB22222),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'User Name',
                    style: GoogleFonts.oswald(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFB22222),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Fitness Enthusiast',
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      color: const Color(0xFF808080),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
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
                            'Stats',
                            style: GoogleFonts.oswald(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFB22222),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Programs Completed: 0',
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              color: const Color(0xFF808080),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Workouts Logged: 0',
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              color: const Color(0xFF808080),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Total Weight Lifted: 0 lbs',
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              color: const Color(0xFF808080),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
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
                            'Body Weight Progress',
                            style: GoogleFonts.oswald(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFB22222),
                            ),
                          ),
                          const SizedBox(height: 8),
                          FutureBuilder<List<Progress>>(
                            future: _progressFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const LoadingIndicator();
                              }
                              if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                                return Text(
                                  'No progress data available.',
                                  style: GoogleFonts.roboto(
                                    fontSize: 14,
                                    color: const Color(0xFF808080),
                                  ),
                                );
                              }
                              final progressData = snapshot.data!;
                              final latestProgress = progressData.last;
                              return Text(
                                'Current Weight: ${latestProgress.weight} lbs',
                                style: GoogleFonts.roboto(
                                  fontSize: 14,
                                  color: const Color(0xFF808080),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      childScreenNotifier.value = const BodyWeightProgressScreen();
                    },
                    child: const Text('Track Body Weight'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      childScreenNotifier.value = const SettingsScreen();
                    },
                    child: const Text('Settings'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}