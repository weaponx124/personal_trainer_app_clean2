import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DailySummary extends StatelessWidget {
  final double dailyCalories;
  final double calorieGoal;
  final double dailyProtein;
  final double dailyCarbs;
  final double dailyFat;
  final double dailyWater;

  const DailySummary({
    Key? key,
    required this.dailyCalories,
    required this.calorieGoal,
    required this.dailyProtein,
    required this.dailyCarbs,
    required this.dailyFat,
    required this.dailyWater,
  }) : super(key: key);

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
              'Daily Summary',
              style: GoogleFonts.oswald(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFB22222),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Calories: ${dailyCalories.toStringAsFixed(1)} / $calorieGoal kcal',
              style: GoogleFonts.roboto(
                fontSize: 16,
                color: const Color(0xFF1C2526),
              ),
            ),
            Text(
              'Protein: ${dailyProtein.toStringAsFixed(1)} g',
              style: GoogleFonts.roboto(
                fontSize: 16,
                color: const Color(0xFF1C2526),
              ),
            ),
            Text(
              'Carbs: ${dailyCarbs.toStringAsFixed(1)} g',
              style: GoogleFonts.roboto(
                fontSize: 16,
                color: const Color(0xFF1C2526),
              ),
            ),
            Text(
              'Fat: ${dailyFat.toStringAsFixed(1)} g',
              style: GoogleFonts.roboto(
                fontSize: 16,
                color: const Color(0xFF1C2526),
              ),
            ),
            Text(
              'Water: ${dailyWater.toStringAsFixed(1)} oz',
              style: GoogleFonts.roboto(
                fontSize: 16,
                color: const Color(0xFF1C2526),
              ),
            ),
          ],
        ),
      ),
    );
  }
}