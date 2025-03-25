import 'package:flutter/material.dart';
import './diet_screen_logic.dart';
import './widgets/saved_recipes.dart';

class RecipesTab extends StatelessWidget {
  final DietScreenLogic logic;

  const RecipesTab({super.key, required this.logic});

  @override
  Widget build(BuildContext context) {
    return SavedRecipes(
      recipes: logic.recipes,
      onDelete: logic.deleteRecipe,
      onAddRecipe: logic.addRecipe,
    );
  }
}