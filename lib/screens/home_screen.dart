import 'package:flutter/material.dart';
import 'package:personal_trainer_app_clean/database_helper.dart';
import 'package:personal_trainer_app_clean/main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  final String unit;

  const HomeScreen({super.key, required this.unit});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<Map<String, dynamic>?> _lastWorkoutFuture;
  late Future<Map<String, dynamic>> _dailyScriptureFuture;
  Map<String, dynamic>? _currentScripture;
  bool _showCelebration = false;
  String _celebrationMessage = '';
  late ConfettiController _confettiController;
  int _previousWorkoutCount = 0; // Track the previous workout count to detect milestone achievement

  @override
  void initState() {
    super.initState();
    _lastWorkoutFuture = _getLastWorkout();
    _dailyScriptureFuture = _loadDailyScripture();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    print('HomeScreen initialized'); // Debug log for rebuilds
    // Check for milestones after initialization
    _checkForMilestones();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>?> _getLastWorkout() async {
    try {
      final workouts = await DatabaseHelper.getWorkouts();
      print('Fetched workouts for last workout: ${workouts.length}'); // Debug log
      return workouts.isNotEmpty ? workouts.first : null;
    } catch (e) {
      print('Error fetching last workout: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> _loadDailyScripture() async {
    try {
      // Get all asset file names dynamically
      final manifestJson = await DefaultAssetBundle.of(context).loadString('AssetManifest.json');
      final assets = jsonDecode(manifestJson) as Map<String, dynamic>;
      final scriptureFiles = assets.keys.where((String key) => key.startsWith('assets/scriptures_') && key.endsWith('.json')).toList();

      if (scriptureFiles.isEmpty) {
        print('No scripture files found in assets'); // Debug log
        throw Exception('No scripture files found in assets');
      }

      print('Found scripture files: $scriptureFiles'); // Debug log
      // Select a random scripture file
      final randomFileIndex = DateTime.now().millisecondsSinceEpoch % scriptureFiles.length;
      final selectedFile = scriptureFiles[randomFileIndex];
      print('Loading scripture from: $selectedFile'); // Debug log

      final asset = await DefaultAssetBundle.of(context).loadString(selectedFile);
      final List<Map<String, dynamic>> books = (jsonDecode(asset) as List).cast<Map<String, dynamic>>();
      if (books.isEmpty) {
        print('No books found in $selectedFile'); // Debug log
        throw Exception('No books found in $selectedFile');
      }
      final book = books[0]; // Single book per file

      final chapters = (book['chapters'] as List).cast<Map<String, dynamic>>();
      if (chapters.isEmpty) {
        print('No chapters found in $selectedFile'); // Debug log
        throw Exception('No chapters found in $selectedFile');
      }
      final randomChapterIndex = DateTime.now().millisecondsSinceEpoch % chapters.length;
      final chapter = chapters[randomChapterIndex];

      final verses = (chapter['verses'] as List).cast<Map<String, dynamic>>();
      if (verses.isEmpty) {
        print('No verses found in chapter $randomChapterIndex of $selectedFile'); // Debug log
        throw Exception('No verses found in chapter');
      }
      final randomVerseIndex = DateTime.now().millisecondsSinceEpoch % verses.length;
      final verse = verses[randomVerseIndex];

      final scripture = {
        'book': book['book'] as String? ?? 'Unknown',
        'chapter': chapter['chapter'] as int? ?? 0,
        'verse': verse['verse'] as int? ?? 0,
        'text': verse['text'] as String? ?? 'No text available'
      };

      // Store the current scripture after the future completes
      _currentScripture = scripture;
      print('Loaded scripture: ${scripture['book']} ${scripture['chapter']}:${scripture['verse']} - ${scripture['text']}'); // Debug log
      return scripture;
    } catch (e) {
      print('Error loading scriptures: $e');
      return {
        'book': 'Error',
        'chapter': 0,
        'verse': 0,
        'text': 'Failed to load scripture. Please check assets/scriptures_*.json files.'
      };
    }
  }

  Future<void> _checkForMilestones() async {
    print('Checking for milestones...'); // Debug log
    // Get the current week range (Monday to Sunday)
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    final startOfWeekDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final endOfWeekDate = DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day, 23, 59, 59);

    // Get workouts for the current week
    final weeklyWorkouts = await DatabaseHelper.getWorkoutsForWeek(startOfWeekDate, endOfWeekDate);
    final workoutCount = weeklyWorkouts.length;
    print('Weekly workouts count: $workoutCount'); // Debug log

    // Get the user's weekly goal
    final weeklyGoal = await DatabaseHelper.getWeeklyWorkoutGoal();
    print('Weekly goal: $weeklyGoal'); // Debug log

    // Check if the milestone has already been celebrated this week
    final hasCelebrated = await DatabaseHelper.hasCelebratedMilestoneThisWeek(startOfWeekDate);
    print('Has celebrated this week: $hasCelebrated'); // Debug log

    // Check if the user has met or exceeded their weekly goal and hasn't celebrated yet
    if (workoutCount >= weeklyGoal && !hasCelebrated) {
      // Check if this is the first time the milestone is achieved (i.e., previous count was below goal)
      if (_previousWorkoutCount < weeklyGoal) {
        print('Milestone met! Triggering celebration...'); // Debug log
        setState(() {
          _showCelebration = true;
          _celebrationMessage = 'Great Job! You’ve met your weekly goal of $weeklyGoal workouts!';
          _confettiController.play();
        });
        await DatabaseHelper.setCelebratedMilestoneThisWeek(startOfWeekDate, true);
      } else {
        print('Milestone already met this week, but no new achievement. Previous count: $_previousWorkoutCount'); // Debug log
      }
    } else if (hasCelebrated) {
      print('Milestone already celebrated this week.'); // Debug log
    } else {
      print('Milestone not met. Workouts: $workoutCount, Goal: $weeklyGoal'); // Debug log
    }

    // Update the previous workout count for the next check
    _previousWorkoutCount = workoutCount;
  }

  @override
  Widget build(BuildContext context) {
    print('HomeScreen rebuilt'); // Debug log for rebuilds
    return ValueListenableBuilder<String>(
      valueListenable: unitNotifier,
      builder: (context, unit, child) {
        return Stack(
          children: [
            Container(
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
                                color: const Color(0xFFB22222),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        color: const Color(0xFFB0B7BF),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: FutureBuilder<Map<String, dynamic>?>(
                            future: _lastWorkoutFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const CircularProgressIndicator(color: Color(0xFFB22222));
                              }
                              if (snapshot.hasError || !snapshot.hasData) {
                                return Text('Failed to load workout: ${snapshot.error}');
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
                                      color: const Color(0xFF1C2526),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  LinearProgressIndicator(
                                    value: lastWorkout != null ? 0.6 : 0.0,
                                    backgroundColor: Colors.grey[400],
                                    color: const Color(0xFFB22222),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        color: const Color(0xFFB0B7BF),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            'Streak: 3 Days', // Placeholder for now
                            style: GoogleFonts.roboto(
                              fontSize: 18,
                              color: const Color(0xFF1C2526),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.fitness_center, size: 24),
                        label: const Text('Start Today’s Lift', style: TextStyle(fontSize: 18)),
                        onPressed: () async {
                          await Navigator.pushNamed(context, '/workout');
                          // Refresh last workout and check for milestones
                          setState(() {
                            _lastWorkoutFuture = _getLastWorkout();
                          });
                          await _checkForMilestones();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB22222),
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
                          backgroundColor: const Color(0xFFB22222),
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
                          backgroundColor: const Color(0xFFB22222),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      FutureBuilder<Map<String, dynamic>>(
                        future: _dailyScriptureFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator(color: Color(0xFFB22222));
                          }
                          if (snapshot.hasError || !snapshot.hasData) {
                            return Text('Failed to load scripture: ${snapshot.error}');
                          }
                          final scripture = snapshot.data!;
                          return Card(
                            elevation: 8,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            color: const Color(0xFFB0B7BF),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: GestureDetector(
                                onTap: () {
                                  print('Navigating to Scriptures with: ${scripture['book']} ${scripture['chapter']}:${scripture['verse']}'); // Debug log
                                  Navigator.pushNamed(
                                    context,
                                    '/scriptures',
                                    arguments: {
                                      'book': scripture['book'],
                                      'chapter': scripture['chapter'],
                                      'verse': scripture['verse'],
                                    },
                                  );
                                },
                                child: Column(
                                  children: [
                                    Text(
                                      '${scripture['book']} ${scripture['chapter']}:${scripture['verse']}',
                                      style: GoogleFonts.oswald(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFFB22222),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      scripture['text'],
                                      style: GoogleFonts.roboto(
                                        fontSize: 16,
                                        color: const Color(0xFF1C2526),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Celebration Overlay
            if (_showCelebration)
              FadeIn(
                duration: const Duration(milliseconds: 500),
                child: Container(
                  color: Colors.black54,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ConfettiWidget(
                          confettiController: _confettiController,
                          blastDirectionality: BlastDirectionality.explosive,
                          shouldLoop: false,
                          colors: const [
                            Colors.red,
                            Colors.blue,
                            Colors.green,
                            Colors.yellow,
                          ],
                        ),
                        Text(
                          '🎉 Celebration! 🎉',
                          style: GoogleFonts.oswald(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _celebrationMessage,
                          style: GoogleFonts.roboto(
                            fontSize: 24,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _showCelebration = false;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB22222),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Continue'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
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