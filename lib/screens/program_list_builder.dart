import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_trainer_app_clean/core/data/models/program.dart';
import 'package:personal_trainer_app_clean/core/data/repositories/program_repository.dart';
import 'package:personal_trainer_app_clean/main.dart';
import 'package:personal_trainer_app_clean/screens/program_details_screen.dart';
import 'package:personal_trainer_app_clean/screens/programs_overview_screen.dart';
import 'package:personal_trainer_app_clean/widgets/common/app_snack_bar.dart';

class ProgramListBuilder extends StatefulWidget {
  final bool showCompleted;

  const ProgramListBuilder({super.key, required this.showCompleted});

  @override
  _ProgramListBuilderState createState() => _ProgramListBuilderState();
}

class _ProgramListBuilderState extends State<ProgramListBuilder> {
  final ProgramRepository _programRepository = ProgramRepository();

  Future<void> _deleteProgram(Program program) async {
    try {
      await _programRepository.deleteProgram(program.id);
      AppSnackBar.showSuccess(context, 'Program deleted successfully!');
      setState(() {});
    } catch (e) {
      AppSnackBar.showError(context, 'Failed to delete program: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Color>(
      valueListenable: accentColorNotifier,
      builder: (context, accentColor, child) {
        return FutureBuilder<List<Program>>(
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

            final programs = snapshot.data!.where((program) => program.completed == widget.showCompleted).toList();
            if (programs.isEmpty) {
              return Center(
                child: Text(
                  widget.showCompleted ? 'No completed programs.' : 'No active programs.',
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    color: const Color(0xFF808080),
                  ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: programs.length,
              itemBuilder: (context, index) {
                final program = programs[index];
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  color: const Color(0xFFB0B7BF),
                  child: ListTile(
                    title: Text(
                      program.name,
                      style: GoogleFonts.roboto(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1C2526),
                      ),
                    ),
                    subtitle: Text(
                      'Started: ${program.startDate}',
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        color: const Color(0xFF808080),
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteProgram(program),
                        ),
                        const Icon(Icons.arrow_forward, color: Color(0xFF1C2526)),
                      ],
                    ),
                    onTap: () {
                      childScreenNotifier.value = ProgramDetailsScreen(programId: program.id);
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}