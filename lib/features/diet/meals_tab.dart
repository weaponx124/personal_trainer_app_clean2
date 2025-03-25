import 'package:flutter/material.dart';
import './diet_screen_logic.dart';
import './widgets/meal_log.dart';
import '../../core/data/models/meal.dart'; // Added import

class MealsTab extends StatelessWidget {
  final DietScreenLogic logic;

  const MealsTab({super.key, required this.logic});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Meal>>(
      valueListenable: logic.meals,
      builder: (context, meals, child) {
        return MealLog(
          meals: meals,
          onAddCustomFood: logic.addCustomFood,
          onAddRecipe: logic.addRecipe,
          onAddMeal: () => logic.addMeal(context),
          onEdit: logic.editMeal,
          onDelete: logic.deleteMeal,
          selectedMealType: logic.selectedMealType,
          onMealTypeChanged: logic.setMealType,
          selectedDate: logic.selectedDate,
        );
      },
    );
  }
}