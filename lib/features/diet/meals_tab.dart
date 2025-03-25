import 'package:flutter/material.dart';
import './diet_screen_logic.dart';
import './widgets/meal_log.dart';

class MealsTab extends StatelessWidget {
  final DietScreenLogic logic;

  const MealsTab({super.key, required this.logic});

  @override
  Widget build(BuildContext context) {
    return MealLog(
      meals: logic.meals,
      onAddCustomFood: logic.addCustomFood,
      onAddRecipe: logic.addRecipe,
      onAddMeal: () => logic.addMeal(context), // Wrap to match VoidCallback
      onEdit: logic.editMeal,
      onDelete: logic.deleteMeal,
      selectedMealType: logic.selectedMealType,
      onMealTypeChanged: logic.setMealType,
      selectedDate: logic.selectedDate,
    );
  }
}