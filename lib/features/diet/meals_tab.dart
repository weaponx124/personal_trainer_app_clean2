import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import './diet_screen_logic.dart';
import './diet_profile.dart';
import '../../core/data/models/meal.dart';
import '../../core/data/models/recipe.dart';

class MealsTab extends StatefulWidget {
  final DietScreenLogic logic;

  const MealsTab({super.key, required this.logic});

  @override
  State<MealsTab> createState() => _MealsTabState();
}

class _MealsTabState extends State<MealsTab> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DietProfile>(
      valueListenable: widget.logic.dietProfile,
      builder: (context, profile, _) {
        return ValueListenableBuilder<List<Meal>>(
          valueListenable: widget.logic.meals,
          builder: (context, meals, _) {
            final calories = widget.logic.effectiveCalories;
            final proteinProgress = widget.logic.loggedProtein / profile.proteinGrams(calories);
            final carbsProgress = widget.logic.loggedCarbs / profile.carbsGrams(calories);
            final fatProgress = widget.logic.loggedFat / profile.fatGrams(calories);

            print('Protein: ${widget.logic.loggedProtein} / ${profile.proteinGrams(calories)} = $proteinProgress');
            print('Carbs: ${widget.logic.loggedCarbs} / ${profile.carbsGrams(calories)} = $carbsProgress');
            print('Fat: ${widget.logic.loggedFat} / ${profile.fatGrams(calories)} = $fatProgress');

            // Get meals for the selected date
            final dateMeals = widget.logic.getMealsForDate(widget.logic.selectedDate);
            final mealGroups = <String, List<Meal>>{};
            for (var meal in dateMeals) {
              mealGroups.putIfAbsent(meal.mealType, () => []).add(meal);
            }

            return Container(
              color: Colors.grey[200], // Apply grey background
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile.scripture,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontStyle: FontStyle.italic,
                                color: const Color(0xFF1C2526),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Daily Goals (${profile.name})',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: const Color(0xFF1C2526),
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
                                        'Protein: ${widget.logic.loggedProtein.toStringAsFixed(1)} / ${profile.proteinGrams(calories).toStringAsFixed(1)}g',
                                        style: const TextStyle(color: Color(0xFF1C2526)),
                                      ),
                                      LinearProgressIndicator(
                                        value: proteinProgress.clamp(0.0, 1.0),
                                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                                        backgroundColor: Colors.grey[300],
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
                                        'Carbs: ${widget.logic.loggedCarbs.toStringAsFixed(1)} / ${profile.carbsGrams(calories).toStringAsFixed(1)}g',
                                        style: const TextStyle(color: Color(0xFF1C2526)),
                                      ),
                                      LinearProgressIndicator(
                                        value: carbsProgress.clamp(0.0, 1.0),
                                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                                        backgroundColor: Colors.grey[300],
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
                                        'Fat: ${widget.logic.loggedFat.toStringAsFixed(1)} / ${profile.fatGrams(calories).toStringAsFixed(1)}g',
                                        style: const TextStyle(color: Color(0xFF1C2526)),
                                      ),
                                      LinearProgressIndicator(
                                        value: fatProgress.clamp(0.0, 1.0),
                                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                                        backgroundColor: Colors.grey[300],
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
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () => widget.logic.addCustomFood(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Add Custom Food'),
                        ),
                        ElevatedButton(
                          onPressed: () => widget.logic.addRecipe(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Create Recipe'),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ValueListenableBuilder<List<String>>(
                      valueListenable: widget.logic.mealNames,
                      builder: (context, mealNames, _) {
                        return ListView(
                          children: mealNames.map((mealName) {
                            final groupMeals = mealGroups[mealName] ?? [];
                            final totalCalories = groupMeals.fold<double>(
                              0.0,
                                  (sum, meal) => sum + (meal.calories * meal.servings),
                            );
                            return ExpansionTile(
                              title: Text(
                                '$mealName (${groupMeals.length})',
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
                                  final recipe = widget.logic.recipes.value.firstWhere(
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
                                  final foodEntry = widget.logic.foodDatabase.firstWhere(
                                        (f) => f['food'] == meal.food,
                                    orElse: () => {'food': meal.food, 'measurement': 'Per serving'},
                                  );
                                  final measurement = foodEntry['measurement'] as String;
                                  displayName = '${meal.food} $measurement';
                                }
                                return ListTile(
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
                                        icon: const Icon(Icons.edit, color: Color(0xFF1C2526)),
                                        onPressed: () => widget.logic.editMeal(context, meal),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Color(0xFF1C2526)),
                                        onPressed: () => widget.logic.deleteMeal(meal.id),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}