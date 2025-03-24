import 'package:personal_trainer_app_clean/core/data/models/meal.dart';
import 'package:personal_trainer_app_clean/core/services/database_service.dart';
import 'package:personal_trainer_app_clean/core/utils/locator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';

class MealRepository {
  final DatabaseService _databaseService = getIt<DatabaseService>();

  Future<List<Meal>> getMeals() async {
    try {
      return await _databaseService.getMeals();
    } catch (e) {
      print('Error loading meals: $e');
      return [];
    }
  }

  Future<void> insertMeal(Meal meal) async {
    // Validate required fields before saving
    if (meal.food.isEmpty) throw Exception('Meal food cannot be empty');
    if (meal.mealType.isEmpty) throw Exception('Meal mealType cannot be empty');

    final mealWithId = Meal(
      id: Uuid().v4(),
      food: meal.food,
      mealType: meal.mealType,
      calories: meal.calories,
      protein: meal.protein,
      carbs: meal.carbs,
      fat: meal.fat,
      sodium: meal.sodium,
      fiber: meal.fiber,
      timestamp: meal.timestamp,
      servings: meal.servings,
      isRecipe: meal.isRecipe,
      ingredients: meal.ingredients,
    );

    try {
      await _databaseService.insertMeal(mealWithId);
    } catch (e) {
      print('Error inserting meal: $e');
      throw Exception('Failed to insert meal: $e');
    }
  }

  Future<void> deleteMeal(String mealId) async {
    try {
      await _databaseService.deleteMeal(mealId);
    } catch (e) {
      print('Error deleting meal: $e');
      throw Exception('Failed to delete meal: $e');
    }
  }

  Future<void> clearMeals() async {
    try {
      await _databaseService.clearMeals();
    } catch (e) {
      print('Error clearing meals: $e');
      throw Exception('Failed to clear meals: $e');
    }
  }

  // Migrate existing data from SharedPreferences to SQLite (one-time operation)
  Future<void> migrateFromSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mealsJson = prefs.getString('meals') ?? '[]';
      final List<dynamic> mealsList = jsonDecode(mealsJson);
      final meals = mealsList.map((data) => Meal.fromMap(data)).toList();

      for (var meal in meals) {
        await _databaseService.insertMeal(meal);
      }
      print('MealRepository: Migrated ${meals.length} meals from SharedPreferences to SQLite.');

      // Clear SharedPreferences after migration
      await prefs.remove('meals');
    } catch (e) {
      print('Error migrating meals from SharedPreferences: $e');
    }
  }
}