import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_trainer_app_clean/main.dart';

class DailySummary extends StatelessWidget {
  final double dailyCalories;
  final double calorieGoal;
  final double dailyProtein;
  final double dailyCarbs;
  final double dailyFat;
  final double dailyWater;
  final double proteinGoal;
  final double carbsGoal;
  final double fatGoal;
  final double waterGoal;
  final VoidCallback onAddWater;

  const DailySummary({
    super.key,
    required this.dailyCalories,
    required this.calorieGoal,
    required this.dailyProtein,
    required this.dailyCarbs,
    required this.dailyFat,
    required this.dailyWater,
    required this.proteinGoal,
    required this.carbsGoal,
    required this.fatGoal,
    required this.waterGoal,
    required this.onAddWater,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Color>(
      valueListenable: accentColorNotifier,
      builder: (context, accentColor, child) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  color: const Color(0xFFB0B7BF),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daily Summary',
                          style: GoogleFonts.oswald(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildProgressRow(
                          'Calories',
                          dailyCalories,
                          calorieGoal,
                          'kcal',
                          Colors.red,
                        ),
                        const SizedBox(height: 8),
                        _buildProgressRow(
                          'Protein',
                          dailyProtein,
                          proteinGoal,
                          'g',
                          Colors.blue,
                        ),
                        const SizedBox(height: 8),
                        _buildProgressRow(
                          'Carbs',
                          dailyCarbs,
                          carbsGoal,
                          'g',
                          Colors.green,
                        ),
                        const SizedBox(height: 8),
                        _buildProgressRow(
                          'Fat',
                          dailyFat,
                          fatGoal,
                          'g',
                          Colors.orange,
                        ),
                        const SizedBox(height: 8),
                        _buildProgressRow(
                          'Water',
                          dailyWater,
                          waterGoal,
                          'oz',
                          Colors.cyan,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: onAddWater,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Log Water'),
                        ),
                      ],
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

  Widget _buildProgressRow(String label, double current, double goal, String unit, Color color) {
    final progress = (current / goal).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ${current.toStringAsFixed(1)} / ${goal.toStringAsFixed(1)} $unit',
          style: GoogleFonts.roboto(
            fontSize: 16,
            color: const Color(0xFF1C2526),
          ),
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }
}