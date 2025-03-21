import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_trainer_app_clean/main.dart';
import 'package:personal_trainer_app_clean/core/data/models/program.dart';
import 'package:personal_trainer_app_clean/core/data/repositories/program_repository.dart';
import 'package:personal_trainer_app_clean/screens/custom_program_form.dart';
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
  late Future<List<Map<String, dynamic>>> _allProgramsFuture;
  List<Map<String, dynamic>> _allPrograms = [];
  String _searchQuery = '';
  String? _selectedProgram;
  Map<String, TextEditingController> _oneRMControllers = {};
  bool _isStarting = false;

  @override
  void initState() {
    super.initState();
    _allProgramsFuture = _loadAllPrograms();
    _loadProgramsData();
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

  Future<void> _loadProgramsData() async {
    final programs = await _allProgramsFuture;
    setState(() {
      _allPrograms = List.from(programs);
    });
  }

  Future<List<Map<String, dynamic>>> _getAllPrograms() async {
    return [
      {'name': '5/3/1 Program', 'duration': 'Ongoing', 'requires1RM': true, 'lifts': ['Squat', 'Bench', 'Deadlift', 'Overhead']},
      {'name': 'Texas Method', 'duration': 'Ongoing', 'requires1RM': true, 'lifts': ['Squat', 'Bench', 'Deadlift']},
      {'name': 'Madcow 5x5', 'duration': '12-16 weeks', 'requires1RM': true, 'lifts': ['Squat', 'Bench', 'Deadlift']},
      {'name': 'Sheiko Beginner', 'duration': '8-12 weeks', 'requires1RM': true, 'lifts': ['Squat', 'Bench', 'Deadlift']},
      {'name': 'Sheiko Intermediate', 'duration': '8-12 weeks', 'requires1RM': true, 'lifts': ['Squat', 'Bench', 'Deadlift']},
      {'name': 'Sheiko Advanced', 'duration': '8-12 weeks', 'requires1RM': true, 'lifts': ['Squat', 'Bench', 'Deadlift']},
      {'name': 'Smolov Base Cycle', 'duration': '13 weeks', 'requires1RM': true, 'lifts': ['Squat']},
      {'name': 'Smolov Jr. (Bench)', 'duration': '3-4 weeks', 'requires1RM': true, 'lifts': ['Bench']},
      {'name': 'Candito 6-Week Program', 'duration': '6 weeks', 'requires1RM': true, 'lifts': ['Squat', 'Bench', 'Deadlift']},
      {'name': 'Push/Pull/Legs (PPL)', 'duration': 'Ongoing', 'requires1RM': false},
      {'name': 'Arnold Split', 'duration': 'Ongoing', 'requires1RM': false},
      {'name': 'Bro Split', 'duration': 'Ongoing', 'requires1RM': false},
      {'name': 'PHUL', 'duration': 'Ongoing', 'requires1RM': true, 'lifts': ['Squat', 'Bench', 'Deadlift']},
      {'name': 'PHAT', 'duration': 'Ongoing', 'requires1RM': true, 'lifts': ['Squat', 'Bench', 'Deadlift']},
      {'name': 'German Volume Training', 'duration': '4-6 weeks', 'requires1RM': true, 'lifts': ['Squat', 'Bench', 'Deadlift']},
      {'name': 'Starting Strength', 'duration': '3-6 months', 'requires1RM': false},
      {'name': 'StrongLifts 5x5', 'duration': '3-6 months', 'requires1RM': false},
      {'name': 'Greyskull LP', 'duration': '3-6 months', 'requires1RM': false},
      {'name': 'Full Body 3x/Week', 'duration': 'Ongoing', 'requires1RM': false},
      {'name': 'Couch to 5K', 'duration': '9 weeks', 'requires1RM': false},
      {'name': 'Bodyweight Fitness', 'duration': 'Ongoing', 'requires1RM': false},
      {'name': 'Russian Squat Program', 'duration': '6 weeks', 'requires1RM': true, 'lifts': ['Squat']},
      {'name': 'Super Squats', 'duration': '6 weeks', 'requires1RM': true, 'lifts': ['Squat']},
      {'name': '30-Day Squat Challenge', 'duration': '30 days', 'requires1RM': false},
      {'name': 'Bench Press Specialization', 'duration': '3 weeks', 'requires1RM': true, 'lifts': ['Bench']},
      {'name': 'Deadlift Builder', 'duration': '6 weeks', 'requires1RM': true, 'lifts': ['Deadlift']},
      {'name': 'Arm Blaster', 'duration': '4 weeks', 'requires1RM': false},
      {'name': 'Shoulder Sculptor', 'duration': '6 weeks', 'requires1RM': false},
      {'name': 'Pull-Up Progression', 'duration': '6 weeks', 'requires1RM': false},
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
          final controller = _oneRMControllers[lift];
          oneRMs[lift as String] = double.tryParse(controller?.text ?? '0') ?? 0.0;
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

      // Navigate to the Program Details screen
      Navigator.pushNamed(
        context,
        '/program_details',
        arguments: programId,
      );
    } catch (e) {
      AppSnackBar.showError(context, 'Failed to start program: $e');
    } finally {
      setState(() {
        _isStarting = false;
        _selectedProgram = null;
        _oneRMControllers.clear();
      });
    }
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
            title: const Text('Select a Program'),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            foregroundColor: Theme.of(context).colorScheme.onSurface,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
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
                Column(
                  children: [
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
                    Expanded(
                      child: FutureBuilder<List<Map<String, dynamic>>>(
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
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            itemCount: filteredPrograms.length + 1, // +1 for Custom Program button
                            itemBuilder: (context, index) {
                              if (index == filteredPrograms.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.add, size: 24),
                                    label: const Text('Create Custom Program'),
                                    onPressed: () => Navigator.pushNamed(context, '/custom_program_form'),
                                  ),
                                );
                              }
                              final program = filteredPrograms[index];
                              final programName = program['name'] as String;
                              final duration = program['duration'] as String;
                              final requires1RM = program['requires1RM'] as bool? ?? false;
                              final lifts = program['lifts'] as List<dynamic>? ?? [];
                              final isSelected = _selectedProgram == programName;

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
                                      const SizedBox(height: 8),
                                      Text(
                                        'Duration: $duration',
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                      if (isSelected) ...[
                                        const SizedBox(height: 16),
                                        if (requires1RM) ...[
                                          Text(
                                            'Enter your 1RMs (${unitNotifier.value}):',
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
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}