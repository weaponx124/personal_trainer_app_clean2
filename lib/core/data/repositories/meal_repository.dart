import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'package:personal_trainer_app_clean/core/data/models/meal.dart';

class MealRepository {
  static const String _mealsKey = 'meals';

  Future<List<Meal>> getMeals() async {
    final prefs = await SharedPreferences.getInstance();
    final mealsJson = prefs.getString(_mealsKey);
    if (mealsJson == null) return [];
    final mealsList = jsonDecode(mealsJson) as List<dynamic>;

    // Filter out invalid meals (those with null required fields)
    final validMeals = <Meal>[];
    final invalidMeals = <Map<String, dynamic>>[];
    for (var meal in mealsList) {
      if (meal == null) {
        invalidMeals.add(meal);
        continue;
      }
      final mealMap = meal as Map<String, dynamic>;
      // Check for null required fields
      if (mealMap['food'] == null || mealMap['mealType'] == null) {
        invalidMeals.add(mealMap);
        continue;
      }
      final mealObject = Meal.fromMap(mealMap);
      validMeals.add(mealObject);
    }

    // If there were invalid meals, save the cleaned-up list back to SharedPreferences
    if (invalidMeals.isNotEmpty) {
      print('Found ${invalidMeals.length} invalid meals. Cleaning up SharedPreferences.');
      await prefs.setString(_mealsKey, jsonEncode(validMeals.map((m) => m.toMap()).toList()));
    }

    return validMeals;
  }

  Future<void> insertMeal(Meal meal) async {
    // Validate required fields before saving
    if (meal.food.isEmpty) throw Exception('Meal food cannot be empty');
    if (meal.mealType.isEmpty) throw Exception('Meal mealType cannot be empty');

    final prefs = await SharedPreferences.getInstance();
    final meals = await getMeals();
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
    meals.add(mealWithId);
    await prefs.setString(_mealsKey, jsonEncode(meals.map((m) => m.toMap()).toList()));
    print('Inserted meal: ${mealWithId.toMap()}');
  }

  Future<void> deleteMeal(String mealId) async {
    final prefs = await SharedPreferences.getInstance();
    final meals = await getMeals();
    final updatedMeals = meals.where((m) => m.id != mealId).toList();
    await prefs.setString(_mealsKey, jsonEncode(updatedMeals.map((m) => m.toMap()).toList()));
    print('Deleted meal with ID: $mealId');
  }

  Future<void> clearMeals() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_mealsKey);
    print('Cleared all meals from SharedPreferences');
  }
}