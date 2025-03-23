import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';
import 'dart:convert';
import 'package:personal_trainer_app_clean/core/data/models/workout.dart';
import 'package:personal_trainer_app_clean/core/data/repositories/workout_repository.dart';
import 'package:personal_trainer_app_clean/core/data/repositories/verse_of_the_day_repository.dart';
import 'package:personal_trainer_app_clean/core/theme/app_theme.dart';
import 'package:personal_trainer_app_clean/main.dart';
import 'package:personal_trainer_app_clean/screens/program_selection_screen.dart';
import 'package:personal_trainer_app_clean/screens/settings_screen.dart';
import 'package:personal_trainer_app_clean/screens/workout_screen.dart';
import 'package:personal_trainer_app_clean/utils/cross_painter.dart';
import 'package:personal_trainer_app_clean/widgets/common/loading_indicator.dart';
import 'package:personal_trainer_app_clean/widgets/common/app_snack_bar.dart';

class HomeScreen extends StatefulWidget {
  final String unit;

  const HomeScreen({super.key, required this.unit});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WorkoutRepository _workoutRepository = WorkoutRepository();
  final VerseOfTheDayRepository _verseOfTheDayRepository = VerseOfTheDayRepository();

  late Future<Map<String, dynamic>?> _lastWorkoutFuture;
  late Future<Map<String, dynamic>> _dailyScriptureFuture;
  late Future<int> _weeklyWorkoutsFuture;
  Map<String, dynamic>? _currentScripture;
  bool _showCelebration = false;
  String _celebrationMessage = '';
  late ConfettiController _confettiController;
  int _previousWorkoutCount = 0;

