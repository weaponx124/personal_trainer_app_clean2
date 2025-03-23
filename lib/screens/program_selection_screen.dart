import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_trainer_app_clean/core/data/models/program.dart';
import 'package:personal_trainer_app_clean/core/data/repositories/program_repository.dart';
import 'package:personal_trainer_app_clean/core/data/repositories/settings_repository.dart';
import 'package:personal_trainer_app_clean/core/data/repositories/workout_repository.dart';
import 'package:personal_trainer_app_clean/core/utils/extensions.dart';
import 'package:personal_trainer_app_clean/core/utils/program_recommender.dart';
import 'package:personal_trainer_app_clean/main.dart';
import 'package:personal_trainer_app_clean/screens/custom_program_form.dart';
import 'package:personal_trainer_app_clean/screens/program_details_screen.dart';
import 'package:personal_trainer_app_clean/utils/cross_painter.dart';
import 'package:personal_trainer_app_clean/widgets/common/app_snack_bar.dart';
import 'package:personal_trainer_app_clean/widgets/common/loading_indicator.dart';
import 'package:uuid/uuid.dart';

class ProgramSelectionScreen extends StatefulWidget {
  const ProgramSelectionScreen({super.key});

  @override
  _ProgramSelectionScreenState createState() => _ProgramSelectionScreenState();
}

class _ProgramSelectionScreenState extends State<ProgramSelectionScreen> {
  final ProgramRepository _programRepository = ProgramRepository();
  late ProgramRecommender _programRecommender;
  late Future<List<Map<String, dynamic>>> _allProgramsFuture;
  late Future<List<Program>> _activeProgramsFuture;
  late Future<List<Program>> _completedProgramsFuture;
  List<Map<String, dynamic>> _allPrograms = [];
  List<Map<String, dynamic>> _recommendedPrograms = [];
  String _searchQuery = '';
  String? _selectedProgram;
  Map<String, TextEditingController> _oneRMControllers = {};
  bool _isStarting = false;
  bool _isLoadingRecommendations = true;
  String? _previewProgram;

  @override
  void initState() {
    super.initState();
    _programRecommender = ProgramRecommender(SettingsRepository(), WorkoutRepository());
    _allProgramsFuture = _loadAllPrograms();
    _activeProgramsFuture = _loadActivePrograms();
    _completedProgramsFuture = _loadCompletedPrograms();
    _loadProgramsData();
    _loadRecommendations();
  }

  Future<List<Map<String, dynamic>>> _loadAllPrograms() async {
    try {
      final programs = await _getAllPrograms();
      return programs;
    } catch (e) {
      print('Error loading programs: $e');
      AppSnackBar.showError(context, 'Failed to load programs: $e');
      return [];
    }
  }

  Future<List<Program>> _loadActivePrograms() async {
    try {
      final programs = await _programRepository.getPrograms();
      return programs.where((program) => !program.completed).toList();
    } catch (e) {
      print('Error loading active programs: $e');
      AppSnackBar.showError(context, 'Failed to load active programs: $e');
      return [];
    }
  }

  Future<List<Program>> _loadCompletedPrograms() async {
    try {
      final programs = await _programRepository.getPrograms();
      return programs.where((program) => program.completed).toList();
    } catch (e) {
      print('Error loading completed programs: $e');
      AppSnackBar.showError(context, 'Failed to load completed programs: $e');
      return [];
    }
  }

  Future<void> _loadProgramsData() async {
    final programs = await _allProgramsFuture;
    setState(() {
      _allPrograms = List.from(programs);
    });
  }

  Future<void> _loadRecommendations() async {
    setState(() {
      _isLoadingRecommendations = true;
    });
    try {
      final recommendations = await _programRecommender.getRecommendedPrograms();
      setState(() {
        _recommendedPrograms = recommendations;
      });
    } catch (e) {
      print('Error loading recommendations: $e');
      AppSnackBar.showError(context, 'Failed to load recommendations: $e');
    } finally {
      setState(() {
        _isLoadingRecommendations = false;
      });
    }
  }

