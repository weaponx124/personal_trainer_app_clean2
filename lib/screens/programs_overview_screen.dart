import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_trainer_app_clean/core/data/models/program.dart';
import 'package:personal_trainer_app_clean/core/data/repositories/program_repository.dart';
import 'package:personal_trainer_app_clean/main.dart';
import 'package:personal_trainer_app_clean/screens/program_details_screen.dart';
import 'package:personal_trainer_app_clean/utils/cross_painter.dart';
import 'package:personal_trainer_app_clean/widgets/common/loading_indicator.dart';
import 'package:personal_trainer_app_clean/widgets/common/app_snack_bar.dart';
import 'package:personal_trainer_app_clean/core/theme/app_theme.dart';
import 'package:uuid/uuid.dart';

class ProgramsOverviewScreen extends StatefulWidget {
  final String unit;
  final String programName;

  const ProgramsOverviewScreen({
    super.key,
    required this.unit,
    required this.programName,
  });

  @override
  _ProgramsOverviewScreenState createState() => _ProgramsOverviewScreenState();
}

class _ProgramsOverviewScreenState extends State<ProgramsOverviewScreen> {
  final ProgramRepository _programRepository = ProgramRepository();
  late Future<List<Program>> _programsFuture;
  List<Program> _programs = [];
  String _sortOption = 'Start Date (Newest)';

  @override
  void initState() {
    super.initState();
    _programsFuture = _loadPrograms();
    _loadProgramsData();
  }

  Future<List<Program>> _loadPrograms() async {
    try {
      final programs = await _programRepository.getPrograms();
      return programs;
    } catch (e) {
      print('Error loading programs: $e');
      AppSnackBar.showError(context, 'Failed to load programs: $e');
      return [];
    }
  }

  Future<void> _loadProgramsData() async {
    final programs = await _programsFuture;
    setState(() {
      _programs = List.from(programs);
      _sortPrograms();
    });
  }

  void _sortPrograms() {
    setState(() {
      if (_sortOption == 'Start Date (Newest)') {
        _programs.sort((a, b) => (b.toMap()['startDate'] ?? '').compareTo(a.toMap()['startDate'] ?? ''));
      } else if (_sortOption == 'Start Date (Oldest)') {
        _programs.sort((a, b) => (a.toMap()['startDate'] ?? '').compareTo(b.toMap()['startDate'] ?? ''));
      } else if (_sortOption == 'Completed') {
        _programs.sort((a, b) {
          final aCompleted = a.toMap()['completed'] as bool? ?? false;
          final bCompleted = b.toMap()['completed'] as bool? ?? false;
          return (bCompleted ? 1 : 0).compareTo(aCompleted ? 1 : 0);
        });
      } else if (_sortOption == 'Not Completed') {
        _programs.sort((a, b) {
          final aCompleted = a.toMap()['completed'] as bool? ?? false;
          final bCompleted = b.toMap()['completed'] as bool? ?? false;
          return (aCompleted ? 1 : 0).compareTo(bCompleted ? 1 : 0);
        });
      }
    });
  }