  @override
  void initState() {
    super.initState();
    _lastWorkoutFuture = _getLastWorkout();
    _dailyScriptureFuture = _loadDailyScripture();
    _weeklyWorkoutsFuture = _getWeeklyWorkoutsCount();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    print('HomeScreen initialized');
    _checkForMilestones();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>?> _getLastWorkout() async {
    try {
      final programs = ['default_program'];
      List<Workout> allWorkouts = [];
      for (var programId in programs) {
        final workouts = await _workoutRepository.getWorkouts(programId);
        allWorkouts.addAll(workouts);
      }
      allWorkouts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      print('Fetched workouts for last workout: ${allWorkouts.length}');
      if (allWorkouts.isEmpty) return null;
      final lastWorkout = allWorkouts.first;
      return {
        'exercise': lastWorkout.name,
        'weight': lastWorkout.exercises.isNotEmpty ? lastWorkout.exercises.first['weight'] ?? 0.0 : 0.0,
        'timestamp': lastWorkout.timestamp,
      };
    } catch (e) {
      print('Error fetching last workout: $e');
      AppSnackBar.showError(context, 'Failed to load last workout: $e');
      return null;
    }
  }

  Future<int> _getWeeklyWorkoutsCount() async {
    try {
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));
      final startOfWeekDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
      final endOfWeekDate = DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day, 23, 59, 59);
      final weeklyWorkouts = await _workoutRepository.getWorkoutsForWeek(startOfWeekDate, endOfWeekDate);
      return weeklyWorkouts.length;
    } catch (e) {
      print('Error fetching weekly workouts: $e');
      return 0;
    }
  }

  Future<Map<String, dynamic>> _loadDailyScripture() async {
    try {
      final storedVerse = await _verseOfTheDayRepository.getVerseOfTheDay();
      if (storedVerse != null) {
        _currentScripture = storedVerse;
        print('Loaded stored verse of the day: ${storedVerse['book']} ${storedVerse['chapter']}:${storedVerse['verse']}');
        return storedVerse;
      }

      final manifestJson = await DefaultAssetBundle.of(context).loadString('AssetManifest.json');
      final assets = jsonDecode(manifestJson) as Map<String, dynamic>;
      final scriptureFiles = assets.keys.where((String key) => key.startsWith('assets/scriptures_') && key.endsWith('.json')).toList();

      if (scriptureFiles.isEmpty) {
        print('No scripture files found in assets');
        throw Exception('No scripture files found in assets');
      }

      print('Found scripture files: $scriptureFiles');
      final randomFileIndex = DateTime.now().millisecondsSinceEpoch % scriptureFiles.length;
      final selectedFile = scriptureFiles[randomFileIndex];
      print('Loading scripture from: $selectedFile');

      final asset = await DefaultAssetBundle.of(context).loadString(selectedFile);
      final List<Map<String, dynamic>> books = (jsonDecode(asset) as List).cast<Map<String, dynamic>>();
      if (books.isEmpty) {
        print('No books found in $selectedFile');
        throw Exception('No books found in $selectedFile');
      }
      final book = books[0];

      final chapters = (book['chapters'] as List).cast<Map<String, dynamic>>();
      if (chapters.isEmpty) {
        print('No chapters found in $selectedFile');
        throw Exception('No chapters found in $selectedFile');
      }
      final randomChapterIndex = DateTime.now().millisecondsSinceEpoch % chapters.length;
      final chapter = chapters[randomChapterIndex];

      final verses = (chapter['verses'] as List).cast<Map<String, dynamic>>();
      if (verses.isEmpty) {
        print('No verses found in chapter $randomChapterIndex of $selectedFile');
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

      await _verseOfTheDayRepository.setVerseOfTheDay(scripture);
      _currentScripture = scripture;
      print('Loaded new verse of the day: ${scripture['book']} ${scripture['chapter']}:${scripture['verse']} - ${scripture['text']}');
      return scripture;
    } catch (e) {
      print('Error loading scriptures: $e');
      AppSnackBar.showError(context, 'Failed to load scripture: $e');
      return {
        'book': 'Error',
        'chapter': 0,
        'verse': 0,
        'text': 'Failed to load scripture. Please check assets/scriptures_*.json files.'
      };
    }
  }

  Future<void> _checkForMilestones() async {
    print('Checking for milestones...');
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    final startOfWeekDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final endOfWeekDate = DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day, 23, 59, 59);

    final weeklyWorkouts = await _workoutRepository.getWorkoutsForWeek(startOfWeekDate, endOfWeekDate);
    final workoutCount = weeklyWorkouts.length;
    print('Weekly workouts count: $workoutCount');

    final weeklyGoal = await _verseOfTheDayRepository.getWeeklyWorkoutGoal();
    print('Weekly goal: $weeklyGoal');

    final hasCelebrated = await _verseOfTheDayRepository.hasCelebratedMilestoneThisWeek(startOfWeekDate);
    print('Has celebrated this week: $hasCelebrated');

    if (workoutCount >= weeklyGoal && !hasCelebrated) {
      if (_previousWorkoutCount < weeklyGoal) {
        print('Milestone met! Triggering celebration...');
        setState(() {
          _showCelebration = true;
          _celebrationMessage = 'Great Job! You’ve met your weekly goal of $weeklyGoal workouts!';
          _confettiController.play();
        });
        await _verseOfTheDayRepository.setCelebratedMilestoneThisWeek(startOfWeekDate, true);
      } else {
        print('Milestone already met this week, but no new achievement. Previous count: $_previousWorkoutCount');
      }
    } else if (hasCelebrated) {
      print('Milestone already celebrated this week.');
    } else {
      print('Milestone not met. Workouts: $workoutCount, Goal: $weeklyGoal');
    }

    _previousWorkoutCount = workoutCount;
  }

  @override
  Widget build(BuildContext context) {
    print('HomeScreen rebuilt');
    return ValueListenableBuilder<Color>(
      valueListenable: accentColorNotifier,
      builder: (context, accentColor, child) {
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
                                  style: Theme.of(context).textTheme.headlineLarge,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Weekly Stats',
                                    style: Theme.of(context).textTheme.headlineMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  FutureBuilder<int>(
                                    future: _weeklyWorkoutsFuture,
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return const LoadingIndicator();
                                      }
                                      if (snapshot.hasError) {
                                        return Text(
                                          'Error loading weekly stats: ${snapshot.error}',
                                          style: Theme.of(context).textTheme.bodySmall,
                                        );
                                      }
                                      final weeklyWorkouts = snapshot.data ?? 0;
                                      return Text(
                                        'Workouts This Week: $weeklyWorkouts',
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: FutureBuilder<Map<String, dynamic>?>(
                                future: _lastWorkoutFuture,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const LoadingIndicator();
                                  }
                                  if (snapshot.hasError || !snapshot.hasData) {
                                    return Text(
                                      'No Lifts Yet',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    );
                                  }
                                  final lastWorkout = snapshot.data;
                                  return Text(
                                    lastWorkout != null
                                        ? 'Last Lift: ${lastWorkout['exercise']} ${lastWorkout['weight']} ${widget.unit}'
                                        : 'No Lifts Yet',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Text(
                                'Streak: 3 Days', // Placeholder for now
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.fitness_center, size: 24),
                            label: const Text('Start Today’s Lift'),
                            onPressed: () async {
                              childScreenNotifier.value = const WorkoutScreen();
                              setState(() {
                                _lastWorkoutFuture = _getLastWorkout();
                                _weeklyWorkoutsFuture = _getWeeklyWorkoutsCount();
                              });
                              await _checkForMilestones();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.list_alt, size: 24),
                            label: const Text('Choose a Program'),
                            onPressed: () {
                              childScreenNotifier.value = const ProgramSelectionScreen();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.settings, size: 24),
                            label: const Text('Settings'),
                            onPressed: () async {
                              childScreenNotifier.value = const SettingsScreen();
                              if (mounted) setState(() {});
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          FutureBuilder<Map<String, dynamic>>(
                            future: _dailyScriptureFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const LoadingIndicator();
                              }
                              if (snapshot.hasError || !snapshot.hasData) {
                                return Text(
                                  'Failed to load scripture: ${snapshot.error}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                );
                              }
                              final scripture = snapshot.data!;
                              return Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      print('Navigating to Scriptures with: ${scripture['book']} ${scripture['chapter']}:${scripture['verse']}');
                                      scriptureArgsNotifier.value = {
                                        'book': scripture['book'],
                                        'chapter': scripture['chapter'],
                                        'verse': scripture['verse'],
                                      };
                                      selectedTabIndexNotifier.value = 4; // Scriptures tab
                                      childScreenNotifier.value = null; // Clear child screen to show tab content
                                    },
                                    child: Column(
                                      children: [
                                        Text(
                                          'Verse of the Day',
                                          style: Theme.of(context).textTheme.headlineMedium,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '${scripture['book']} ${scripture['chapter']}:${scripture['verse']}',
                                          style: Theme.of(context).textTheme.headlineMedium,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          scripture['text'],
                                          style: Theme.of(context).textTheme.bodySmall,
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
                ],
              ),
            ),
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
                          colors: [
                            accentColor,
                            Colors.blue,
                            Colors.green,
                            Colors.yellow,
                          ],
                        ),
                        Text(
                          '🎉 Celebration! 🎉',
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _celebrationMessage,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white),
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
                            backgroundColor: accentColor,
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