  Future<List<Map<String, dynamic>>> _getAllPrograms() async {
    return [
      {
        'name': '5/3/1 Program',
        'duration': 'Ongoing',
        'requires1RM': true,
        'lifts': ['Squat', 'Bench', 'Deadlift', 'Overhead'],
        'description': 'A strength program with a focus on slow, steady progression using 3-week cycles.',
        'weeklyStructure': '3 workouts per week: Main lift + accessories each day.',
      },
      {
        'name': 'Texas Method',
        'duration': 'Ongoing',
        'requires1RM': true,
        'lifts': ['Squat', 'Bench', 'Deadlift'],
        'description': 'A strength program with volume, recovery, and intensity days each week.',
        'weeklyStructure': '3 workouts per week: Volume Day, Recovery Day, Intensity Day.',
      },
      {
        'name': 'Madcow 5x5',
        'duration': '12-16 weeks',
        'requires1RM': true,
        'lifts': ['Squat', 'Bench', 'Deadlift'],
        'description': 'An intermediate strength program with weekly progression and deloads.',
        'weeklyStructure': '3 workouts per week: Medium (A), Light (B), Heavy (C).',
      },
      {
        'name': 'Sheiko Beginner',
        'duration': '8-12 weeks',
        'requires1RM': true,
        'lifts': ['Squat', 'Bench', 'Deadlift'],
        'description': 'A beginner powerlifting program with high volume and moderate intensity.',
        'weeklyStructure': '3-4 workouts per week: Focus on technique and volume.',
      },
      {
        'name': 'Sheiko Intermediate',
        'duration': '8-12 weeks',
        'requires1RM': true,
        'lifts': ['Squat', 'Bench', 'Deadlift'],
        'description': 'An intermediate powerlifting program with increased volume and intensity.',
        'weeklyStructure': '3-4 workouts per week: Focus on volume and intensity.',
      },
      {
        'name': 'Sheiko Advanced',
        'duration': '8-12 weeks',
        'requires1RM': true,
        'lifts': ['Squat', 'Bench', 'Deadlift'],
        'description': 'An advanced powerlifting program with high volume and intensity.',
        'weeklyStructure': '4-5 workouts per week: High volume and intensity.',
      },
      {
        'name': 'Smolov Base Cycle',
        'duration': '13 weeks',
        'requires1RM': true,
        'lifts': ['Squat'],
        'description': 'An intense squat program for advanced lifters.',
        'weeklyStructure': '4 workouts per week: High-frequency squatting.',
      },
      {
        'name': 'Smolov Jr. (Bench)',
        'duration': '3-4 weeks',
        'requires1RM': true,
        'lifts': ['Bench'],
        'description': 'A bench press specialization program for advanced lifters.',
        'weeklyStructure': '4 workouts per week: High-frequency bench pressing.',
      },
      {
        'name': 'Candito 6-Week Program',
        'duration': '6 weeks',
        'requires1RM': true,
        'lifts': ['Squat', 'Bench', 'Deadlift'],
        'description': 'A 6-week powerlifting program with a mix of hypertrophy and strength.',
        'weeklyStructure': '4 workouts per week: Hypertrophy and strength focus.',
      },
      {
        'name': 'Push/Pull/Legs (PPL)',
        'duration': 'Ongoing',
        'requires1RM': false,
        'description': 'A bodybuilding program focusing on push, pull, and leg movements.',
        'weeklyStructure': '6 workouts per week: Push, Pull, Legs (repeat).',
      },
      {
        'name': 'Arnold Split',
        'duration': 'Ongoing',
        'requires1RM': false,
        'description': 'A bodybuilding split inspired by Arnold Schwarzenegger.',
        'weeklyStructure': '6 workouts per week: Chest/Back, Shoulders/Arms, Legs (repeat).',
      },
      {
        'name': 'Bro Split',
        'duration': 'Ongoing',
        'requires1RM': false,
        'description': 'A bodybuilding split focusing on one muscle group per day.',
        'weeklyStructure': '5 workouts per week: Chest, Back, Shoulders, Arms, Legs.',
      },
      {
        'name': 'PHUL',
        'duration': 'Ongoing',
        'requires1RM': true,
        'lifts': ['Squat', 'Bench', 'Deadlift'],
        'description': 'A power hypertrophy program combining strength and muscle building.',
        'weeklyStructure': '4 workouts per week: Power Upper, Power Lower, Hypertrophy Upper, Hypertrophy Lower.',
      },
      {
        'name': 'PHAT',
        'duration': 'Ongoing',
        'requires1RM': true,
        'lifts': ['Squat', 'Bench', 'Deadlift'],
        'description': 'A power hypertrophy program with a focus on strength and size.',
        'weeklyStructure': '5 workouts per week: Power and hypertrophy days.',
      },
      {
        'name': 'German Volume Training',
        'duration': '4-6 weeks',
        'requires1RM': true,
        'lifts': ['Squat', 'Bench', 'Deadlift'],
        'description': 'A high-volume program for muscle growth.',
        'weeklyStructure': '4-5 workouts per week: 10x10 sets for major lifts.',
      },
      {
        'name': 'Starting Strength',
        'duration': '3-6 months',
        'requires1RM': false,
        'description': 'A beginner strength program focusing on linear progression.',
        'weeklyStructure': '3 workouts per week: Alternating A/B workouts.',
      },
      {
        'name': 'StrongLifts 5x5',
        'duration': '3-6 months',
        'requires1RM': false,
        'description': 'A beginner strength program with 5x5 sets.',
        'weeklyStructure': '3 workouts per week: Alternating A/B workouts.',
      },
      {
        'name': 'Greyskull LP',
        'duration': '3-6 months',
        'requires1RM': false,
        'description': 'A beginner linear progression program with a focus on strength.',
        'weeklyStructure': '3 workouts per week: Alternating A/B workouts.',
      },
      {
        'name': 'Full Body 3x/Week',
        'duration': 'Ongoing',
        'requires1RM': false,
        'description': 'A full-body workout program for beginners.',
        'weeklyStructure': '3 workouts per week: Full-body each day.',
      },
      {
        'name': 'Couch to 5K',
        'duration': '9 weeks',
        'requires1RM': false,
        'description': 'A running program to build endurance from scratch.',
        'weeklyStructure': '3 workouts per week: Running intervals.',
      },
      {
        'name': 'Bodyweight Fitness',
        'duration': 'Ongoing',
        'requires1RM': false,
        'description': 'A bodyweight program for strength and fitness.',
        'weeklyStructure': '3 workouts per week: Full-body bodyweight exercises.',
      },
      {
        'name': 'Russian Squat Program',
        'duration': '6 weeks',
        'requires1RM': true,
        'lifts': ['Squat'],
        'description': 'An intense squat program for advanced lifters.',
        'weeklyStructure': '3 workouts per week: High-frequency squatting.',
      },
      {
        'name': 'Super Squats',
        'duration': '6 weeks',
        'requires1RM': true,
        'lifts': ['Squat'],
        'description': 'A squat-focused program for strength and size.',
        'weeklyStructure': '3 workouts per week: High-volume squatting.',
      },
      {
        'name': '30-Day Squat Challenge',
        'duration': '30 days',
        'requires1RM': false,
        'description': 'A 30-day challenge to build squat strength.',
        'weeklyStructure': 'Daily: Increasing squat reps.',
      },
      {
        'name': 'Bench Press Specialization',
        'duration': '3 weeks',
        'requires1RM': true,
        'lifts': ['Bench'],
        'description': 'A bench press specialization program.',
        'weeklyStructure': '3 workouts per week: High-frequency bench pressing.',
      },
      {
        'name': 'Deadlift Builder',
        'duration': '6 weeks',
        'requires1RM': true,
        'lifts': ['Deadlift'],
        'description': 'A deadlift-focused program for strength.',
        'weeklyStructure': '3 workouts per week: Deadlift and accessories.',
      },
      {
        'name': 'Arm Blaster',
        'duration': '4 weeks',
        'requires1RM': false,
        'description': 'An arm-focused program for hypertrophy.',
        'weeklyStructure': '3 workouts per week: Arm-focused exercises.',
      },
      {
        'name': 'Shoulder Sculptor',
        'duration': '6 weeks',
        'requires1RM': false,
        'description': 'A shoulder-focused program for hypertrophy.',
        'weeklyStructure': '3 workouts per week: Shoulder-focused exercises.',
      },
      {
        'name': 'Pull-Up Progression',
        'duration': '6 weeks',
        'requires1RM': false,
        'description': 'A program to build pull-up strength.',
        'weeklyStructure': '3 workouts per week: Pull-up progression exercises.',
      },
    ];
  }

