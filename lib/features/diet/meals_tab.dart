import 'package:flutter/material.dart';
import './diet_screen_logic.dart';
import './widgets/meal_log.dart';
import './diet_profile.dart'; // Added import
import '../../core/data/models/meal.dart';

class MealsTab extends StatelessWidget {
  final DietScreenLogic logic;

  const MealsTab({super.key, required this.logic});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DietProfile>(
      valueListenable: logic.dietProfile,
      builder: (context, profile, _) {
        return ValueListenableBuilder<List<Meal>>(
          valueListenable: logic.meals,
          builder: (context, meals, child) {
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
                            'Daily Goals (${profile.name})',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Protein: ${logic.loggedProtein.toStringAsFixed(1)} / ${profile.proteinGrams.toStringAsFixed(1)}g'),
                              Text('Carbs: ${logic.loggedCarbs.toStringAsFixed(1)} / ${profile.carbsGrams.toStringAsFixed(1)}g'),
                              Text('Fat: ${logic.loggedFat.toStringAsFixed(1)} / ${profile.fatGrams.toStringAsFixed(1)}g'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: MealLog(
                    meals: meals,
                    onAddCustomFood: logic.addCustomFood,
                    onAddRecipe: logic.addRecipe,
                    onAddMeal: () => logic.addMeal(context),
                    onEdit: logic.editMeal,
                    onDelete: logic.deleteMeal,
                    selectedMealType: logic.selectedMealType,
                    onMealTypeChanged: logic.setMealType,
                    selectedDate: logic.selectedDate,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}