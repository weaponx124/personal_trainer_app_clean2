import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'package:personal_trainer_app_clean/core/data/models/recipe.dart';

class RecipeRepository {
  static const String _recipesKey = 'recipes';

  Future<List<Recipe>> getRecipes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recipesJson = prefs.getString(_recipesKey);
      print('Recipes JSON from SharedPreferences: $recipesJson');
      if (recipesJson == null) return [];
      final recipesList = jsonDecode(recipesJson) as List<dynamic>;
      final recipes = recipesList.map((recipe) => Recipe.fromMap(recipe as Map<String, dynamic>)).toList();
      print('Loaded recipes: ${recipes.map((r) => r.toMap()).toList()}');
      return recipes;
    } catch (e, stackTrace) {
      print('Error loading recipes: $e');
      print('Stack trace: $stackTrace');
      // Clear recipes to prevent future errors
      await clearRecipes();
      return [];
    }
  }

  Future<void> addRecipe(Map<String, dynamic> recipeMap) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recipes = await getRecipes();
      final recipe = Recipe(
        id: Uuid().v4(),
        name: recipeMap['name'] as String,
        calories: (recipeMap['calories'] as num).toDouble(),
        protein: (recipeMap['protein'] as num).toDouble(),
        carbs: (recipeMap['carbs'] as num).toDouble(),
        fat: (recipeMap['fat'] as num).toDouble(),
        sodium: (recipeMap['sodium'] as num).toDouble(),
        fiber: (recipeMap['fiber'] as num).toDouble(),
        ingredients: (recipeMap['ingredients'] as List<dynamic>).cast<Map<String, dynamic>>(),
      );
      recipes.add(recipe);
      print('Adding recipe: ${recipe.toMap()}');
      print('Updated recipes list: ${recipes.map((r) => r.toMap()).toList()}');
      await prefs.setString(_recipesKey, jsonEncode(recipes.map((r) => r.toMap()).toList()));
      print('Saved recipes to SharedPreferences: ${prefs.getString(_recipesKey)}');
    } catch (e, stackTrace) {
      print('Error saving recipe: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to save recipe: $e');
    }
  }

  Future<void> deleteRecipe(String recipeId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recipes = await getRecipes();
      final updatedRecipes = recipes.where((r) => r.id != recipeId).toList();
      await prefs.setString(_recipesKey, jsonEncode(updatedRecipes.map((r) => r.toMap()).toList()));
      print('Deleted recipe with ID: $recipeId');
    } catch (e, stackTrace) {
      print('Error deleting recipe: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to delete recipe: $e');
    }
  }

  Future<void> clearRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recipesKey);
    print('Cleared all recipes from SharedPreferences');
  }
}