import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'package:personal_trainer_app_clean/core/data/models/recipe.dart';

class RecipeRepository {
  static const String _recipesKey = 'recipes';

  Future<List<Recipe>> getRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    final recipesJson = prefs.getString(_recipesKey);
    if (recipesJson == null) return [];
    final recipesList = jsonDecode(recipesJson) as List<dynamic>;
    return recipesList.map((recipe) {
      if (recipe == null) return null;
      return Recipe.fromMap(recipe as Map<String, dynamic>);
    }).whereType<Recipe>().toList();
  }

  Future<void> addRecipe(Recipe recipe) async {
    final prefs = await SharedPreferences.getInstance();
    final recipes = await getRecipes();
    final recipeWithId = Recipe(
      id: Uuid().v4(),
      name: recipe.name,
      ingredients: recipe.ingredients,
      calories: recipe.calories,
      protein: recipe.protein,
      carbs: recipe.carbs,
      fat: recipe.fat,
      sodium: recipe.sodium,
      fiber: recipe.fiber,
      suitableFor: recipe.suitableFor,
    );
    recipes.add(recipeWithId);
    await prefs.setString(_recipesKey, jsonEncode(recipes.map((r) => r.toMap()).toList()));
    print('Added recipe: ${recipeWithId.toMap()}');
  }

  Future<void> deleteRecipe(String recipeId) async {
    final prefs = await SharedPreferences.getInstance();
    final recipes = await getRecipes();
    final updatedRecipes = recipes.where((r) => r.id != recipeId).toList();
    await prefs.setString(_recipesKey, jsonEncode(updatedRecipes.map((r) => r.toMap()).toList()));
    print('Deleted recipe with ID: $recipeId');
  }
}