  Future<void> _startProgram(String programName) async {
    setState(() {
      _isStarting = true;
    });
    try {
      final programId = Uuid().v4();
      final startDate = DateTime.now().toIso8601String().split('T')[0];
      final selectedProgramData = _allPrograms.firstWhere((program) => program['name'] == programName);
      final requires1RM = selectedProgramData['requires1RM'] as bool? ?? false;

      Map<String, dynamic> oneRMs = {};
      Map<String, dynamic> details = {
        'unit': unitNotifier.value,
      };

      if (requires1RM) {
        final lifts = selectedProgramData['lifts'] as List<dynamic>? ?? [];
        for (var lift in lifts) {
          final controller = _oneRMControllers[lift as String];
          final weight = double.tryParse(controller?.text ?? '0') ?? 0.0;
          if (weight <= 0) {
            throw Exception('Please enter a valid 1RM for $lift (must be greater than 0).');
          }
          oneRMs[lift as String] = weight;
        }
        details['original1RMs'] = Map<String, double>.from(oneRMs);
        details['originalUnit'] = unitNotifier.value;
      }

      final newProgram = Program(
        id: programId,
        name: programName,
        description: selectedProgramData['duration'] as String,
        oneRMs: oneRMs,
        details: details,
        completed: false,
        startDate: startDate,
        currentWeek: 1,
        currentSession: 1,
        sessionsCompleted: 0,
      );

      await _programRepository.insertProgram(newProgram);
      AppSnackBar.showSuccess(context, 'Program started successfully!');

      // Refresh active programs
      setState(() {
        _activeProgramsFuture = _loadActivePrograms();
        _selectedProgram = null;
        _oneRMControllers.clear();
      });

      // Navigate to ProgramDetailsScreen by updating childScreenNotifier
      childScreenNotifier.value = ProgramDetailsScreen(programId: programId);
    } catch (e) {
      AppSnackBar.showError(context, 'Failed to start program: $e');
    } finally {
      setState(() {
        _isStarting = false;
      });
    }
  }

