import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_trainer_app_clean/main.dart';
import 'package:personal_trainer_app_clean/core/data/models/meal.dart';
import '../diet_screen_logic.dart';

class MealLog extends StatelessWidget {
  final List<Meal> meals;
  final VoidCallback onAddCustomFood;
  final VoidCallback onAddRecipe;
  final VoidCallback onAddMeal;
  final Function(Meal) onEdit;
  final Function(String) onDelete;
  final String selectedMealType;
  final ValueChanged<String?> onMealTypeChanged;
  final DateTime selectedDate;
  final DietScreenLogic logic;

  const MealLog({
    super.key,
    required this.meals,
    required this.onAddCustomFood,
    required this.onAddRecipe,
    required this.onAddMeal,
    required this.onEdit,
    required this.onDelete,
    required this.selectedMealType,
    required this.onMealTypeChanged,
    required this.selectedDate,
    required this.logic,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Color>(
      valueListenable: accentColorNotifier,
      builder: (context, accentColor, child) {
        final startOfDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day).millisecondsSinceEpoch;
        final endOfDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 23, 59, 59).millisecondsSinceEpoch;

        final dateMeals = meals.where((meal) {
          final timestamp = meal.timestamp;
          return timestamp >= startOfDay && timestamp <= endOfDay;
        }).toList();

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButton<String>(
                        value: logic.mealNames.contains(selectedMealType) ? selectedMealType : logic.mealNames[0],
                        isExpanded: true,
                        items: logic.mealNames.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: onMealTypeChanged,
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: onAddMeal,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Log Meal'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                dateMeals.isEmpty
                    ? Center(child: Text('No meals logged for ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}.'))
                    : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: dateMeals.length,
                  itemBuilder: (context, index) {
                    final meal = dateMeals[index];
                    return Card(
                      child: ListTile(
                        title: Text(
                          '${meal.mealType}: ${meal.food}',
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            color: const Color(0xFF1C2526),
                          ),
                        ),
                        subtitle: Text(
                          '${meal.calories.toStringAsFixed(1)} kcal, ${meal.protein.toStringAsFixed(1)}g protein',
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            color: const Color(0xFF808080),
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: accentColor),
                              onPressed: () => onEdit(meal),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: accentColor),
                              onPressed: () => onDelete(meal.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}