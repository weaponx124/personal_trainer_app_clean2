import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_trainer_app_clean/core/data/models/program.dart';
import 'package:personal_trainer_app_clean/core/data/repositories/program_repository.dart';
import 'package:personal_trainer_app_clean/main.dart';
import 'package:personal_trainer_app_clean/screens/program_details_widgets.dart';
import 'package:personal_trainer_app_clean/screens/programs_overview_screen.dart';
import 'package:personal_trainer_app_clean/utils/cross_painter.dart';
import 'package:personal_trainer_app_clean/widgets/common/app_snack_bar.dart';

class ProgramDetailsScreen extends StatefulWidget {
  final String programId;

  const ProgramDetailsScreen({super.key, required this.programId});

  @override
  _ProgramDetailsScreenState createState() => _ProgramDetailsScreenState();
}

class _ProgramDetailsScreenState extends State<ProgramDetailsScreen> {
  final ProgramRepository _programRepository = ProgramRepository();
  late Future<Program> _programFuture;

  @override
  void initState() {
    super.initState();
    _programFuture = _programRepository.getPrograms().then((programs) {
      final program = programs.firstWhere((p) => p.id == widget.programId, orElse: () => throw Exception('Program not found'));
      return program;
    });
  }

  Future<void> _endProgram(Program program) async {
    try {
      final updatedProgram = program.copyWith(completed: true);
      await _programRepository.updateProgram(updatedProgram);
      AppSnackBar.showSuccess(context, 'Program ended successfully!');
      // Navigate back to ProgramsOverviewScreen by updating childScreenNotifier
      childScreenNotifier.value = const ProgramsOverviewScreen(programName: '');
    } catch (e) {
      AppSnackBar.showError(context, 'Failed to end program: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Color>(
      valueListenable: accentColorNotifier,
      builder: (context, accentColor, child) {
        return FutureBuilder<Program>(
          future: _programFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [const Color(0xFF87CEEB).withOpacity(0.2), const Color(0xFF1C2526)],
                  ),
                ),
                child: Center(child: CircularProgressIndicator(color: accentColor)),
              );
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [const Color(0xFF87CEEB).withOpacity(0.2), const Color(0xFF1C2526)],
                  ),
                ),
                child: Center(
                  child: Text(
                    'Error loading program: ${snapshot.error}',
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      color: const Color(0xFF808080),
                    ),
                  ),
                ),
              );
            }

            final program = snapshot.data!;
            final unit = program.details['unit'] as String? ?? 'lbs';

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
                    appBar: AppBar(
                      title: Text(program.name),
                      backgroundColor: const Color(0xFF1C2526),
                      foregroundColor: const Color(0xFFB0B7BF),
                      leading: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Color(0xFFB0B7BF)),
                        onPressed: () {
                          // Navigate back to ProgramsOverviewScreen by updating childScreenNotifier
                          childScreenNotifier.value = const ProgramsOverviewScreen(programName: '');
                        },
                      ),
                    ),
                    body: SingleChildScrollView(
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
                              onTap: () {
                                // No action needed for "Start Workout" button
                              },
                              onLogWorkout: (workout) async {
                                // No action needed for "Log Workout" button
                              },
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
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}