  void _onProgramTap(String programId) {
    childScreenNotifier.value = ProgramDetailsScreen(programId: programId);
  }

  @override
  void dispose() {
    _oneRMControllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: unitNotifier,
      builder: (context, unit, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Programs'),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            foregroundColor: Theme.of(context).colorScheme.onSurface,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                childScreenNotifier.value = null;
              },
            ),
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF87CEEB).withOpacity(0.2),
                  const Color(0xFF1C2526),
                ],
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
                RefreshIndicator(
                  onRefresh: () async {
                    await _loadRecommendations();
                    await _loadProgramsData();
                    setState(() {
                      _activeProgramsFuture = _loadActivePrograms();
                      _completedProgramsFuture = _loadCompletedPrograms();
                    });
                  },
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          // Active Programs Section
                          Text(
                            'Active Programs',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 8),
                          FutureBuilder<List<Program>>(
                            future: _activeProgramsFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const LoadingIndicator();
                              }
                              if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                                return Text(
                                  'No active programs.',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                );
                              }
                              final activePrograms = snapshot.data!;
                              return Column(
                                children: activePrograms.map((program) {
                                  return Card(
                                    child: ListTile(
                                      title: Text(
                                        program.name,
                                        style: Theme.of(context).textTheme.headlineMedium,
                                      ),
                                      subtitle: Text(
                                        'Week ${program.currentWeek}, Session ${program.currentSession}',
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                      onTap: () => _onProgramTap(program.id),
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          // Completed Programs Section
                          Text(
                            'Completed Programs',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 8),
                          FutureBuilder<List<Program>>(
                            future: _completedProgramsFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const LoadingIndicator();
                              }
                              if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                                return Text(
                                  'No completed programs.',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                );
                              }
                              final completedPrograms = snapshot.data!;
                              return Column(
                                children: completedPrograms.map((program) {
                                  return Card(
                                    child: ListTile(
                                      title: Text(
                                        program.name,
                                        style: Theme.of(context).textTheme.headlineMedium,
                                      ),
                                      subtitle: Text(
                                        'Completed',
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                      onTap: () => _onProgramTap(program.id),
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          // Recommended Programs Section
                          Text(
                            'Recommended Programs',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 8),
                          if (_isLoadingRecommendations)
                            const LoadingIndicator()
                          else if (_recommendedPrograms.isEmpty)
                            Text(
                              'No recommendations available.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            )
                          else
                            ..._recommendedPrograms.map((program) {
                              final programName = program['name'] as String;
                              final duration = program['duration'] as String;
                              final requires1RM = program['requires1RM'] as bool? ?? false;
                              final lifts = program['lifts'] as List<dynamic>? ?? [];
                              final description = program['description'] as String? ?? 'No description available.';
                              final weeklyStructure = program['weeklyStructure'] as String? ?? 'No weekly structure available.';
                              final isSelected = _selectedProgram == programName;
                              final isPreviewing = _previewProgram == programName;

                              return Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              programName,
                                              style: Theme.of(context).textTheme.headlineMedium,
                                            ),
                                          ),
                                          if (!isSelected)
                                            Row(
                                              children: [
                                                IconButton(
                                                  icon: const Icon(Icons.info_outline),
                                                  onPressed: () {
                                                    setState(() {
                                                      _previewProgram = isPreviewing ? null : programName;
                                                    });
                                                  },
                                                ),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      _selectedProgram = programName;
                                                      if (requires1RM) {
                                                        for (var lift in lifts) {
                                                          _oneRMControllers[lift as String] =
                                                              TextEditingController();
                                                        }
                                                      }
                                                    });
                                                  },
                                                  child: const Text('Select'),
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Duration: $duration',
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                      Text(
                                        'Difficulty: ${CapitalizeStringExtension(program['difficulty']).capitalize()}',
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                      Text(
                                        'Focus: ${CapitalizeStringExtension(program['focus'].replaceAll('_', ' ')).capitalize()}',
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                      Text(
                                        'Type: ${CapitalizeStringExtension(program['type']).capitalize()}',
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                      if (isPreviewing) ...[
                                        const SizedBox(height: 8),
                                        Text(
                                          'Description: $description',
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                        Text(
                                          'Weekly Structure: $weeklyStructure',
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                      ],
                                      if (isSelected) ...[
                                        const SizedBox(height: 16),
                                        if (requires1RM) ...[
                                          Text(
                                            'Enter your 1RMs ($unit):',
                                            style: Theme.of(context).textTheme.bodyMedium,
                                          ),
                                          const SizedBox(height: 8),
                                          ...lifts.map((lift) {
                                            return Padding(
                                              padding: const EdgeInsets.only(bottom: 8.0),
                                              child: TextField(
                                                controller: _oneRMControllers[lift as String],
                                                keyboardType: TextInputType.number,
                                                decoration: InputDecoration(
                                                  labelText: '$lift 1RM',
                                                  labelStyle: Theme.of(context).textTheme.bodySmall,
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  filled: true,
                                                  fillColor: Theme.of(context).colorScheme.surface,
                                                ),
                                                style: Theme.of(context).textTheme.bodyMedium,
                                              ),
                                            );
                                          }).toList(),
                                        ],
                                        const SizedBox(height: 16),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            ElevatedButton(
                                              onPressed: () {
                                                setState(() {
                                                  _selectedProgram = null;
                                                  _oneRMControllers.clear();
                                                });
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.grey,
                                              ),
                                              child: const Text('Cancel'),
                                            ),
                                            ElevatedButton(
                                              onPressed: _isStarting
                                                  ? null
                                                  : () => _startProgram(programName),
                                              child: _isStarting
                                                  ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2,
                                                ),
                                              )
                                                  : const Text('Start'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          const SizedBox(height: 24),
                          // All Programs Section
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: TextField(
                              decoration: InputDecoration(
                                labelText: 'Search Programs',
                                labelStyle: Theme.of(context).textTheme.bodySmall,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Theme.of(context).colorScheme.surface,
                                prefixIcon: const Icon(Icons.search),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value.toLowerCase();
                                });
                              },
                            ),
                          ),
                          Text(
                            'All Programs',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 8),
                          FutureBuilder<List<Map<String, dynamic>>>(
                            future: _allProgramsFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const LoadingIndicator();
                              }
                              if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                                return Center(
                                  child: Text(
                                    'No programs available.',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                );
                              }
                              final filteredPrograms = snapshot.data!
                                  .where((program) =>
                                  program['name'].toString().toLowerCase().contains(_searchQuery))
                                  .toList();
                              return ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: filteredPrograms.length + 1, // +1 for Custom Program button
                                itemBuilder: (context, index) {
                                  if (index == filteredPrograms.length) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 16.0),
                                      child: ElevatedButton.icon(
                                        icon: const Icon(Icons.add, size: 24),
                                        label: const Text('Create Custom Program'),
                                        onPressed: () {
                                          childScreenNotifier.value = const CustomProgramForm();
                                        },
                                      ),
                                    );
                                  }
                                  final program = filteredPrograms[index];
                                  final programName = program['name'] as String;
                                  final duration = program['duration'] as String;
                                  final requires1RM = program['requires1RM'] as bool? ?? false;
                                  final lifts = program['lifts'] as List<dynamic>? ?? [];
                                  final description = program['description'] as String? ?? 'No description available.';
                                  final weeklyStructure = program['weeklyStructure'] as String? ?? 'No weekly structure available.';
                                  final isSelected = _selectedProgram == programName;
                                  final isPreviewing = _previewProgram == programName;

                                  return Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  programName,
                                                  style: Theme.of(context).textTheme.headlineMedium,
                                                ),
                                              ),
                                              if (!isSelected)
                                                Row(
                                                  children: [
                                                    IconButton(
                                                      icon: const Icon(Icons.info_outline),
                                                      onPressed: () {
                                                        setState(() {
                                                          _previewProgram = isPreviewing ? null : programName;
                                                        });
                                                      },
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          _selectedProgram = programName;
                                                          if (requires1RM) {
                                                            for (var lift in lifts) {
                                                              _oneRMControllers[lift as String] =
                                                                  TextEditingController();
                                                            }
                                                          }
                                                        });
                                                      },
                                                      child: const Text('Select'),
                                                    ),
                                                  ],
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Duration: $duration',
                                            style: Theme.of(context).textTheme.bodySmall,
                                          ),
                                          if (isPreviewing) ...[
                                            const SizedBox(height: 8),
                                            Text(
                                              'Description: $description',
                                              style: Theme.of(context).textTheme.bodySmall,
                                            ),
                                            Text(
                                              'Weekly Structure: $weeklyStructure',
                                              style: Theme.of(context).textTheme.bodySmall,
                                            ),
                                          ],
                                          if (isSelected) ...[
                                            const SizedBox(height: 16),
                                            if (requires1RM) ...[
                                              Text(
                                                'Enter your 1RMs ($unit):',
                                                style: Theme.of(context).textTheme.bodyMedium,
                                              ),
                                              const SizedBox(height: 8),
                                              ...lifts.map((lift) {
                                                return Padding(
                                                  padding: const EdgeInsets.only(bottom: 8.0),
                                                  child: TextField(
                                                    controller: _oneRMControllers[lift as String],
                                                    keyboardType: TextInputType.number,
                                                    decoration: InputDecoration(
                                                      labelText: '$lift 1RM',
                                                      labelStyle: Theme.of(context).textTheme.bodySmall,
                                                      border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                      filled: true,
                                                      fillColor: Theme.of(context).colorScheme.surface,
                                                    ),
                                                    style: Theme.of(context).textTheme.bodyMedium,
                                                  ),
                                                );
                                              }).toList(),
                                            ],
                                            const SizedBox(height: 16),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                ElevatedButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      _selectedProgram = null;
                                                      _oneRMControllers.clear();
                                                    });
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.grey,
                                                  ),
                                                  child: const Text('Cancel'),
                                                ),
                                                ElevatedButton(
                                                  onPressed: _isStarting
                                                      ? null
                                                      : () => _startProgram(programName),
                                                  child: _isStarting
                                                      ? const SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child: CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2,
                                                    ),
                                                  )
                                                      : const Text('Start'),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
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