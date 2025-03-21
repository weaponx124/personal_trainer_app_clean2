import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_trainer_app_clean/core/data/models/program.dart';
import 'package:personal_trainer_app_clean/core/data/repositories/program_repository.dart';
import 'package:personal_trainer_app_clean/main.dart';
import 'package:personal_trainer_app_clean/screens/program_details_screen.dart';
import 'package:personal_trainer_app_clean/utils/cross_painter.dart';
import 'package:personal_trainer_app_clean/widgets/common/app_snack_bar.dart';
import 'package:personal_trainer_app_clean/widgets/common/loading_indicator.dart';

class ProgramListBuilder extends StatefulWidget {
  const ProgramListBuilder({super.key});

  @override
  _ProgramListBuilderState createState() => _ProgramListBuilderState();
}

class _ProgramListBuilderState extends State<ProgramListBuilder> {
  final ProgramRepository _programRepository = ProgramRepository();
  late Future<List<Program>> _programsFuture;
  List<Program> _programs = [];

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
    });
  }

  Future<void> _deleteProgram(String programId) async {
    await _programRepository.deleteProgram(programId);
    setState(() {
      _programsFuture = _loadPrograms();
      _loadProgramsData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: unitNotifier,
      builder: (context, unit, child) {
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
              FutureBuilder<List<Program>>(
                future: _programsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const LoadingIndicator();
                  }
                  if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        'No active programs.',
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          color: const Color(0xFF1C2526),
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
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        color: const Color(0xFFB0B7BF),
                        child: ListTile(
                          title: Text(
                            program.name,
                            style: GoogleFonts.oswald(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFB22222),
                            ),
                          ),
                          subtitle: Text(
                            program.description ?? 'No description available',
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              color: const Color(0xFF808080),
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Color(0xFFB22222)),
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
        );
      },
    );
  }
}