  Future<void> _deleteProgram(String programId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Program',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        content: Text(
          'Are you sure you want to delete this program? This action cannot be undone.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _programRepository.deleteProgram(programId);
        AppSnackBar.showSuccess(context, 'Program deleted successfully');
        setState(() {
          _programsFuture = _loadPrograms();
          _loadProgramsData();
        });
      } catch (e) {
        AppSnackBar.showError(context, 'Failed to delete program: $e');
      }
    }
  }

  Future<void> _startRecommendedProgram(String programName) async {
    try {
      // Create a new program instance
      final programId = Uuid().v4();
      final startDate = DateTime.now().toIso8601String().split('T')[0];
      final description = _getProgramDescription(programName);
      final requires1RM = _requires1RM(programName);

      Map<String, dynamic> oneRMs = {};
      Map<String, dynamic> details = {
        'unit': widget.unit,
        'requires1RM': requires1RM,
      };

      if (requires1RM) {
        oneRMs = {
          'Squat': 0.0,
          'Bench': 0.0,
          'Deadlift': 0.0,
          ...(programName == '5/3/1 Program' ? {'Overhead': 0.0} : {}),
        };
        details['1RMs'] = oneRMs;
      }

      final newProgram = Program(
        id: programId,
        name: programName,
        description: description,
        oneRMs: oneRMs,
        details: details,
        completed: false,
        startDate: startDate,
        currentWeek: 1,
        currentSession: 1,
        sessionsCompleted: 0,
      );

      // Save the program to the repository
      await _programRepository.insertProgram(newProgram);

      // Show success message
      AppSnackBar.showSuccess(context, 'Started $programName!');

      // Refresh the programs list
      setState(() {
        _programsFuture = _loadPrograms();
        _loadProgramsData();
      });

      // Navigate to the Program Details screen
      Navigator.pushNamed(
        context,
        '/program_details',
        arguments: programId,
      );
    } catch (e) {
      AppSnackBar.showError(context, 'Failed to start program: $e');
    }
  }

  String _getProgramDescription(String programName) {
    switch (programName) {
      case '5/3/1 Program':
        return 'Ongoing, Strength';
      case 'Starting Strength':
        return '3-6 Months, Beginner';
      case 'PPL':
        return 'Ongoing, Hypertrophy';
      default:
        return 'Fitness Program';
    }
  }

  bool _requires1RM(String programName) {
    switch (programName) {
      case '5/3/1 Program':
        return true;
      case 'Starting Strength':
        return false;
      case 'PPL':
        return false;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: unitNotifier,
      builder: (context, unit, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.programName.isNotEmpty ? widget.programName : 'Active Programs'),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            foregroundColor: Theme.of(context).colorScheme.onSurface,
            actions: [
              DropdownButton<String>(
                value: _sortOption,
                icon: const Icon(Icons.sort),
                items: <String>['Start Date (Newest)', 'Start Date (Oldest)', 'Completed', 'Not Completed']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _sortOption = newValue;
                      _sortPrograms();
                    });
                  }
                },
              ),
              const SizedBox(width: 16),
            ],
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppTheme.lightBlue.withOpacity(0.2), AppTheme.matteBlack],
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
                FutureBuilder<List<Program>>(
                  future: _programsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const LoadingIndicator();
                    }
                    if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                      return SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 40),
                              Icon(
                                Icons.fitness_center,
                                size: 80,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No Active Programs',
                                style: Theme.of(context).textTheme.headlineMedium,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Programs help you stay on track with your fitness goals. Start one today to track your progress!',
                                style: Theme.of(context).textTheme.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.add, size: 24),
                                label: const Text('Start a Program'),
                                onPressed: () => Navigator.pushNamed(context, '/program_selection'),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Recommended Programs',
                                style: Theme.of(context).textTheme.headlineMedium,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              _buildRecommendedProgramCard('5/3/1 Program', 'Ongoing, Strength'),
                              const SizedBox(height: 8),
                              _buildRecommendedProgramCard('Starting Strength', '3-6 Months, Beginner'),
                              const SizedBox(height: 8),
                              _buildRecommendedProgramCard('PPL', 'Ongoing, Hypertrophy'),
                            ],
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _programs.length,
                      itemBuilder: (context, index) {
                        final program = _programs[index];
                        return Card(
                          child: ListTile(
                            title: Text(
                              program.name,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            subtitle: Text(
                              'Started: ${program.startDate}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              color: Theme.of(context).colorScheme.secondary,
                              onPressed: () => _deleteProgram(program.id),
                            ),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/program_details',
                                arguments: program.id,
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => Navigator.pushNamed(context, '/program_selection'),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildRecommendedProgramCard(String name, String description) {
    return Card(
      child: ListTile(
        title: Text(
          name,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        subtitle: Text(
          description,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: Icon(
          Icons.arrow_forward,
          color: Theme.of(context).colorScheme.secondary,
        ),
        onTap: () => _startRecommendedProgram(name),
      ),
    );
  }
}