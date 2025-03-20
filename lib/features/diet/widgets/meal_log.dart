import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_trainer_app_clean/core/data/models/meal.dart';

class MealLog extends StatelessWidget {
  final List<Meal> meals;
  final Function(String) onDelete;

  const MealLog({
    Key? key,
    required this.meals,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59).millisecondsSinceEpoch;

    final todayMeals = meals.where((meal) {
      final timestamp = meal.timestamp;
      return timestamp >= startOfDay && timestamp <= endOfDay;
    }).toList();

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
              'Today\'s Meals',
              style: GoogleFonts.oswald(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFB22222),
              ),
            ),
            const SizedBox(height: 8),
            todayMeals.isEmpty
                ? const Text('No meals logged yet.')
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: todayMeals.length,
              itemBuilder: (context, index) {
                final meal = todayMeals[index];
                final date = DateTime.fromMillisecondsSinceEpoch(meal.timestamp);
                return ListTile(
                  title: Text(
                    '${meal.mealType}: ${meal.food}',
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      color: const Color(0xFF1C2526),
                    ),
                  ),
                  subtitle: Text(
                    '${meal.calories} kcal, ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      color: const Color(0xFF808080),
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Color(0xFFB22222)),
                    onPressed: () => onDelete(meal.id),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}