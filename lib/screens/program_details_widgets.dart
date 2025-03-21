import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_trainer_app_clean/core/data/models/workout.dart';
import 'package:personal_trainer_app_clean/core/data/repositories/workout_repository.dart';

class WorkoutCard extends StatelessWidget {
  final Map<String, dynamic> workout;
  final String unit;
  final VoidCallback onTap;

  const WorkoutCard({
    super.key,
    required this.workout,
    required this.unit,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: const Color(0xFFB0B7BF),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                workout['name'] ?? 'Workout',
                style: GoogleFonts.oswald(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFB22222),
                ),
              ),
              const SizedBox(height: 8),
              if (workout['exercises'] != null && workout['exercises'].isNotEmpty)
                ...workout['exercises'].map<Widget>((exercise) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      '${exercise['name']}: ${exercise['sets']} sets x ${exercise['reps']} reps @ ${exercise['weight']} $unit',
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        color: const Color(0xFF1C2526),
                      ),
                    ),
                  );
                }).toList()
              else
                Text(
                  'No exercises logged.',
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    color: const Color(0xFF808080),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProgramDetailsWidget extends StatelessWidget {
  final Map<String, dynamic> program;
  final String unit;

  const ProgramDetailsWidget({super.key, required this.program, required this.unit});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: const Color(0xFFB0B7BF),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              program['name'] ?? 'Program Details',
              style: GoogleFonts.oswald(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFB22222),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Started: ${program['startDate'] ?? 'Unknown'}',
              style: GoogleFonts.roboto(
                fontSize: 16,
                color: const Color(0xFF1C2526),
              ),
            ),
            const SizedBox(height: 8),
            if (program['oneRMs'] != null)
              ...program['oneRMs'].entries.map<Widget>((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Text(
                    '${entry.key} 1RM: ${entry.value} $unit',
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      color: const Color(0xFF1C2526),
                    ),
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }
}

class ExerciseInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool isNumeric;

  const ExerciseInputWidget({
    super.key,
    required this.controller,
    required this.label,
    this.isNumeric = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.roboto(
            fontSize: 16,
            color: const Color(0xFF808080),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: const Color(0xFFB0B7BF),
        ),
        style: GoogleFonts.roboto(
          fontSize: 16,
          color: const Color(0xFF1C2526),
        ),
      ),
    );
  }
}

class ProgramProgressWidget extends StatelessWidget {
  final String programId;

  const ProgramProgressWidget({super.key, required this.programId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Workout>>(
      future: WorkoutRepository().getWorkouts(programId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFB22222)));
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return Text(
            'No workouts logged for this program.',
            style: GoogleFonts.roboto(
              fontSize: 16,
              color: const Color(0xFF808080),
            ),
          );
        }

        final workouts = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Program Progress',
              style: GoogleFonts.oswald(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFB22222),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Total Workouts Logged: ${workouts.length}',
              style: GoogleFonts.roboto(
                fontSize: 16,
                color: const Color(0xFF1C2526),
              ),
            ),
          ],
        );
      },
    );
  }
}