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
  final DateTime selectedDate;
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
    required this.selectedDate,
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
                // Calories
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
                          'Calories',
                          style: GoogleFonts.oswald(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: dailyCalories / calorieGoal,
                          backgroundColor: const Color(0xFF808080),
                          valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${dailyCalories.toStringAsFixed(1)} / ${calorieGoal.toStringAsFixed(1)} kcal',
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            color: const Color(0xFF1C2526),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Macros
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
                          'Macros',
                          style: GoogleFonts.oswald(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Protein',
                                    style: GoogleFonts.roboto(
                                      fontSize: 16,
                                      color: const Color(0xFF1C2526),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  LinearProgressIndicator(
                                    value: dailyProtein / proteinGoal,
                                    backgroundColor: const Color(0xFF808080),
                                    valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${dailyProtein.toStringAsFixed(1)} / ${proteinGoal.toStringAsFixed(1)} g',
                                    style: GoogleFonts.roboto(
                                      fontSize: 14,
                                      color: const Color(0xFF1C2526),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Carbs',
                                    style: GoogleFonts.roboto(
                                      fontSize: 16,
                                      color: const Color(0xFF1C2526),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  LinearProgressIndicator(
                                    value: dailyCarbs / carbsGoal,
                                    backgroundColor: const Color(0xFF808080),
                                    valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${dailyCarbs.toStringAsFixed(1)} / ${carbsGoal.toStringAsFixed(1)} g',
                                    style: GoogleFonts.roboto(
                                      fontSize: 14,
                                      color: const Color(0xFF1C2526),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Fat',
                                    style: GoogleFonts.roboto(
                                      fontSize: 16,
                                      color: const Color(0xFF1C2526),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  LinearProgressIndicator(
                                    value: dailyFat / fatGoal,
                                    backgroundColor: const Color(0xFF808080),
                                    valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${dailyFat.toStringAsFixed(1)} / ${fatGoal.toStringAsFixed(1)} g',
                                    style: GoogleFonts.roboto(
                                      fontSize: 14,
                                      color: const Color(0xFF1C2526),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Water Intake
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
                          'Water Intake',
                          style: GoogleFonts.oswald(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: dailyWater / waterGoal,
                          backgroundColor: const Color(0xFF808080),
                          valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${dailyWater.toStringAsFixed(1)} / ${waterGoal.toStringAsFixed(1)} oz',
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            color: const Color(0xFF1C2526),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.local_drink),
                            label: const Text('Add Water'),
                            onPressed: onAddWater,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentColor,
                              foregroundColor: Colors.white,
                            ),
                          ),
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
}