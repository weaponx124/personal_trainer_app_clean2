import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_trainer_app_clean/core/data/models/program.dart';
import 'package:personal_trainer_app_clean/core/data/repositories/program_repository.dart';

class ProgramListBuilder extends StatelessWidget {
  final ProgramRepository _programRepository = ProgramRepository();

  ProgramListBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Program>>(
      future: _programRepository.getPrograms(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFB22222)));
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              'No programs found.',
              style: GoogleFonts.roboto(
                fontSize: 16,
                color: const Color(0xFF1C2526),
              ),
            ),
          );
        }

        final programs = snapshot.data!;
        return ListView.builder(
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
                  style: GoogleFonts.oswald(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFB22222),
                  ),
                ),
                subtitle: Text(
                  program.description,
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: const Color(0xFF808080),
                  ),
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
    );
  }
}