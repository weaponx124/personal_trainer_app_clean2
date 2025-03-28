import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_trainer_app_clean/main.dart';
import 'package:personal_trainer_app_clean/core/data/models/meal.dart';
import 'package:personal_trainer_app_clean/core/data/models/recipe.dart';
import '../diet_screen_logic.dart';

class MealLog extends StatelessWidget {
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
        return ValueListenableBuilder<List<Meal>>(
          valueListenable: logic.meals,
          builder: (context, meals, _) {
            // Get meals for the selected date
            final dateMeals = logic.getMealsForDate(selectedDate);
            final mealGroups = <String, List<Meal>>{};
            for (var meal in dateMeals) {
              mealGroups.putIfAbsent(meal.mealType, () => []).add(meal);
            }

            return Container(
              color: Colors.grey[200], // Apply grey background
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: ValueListenableBuilder<List<String>>(
                              valueListenable: logic.mealNames,
                              builder: (context, mealNames, _) {
                                return DropdownButton<String>(
                                  value: mealNames.contains(selectedMealType) ? selectedMealType : mealNames[0],
                                  isExpanded: true,
                                  items: mealNames.map((String value) {
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
                                );
                              },
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
                          ? Center(
                        child: Text(
                          'No meals logged for ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}.',
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            color: const Color(0xFF1C2526),
                          ),
                        ),
                      )
                          : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: mealGroups.keys.length,
                        itemBuilder: (context, index) {
                          final mealType = mealGroups.keys.elementAt(index);
                          final groupMeals = mealGroups[mealType]!;
                          final totalCalories = groupMeals.fold<double>(
                            0.0,
                                (sum, meal) => sum + (meal.calories * meal.servings),
                          );
                          return ExpansionTile(
                            title: Text(
                              '$mealType (${groupMeals.length})',
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                color: const Color(0xFF1C2526),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'Total: ${totalCalories.toStringAsFixed(1)} kcal',
                              style: GoogleFonts.roboto(
                                fontSize: 14,
                                color: const Color(0xFF808080),
                              ),
                            ),
                            children: groupMeals.map((meal) {
                              String displayName = meal.food;
                              if (meal.isRecipe) {
                                final recipe = logic.recipes.value.firstWhere(
                                      (r) => r.id == meal.food,
                                  orElse: () => Recipe(
                                    id: meal.food,
                                    name: 'Unknown Recipe',
                                    calories: meal.calories,
                                    protein: meal.protein,
                                    carbs: meal.carbs,
                                    fat: meal.fat,
                                    sodium: meal.sodium,
                                    fiber: meal.fiber,
                                    ingredients: [],
                                  ),
                                );
                                displayName = recipe.name;
                              } else {
                                // Look up the food in foodDatabase to get the measurement
                                final foodEntry = logic.foodDatabase.firstWhere(
                                      (f) => f['food'] == meal.food,
                                  orElse: () => {'food': meal.food, 'measurement': 'Per serving'},
                                );
                                final measurement = foodEntry['measurement'] as String;
                                displayName = '${meal.food} $measurement';
                              }
                              return Card(
                                child: ListTile(
                                  title: Text(
                                    displayName,
                                    style: GoogleFonts.roboto(
                                      fontSize: 16,
                                      color: const Color(0xFF1C2526),
                                    ),
                                  ),
                                  subtitle: Wrap(
                                    spacing: 8.0,
                                    children: [
                                      Text(
                                        '${meal.calories.toStringAsFixed(1)} kcal',
                                        style: GoogleFonts.roboto(
                                          fontSize: 14,
                                          color: const Color(0xFF808080),
                                        ),
                                      ),
                                      Text(
                                        '${meal.protein.toStringAsFixed(1)}g protein',
                                        style: GoogleFonts.roboto(
                                          fontSize: 14,
                                          color: const Color(0xFF808080),
                                        ),
                                      ),
                                      Text(
                                        '${meal.carbs.toStringAsFixed(1)}g carbs',
                                        style: GoogleFonts.roboto(
                                          fontSize: 14,
                                          color: const Color(0xFF808080),
                                        ),
                                      ),
                                      Text(
                                        '${meal.fat.toStringAsFixed(1)}g fat',
                                        style: GoogleFonts.roboto(
                                          fontSize: 14,
                                          color: const Color(0xFF808080),
                                        ),
                                      ),
                                      Text(
                                        '${meal.sodium.toStringAsFixed(1)}mg sodium',
                                        style: GoogleFonts.roboto(
                                          fontSize: 14,
                                          color: const Color(0xFF808080),
                                        ),
                                      ),
                                      Text(
                                        '${meal.fiber.toStringAsFixed(1)}g fiber',
                                        style: GoogleFonts.roboto(
                                          fontSize: 14,
                                          color: const Color(0xFF808080),
                                        ),
                                      ),
                                    ],
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
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}