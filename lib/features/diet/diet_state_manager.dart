import 'package:flutter/material.dart';
import 'package:personal_trainer_app_clean/core/data/models/meal.dart';
import 'package:personal_trainer_app_clean/core/data/models/recipe.dart';
import 'package:personal_trainer_app_clean/core/data/models/custom_food.dart';
import 'package:personal_trainer_app_clean/core/data/models/shopping_list_item.dart'; // Added import
import 'package:personal_trainer_app_clean/features/diet/diet_profile.dart';

class DietStateManager {
  final ValueNotifier<List<Meal>> meals = ValueNotifier([]);
  final ValueNotifier<List<Recipe>> recipes = ValueNotifier([]);
  final ValueNotifier<List<ShoppingListItem>> shoppingList = ValueNotifier([]);
  List<CustomFood> customFoods = [];
  List<Map<String, dynamic>> allFoods = [];
  DateTime _selectedDate = DateTime.now();
  String selectedMealType = 'Breakfast';
  final ValueNotifier<DietProfile> dietProfile = ValueNotifier(DietProfile.profiles[0]);
  int? customCalories;
  final ValueNotifier<List<String>> mealNames = ValueNotifier(['Breakfast', 'Lunch', 'Dinner']);

  DietStateManager() {
    // Normalize selectedDate on initialization
    _selectedDate = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    meals.addListener(() {
      print('DietStateManager: meals value changed, new count: ${meals.value.length}');
    });
  }

  DateTime get selectedDate => _selectedDate;

  set selectedDate(DateTime date) {
    _selectedDate = DateTime(date.year, date.month, date.day);
    print('DietStateManager: Selected date set to ${_selectedDate.toString()}');
  }

  final List<Map<String, dynamic>> foodDatabase = const [
    {
      'food': 'Chicken Breast',
      'measurement': 'oz',
      'quantityPerServing': 4.0, // 1 serving = 4 oz
      'calories': 165.0,
      'protein': 31.0,
      'carbs': 0.0,
      'fat': 3.6,
      'sodium': 74.0,
      'fiber': 0.0,
      'servings': 1.0,
      'isRecipe': false
    },
    {
      'food': 'Broccoli',
      'measurement': 'cup',
      'quantityPerServing': 1.0, // 1 serving = 1 cup
      'calories': 35.0,
      'protein': 3.0,
      'carbs': 7.0,
      'fat': 0.4,
      'sodium': 33.0,
      'fiber': 3.0,
      'servings': 1.0,
      'isRecipe': false
    },
    {
      'food': 'Avocado',
      'measurement': 'medium',
      'quantityPerServing': 1.0, // 1 serving = 1 medium avocado
      'calories': 160.0,
      'protein': 2.0,
      'carbs': 9.0,
      'fat': 15.0,
      'sodium': 7.0,
      'fiber': 7.0,
      'servings': 1.0,
      'isRecipe': false
    },
  ];

  void initializeAllFoods(List<CustomFood> customFoods) {
    allFoods = List.from(foodDatabase);
    for (var customFood in customFoods) {
      allFoods.add({
        'food': customFood.name,
        'measurement': customFood.servingSizeUnit ?? 'serving',
        'quantityPerServing': customFood.quantityPerServing,
        'calories': customFood.calories,
        'protein': customFood.protein,
        'carbs': customFood.carbs,
        'fat': customFood.fat,
        'sodium': customFood.sodium,
        'fiber': customFood.fiber,
        'servings': 1.0,
        'isRecipe': false,
      });
    }
    print('Initialized allFoods with ${allFoods.length} items: $allFoods');
  }

  void resetData() {
    meals.value = [];
    recipes.value = [];
    shoppingList.value = [];
    print('DietStateManager: resetData called, meals count: ${meals.value.length}');
  }

  List<Meal> getMealsForDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day).millisecondsSinceEpoch;
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59).millisecondsSinceEpoch;
    print('DietStateManager: Getting meals for date ${date.toString()}, start: $startOfDay, end: $endOfDay');
    final filteredMeals = meals.value.where((meal) {
      print('DietStateManager: Checking meal timestamp ${meal.timestamp} for meal: ${meal.toJson()}');
      return meal.timestamp >= startOfDay && meal.timestamp <= endOfDay;
    }).toList();
    print('DietStateManager: Found ${filteredMeals.length} meals for date: ${filteredMeals.map((m) => m.toJson()).toList()}');
    return filteredMeals;
  }

  double getLoggedProtein() {
    final protein = getMealsForDate(selectedDate)
        .fold<double>(0.0, (sum, meal) => sum + (meal.protein * meal.servings));
    print('DietStateManager: Logged protein: $protein');
    return protein;
  }

  double getLoggedCarbs() {
    final carbs = getMealsForDate(selectedDate)
        .fold<double>(0.0, (sum, meal) => sum + (meal.carbs * meal.servings));
    print('DietStateManager: Logged carbs: $carbs');
    return carbs;
  }

  double getLoggedFat() {
    final fat = getMealsForDate(selectedDate)
        .fold<double>(0.0, (sum, meal) => sum + (meal.fat * meal.servings));
    print('DietStateManager: Logged fat: $fat');
    return fat;
  }

  int getEffectiveCalories() => customCalories ?? dietProfile.value.defaultCalories;

  void dispose() {
    meals.dispose();
    recipes.dispose();
    shoppingList.dispose();
    dietProfile.dispose();
    mealNames.dispose();
  }
}