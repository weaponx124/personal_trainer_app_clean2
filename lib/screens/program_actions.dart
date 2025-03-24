import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_trainer_app_clean/core/data/models/program.dart';
import 'package:personal_trainer_app_clean/core/data/repositories/program_repository.dart';
import 'package:personal_trainer_app_clean/main.dart';
import 'package:personal_trainer_app_clean/screens/program_details_screen.dart';
import 'package:personal_trainer_app_clean/screens/programs_overview_screen.dart';
import 'package:personal_trainer_app_clean/utils/cross_painter.dart';
import 'package:personal_trainer_app_clean/widgets/common/app_snack_bar.dart';

class ProgramActions extends StatefulWidget {
  const ProgramActions({super.key});

  @override
  _ProgramActionsState createState() => _ProgramActionsState();
}

class _ProgramActionsState extends State<ProgramActions> {
  final ProgramRepository _programRepository = ProgramRepository();

  Future<void> _deleteProgram(Program program) async {
    try {
      await _programRepository.deleteProgram(program.id);
      AppSnackBar.showSuccess(context, 'Program deleted successfully!');
      childScreenNotifier.value = const ProgramsOverviewScreen(programName: '');
    } catch (e) {
      AppSnackBar.showError(context, 'Failed to delete program: $e');
    }
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
                appBar: AppBar(
                  title: const Text('Program Actions'),
                  backgroundColor: const Color(0xFF1C2526),
                  foregroundColor: const Color(0xFFB0B7BF),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFFB0B7BF)),
                    onPressed: () {
                      childScreenNotifier.value = const ProgramsOverviewScreen(programName: '');
                    },
                  ),
                ),
                body: FutureBuilder<List<Program>>(
                  future: _programRepository.getPrograms(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator(color: accentColor));
                    }
                    if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Text(
                          'No programs available.',
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            color: const Color(0xFF808080),
                          ),
                        ),
                      );
                    }

                    final programs = snapshot.data!;
                    return ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: programs.length,
                      itemBuilder: (context, index) {
                        final program = programs[index];
                        return ProgramCard(
                          name: program.name,
                          onTap: () {
                            childScreenNotifier.value = ProgramDetailsScreen(programId: program.id);
                          },
                          onDelete: () => _deleteProgram(program),
                        );
                      },
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

class ProgramCard extends StatelessWidget {
  final String name;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const ProgramCard({
    super.key,
    required this.name,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: const Color(0xFFB0B7BF),
      child: ListTile(
        title: Text(
          name,
          style: GoogleFonts.roboto(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1C2526),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: onDelete,
              ),
            const Icon(Icons.arrow_forward, color: Color(0xFF1C2526)),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}