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
    // Normalize the selected date to the start of the day
    final normalizedDate = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );
    print('MealLog: Normalized selectedDate: ${normalizedDate.toString()}');

    return ValueListenableBuilder<Color>(
      valueListenable: accentColorNotifier,
      builder: (context, accentColor, child) {
        return ValueListenableBuilder<List<String>>(
          valueListenable: logic.stateManager.mealNames,
          builder: (context, mealNames, _) {
            print('MealLog: Meal names updated: $mealNames');
            return ValueListenableBuilder<List<Meal>>(
              valueListenable: logic.stateManager.meals,
              builder: (context, meals, _) {
                print('MealLog: Rebuilding with ${meals.length} meals');
                print('MealLog: Total meals in state: ${meals.length}');
                // Log all meals in the state
                for (var meal in meals) {
                  print('MealLog: Meal in state: ${meal.toJson()}');
                }
                // Get meals for the selected date
                final dateMeals = logic.stateManager.getMealsForDate(normalizedDate);
                print('MealLog: Date meals for ${normalizedDate.toString()}: ${dateMeals.length}');
                final mealGroups = <String, List<Meal>>{};
                for (var meal in dateMeals) {
                  mealGroups.putIfAbsent(meal.mealType, () => []).add(meal);
                  print('MealLog: Added meal to group ${meal.mealType}: ${meal.toJson()}');
                }
                print('MealLog: Meal groups: ${mealGroups.keys.toList()}');

                return Container(
                  color: Colors.grey[200], // Apply grey background
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          dateMeals.isEmpty && mealNames.isEmpty
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
                            itemCount: mealNames.length,
                            itemBuilder: (context, index) {
                              final mealType = mealNames[index];
                              final groupMeals = mealGroups[mealType] ?? [];
                              final totalCalories = groupMeals.fold<double>(
                                0.0,
                                    (sum, meal) => sum + (meal.calories * meal.servings),
                              );
                              print('MealLog: Rendering meal type: $mealType with ${groupMeals.length} meals');
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
                                children: groupMeals.isEmpty
                                    ? [
                                  const ListTile(
                                    title: Text(
                                      'No foods added to this meal.',
                                      style: TextStyle(color: Color(0xFF808080)),
                                    ),
                                  ),
                                ]
                                    : groupMeals.map((meal) {
                                  String displayName = meal.food;
                                  String measurement = 'serving'; // Default for recipes and custom foods
                                  if (meal.isRecipe) {
                                    final recipe = logic.stateManager.recipes.value.firstWhere(
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
                                    measurement = recipe.servingSizeUnit ?? 'serving';
                                  } else {
                                    // Look up the food in foodDatabase or allFoods to get the measurement
                                    final foodEntry = logic.stateManager.allFoods.firstWhere(
                                          (f) => f['food'] == meal.food,
                                      orElse: () => logic.stateManager.foodDatabase.firstWhere(
                                            (f) => f['food'] == meal.food,
                                        orElse: () => {'food': meal.food, 'measurement': 'serving'},
                                      ),
                                    );
                                    measurement = foodEntry['measurement'] as String;
                                  }
                                  // Use the user-specified servingSizeUnit if available
                                  final displayMeasurement = meal.servingSizeUnit ?? measurement;
                                  // Scale the nutritional values by the number of servings
                                  final scaledCalories = meal.calories * meal.servings;
                                  final scaledProtein = meal.protein * meal.servings;
                                  final scaledCarbs = meal.carbs * meal.servings;
                                  final scaledFat = meal.fat * meal.servings;
                                  final scaledSodium = meal.sodium * meal.servings;
                                  final scaledFiber = meal.fiber * meal.servings;
                                  return Card(
                                    child: ListTile(
                                      title: Text(
                                        '$displayName $displayMeasurement (${meal.servings.toStringAsFixed(1)} servings)',
                                        style: GoogleFonts.roboto(
                                          fontSize: 16,
                                          color: const Color(0xFF1C2526),
                                        ),
                                      ),
                                      subtitle: Wrap(
                                        spacing: 8.0,
                                        children: [
                                          Text(
                                            '${scaledCalories.toStringAsFixed(1)} kcal',
                                            style: GoogleFonts.roboto(
                                              fontSize: 14,
                                              color: const Color(0xFF808080),
                                            ),
                                          ),
                                          Text(
                                            '${scaledProtein.toStringAsFixed(1)}g protein',
                                            style: GoogleFonts.roboto(
                                              fontSize: 14,
                                              color: const Color(0xFF808080),
                                            ),
                                          ),
                                          Text(
                                            '${scaledCarbs.toStringAsFixed(1)}g carbs',
                                            style: GoogleFonts.roboto(
                                              fontSize: 14,
                                              color: const Color(0xFF808080),
                                            ),
                                          ),
                                          Text(
                                            '${scaledFat.toStringAsFixed(1)}g fat',
                                            style: GoogleFonts.roboto(
                                              fontSize: 14,
                                              color: const Color(0xFF808080),
                                            ),
                                          ),
                                          Text(
                                            '${scaledSodium.toStringAsFixed(1)}mg sodium',
                                            style: GoogleFonts.roboto(
                                              fontSize: 14,
                                              color: const Color(0xFF808080),
                                            ),
                                          ),
                                          Text(
                                            '${scaledFiber.toStringAsFixed(1)}g fiber',
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
      },
    );
  }
}