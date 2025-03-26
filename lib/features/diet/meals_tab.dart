import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import './diet_screen_logic.dart';
import './widgets/meal_log.dart';
import './diet_profile.dart';
import '../../core/data/models/meal.dart';

class MealsTab extends StatelessWidget {
  final DietScreenLogic logic;

  const MealsTab({super.key, required this.logic});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder<DietProfile>(
        valueListenable: logic.dietProfile,
        builder: (context, profile, _) {
          return ValueListenableBuilder<List<Meal>>(
            valueListenable: logic.meals,
            builder: (context, meals, _) {
              final calories = logic.effectiveCalories;
              final proteinProgress = logic.loggedProtein / profile.proteinGrams(calories);
              final carbsProgress = logic.loggedCarbs / profile.carbsGrams(calories);
              final fatProgress = logic.loggedFat / profile.fatGrams(calories);

              print('Protein: ${logic.loggedProtein} / ${profile.proteinGrams(calories)} = $proteinProgress');
              print('Carbs: ${logic.loggedCarbs} / ${profile.carbsGrams(calories)} = $carbsProgress');
              print('Fat: ${logic.loggedFat} / ${profile.fatGrams(calories)} = $fatProgress');

              final mealGroups = <String, List<Meal>>{};
              for (var meal in meals) {
                mealGroups.putIfAbsent(meal.mealType, () => []).add(meal);
              }

              return Column(
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
                                        'Protein: ${logic.loggedProtein.toStringAsFixed(1)} / ${profile.proteinGrams(calories).toStringAsFixed(1)}g',
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
                                        'Carbs: ${logic.loggedCarbs.toStringAsFixed(1)} / ${profile.carbsGrams(calories).toStringAsFixed(1)}g',
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
                                        'Fat: ${logic.loggedFat.toStringAsFixed(1)} / ${profile.fatGrams(calories).toStringAsFixed(1)}g',
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
                          onPressed: logic.addCustomFood,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Add Custom Food'),
                        ),
                        ElevatedButton(
                          onPressed: logic.addRecipe,
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
                    child: ListView(
                      children: logic.mealNames.map((mealName) {
                        final groupMeals = mealGroups[mealName] ?? [];
                        return ExpansionTile(
                          title: Text(
                            '$mealName (${groupMeals.length})',
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              color: const Color(0xFF1C2526),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          children: groupMeals.map((meal) {
                            return ListTile(
                              title: Text(
                                meal.food,
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
                                    icon: const Icon(Icons.edit, color: Color(0xFF1C2526)),
                                    onPressed: () => logic.editMeal(meal),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Color(0xFF1C2526)),
                                    onPressed: () => logic.deleteMeal(meal.id),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}