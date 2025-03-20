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
    return mealsList.map((meal) {
      if (meal == null) return null;
      return Meal.fromMap(meal as Map<String, dynamic>);
    }).whereType<Meal>().toList();
  }

  Future<void> insertMeal(Meal meal) async {
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
}