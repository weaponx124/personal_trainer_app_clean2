import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_trainer_app_clean/core/data/models/program.dart';
import 'package:personal_trainer_app_clean/core/data/repositories/program_repository.dart';
import 'package:personal_trainer_app_clean/core/data/repositories/workout_repository.dart';
import 'package:personal_trainer_app_clean/main.dart';
import 'package:personal_trainer_app_clean/screens/program_details_widgets.dart';
import 'package:personal_trainer_app_clean/screens/program_logic.dart';
import 'package:personal_trainer_app_clean/screens/programs_overview_screen.dart';
import 'package:personal_trainer_app_clean/utils/cross_painter.dart';
import 'package:personal_trainer_app_clean/widgets/common/app_snack_bar.dart';
import 'package:share_plus/share_plus.dart';

class ProgramDetailsScreen extends StatefulWidget {
  final String programId;

  const ProgramDetailsScreen({super.key, required this.programId});

  @override
  _ProgramDetailsScreenState createState() => _ProgramDetailsScreenState();
}

class _ProgramDetailsScreenState extends State<ProgramDetailsScreen> {
  final ProgramRepository _programRepository = ProgramRepository();
  late Future<Program> _programFuture;
  late ProgramLogic _programLogic;

  @override
  void initState() {
    super.initState();
    _programFuture = _programRepository.getPrograms().then((programs) {
      final program = programs.firstWhere((p) => p.id == widget.programId, orElse: () => throw Exception('Program not found'));
      _programLogic = ProgramLogic(program.toMap());
      return program;
    });
  }

  Future<void> _endProgram(Program program) async {
    try {
      final updatedProgram = program.copyWith(completed: true);
      await _programRepository.updateProgram(updatedProgram);
      AppSnackBar.showSuccess(context, 'Program ended successfully!');
      childScreenNotifier.value = const ProgramsOverviewScreen(programName: '');
    } catch (e) {
      AppSnackBar.showError(context, 'Failed to end program: $e');
    }
  }

  Future<void> _shareProgress(Program program) async {
    final totalWorkouts = (await WorkoutRepository().getWorkouts(program.id)).length;
    final oneRMsSummary = program.oneRMs.entries.map((entry) => '${entry.key}: ${entry.value} ${program.details['unit'] ?? 'lbs'}').join('\n');
    final shareText = '''
Program: ${program.name}
Started: ${program.startDate}
Total Workouts Logged: $totalWorkouts
1RMs:
$oneRMsSummary
''';
    await Share.share(shareText, subject: 'My Program Progress');
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Color>(
      valueListenable: accentColorNotifier,
      builder: (context, accentColor, child) {
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
              Scaffold(
                backgroundColor: Colors.transparent,
                floatingActionButton: FutureBuilder<Program>(
                  future: _programFuture,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const SizedBox.shrink(); // Don't show FAB until program is loaded
                    }
                    return FloatingActionButton(
                      onPressed: () => _shareProgress(snapshot.data!),
                      backgroundColor: accentColor,
                      child: const Icon(Icons.share),
                      tooltip: 'Share Progress',
                    );
                  },
                ),
                body: FutureBuilder<Program>(
                  future: _programFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError || !snapshot.hasData) {
                      return Center(
                        child: Text(
                          'Error loading program: ${snapshot.error}',
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            color: const Color(0xFF808080),
                          ),
                        ),
                      );
                    }

                    final program = snapshot.data!;
                    final unit = program.details['unit'] as String? ?? 'lbs';

                    return SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ProgramDetailsWidget(program: program.toMap(), unit: unit),
                            const SizedBox(height: 16),
                            WorkoutCard(
                              program: program,
                              unit: unit,
                              onTap: () {},
                              onLogWorkout: (workout) async {},
                            ),
                            const SizedBox(height: 16),
                            ProgramProgressWidget(programId: program.id),
                            const SizedBox(height: 16),
                            Center(
                              child: SizedBox(
                                width: 150,
                                child: ElevatedButton(
                                  onPressed: () => _endProgram(program),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  child: const Text('End Program'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}