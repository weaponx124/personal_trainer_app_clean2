import 'package:flutter/material.dart'; // Added for DefaultAssetBundle
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'package:personal_trainer_app_clean/core/data/models/meal.dart';
import 'package:personal_trainer_app_clean/core/data/models/recipe.dart';

class DietService {
  Future<List<Map<String, dynamic>>> loadFoodDatabase(BuildContext context) async {
    final foodDatabaseJson = await DefaultAssetBundle.of(context).loadString('assets/food_database.json');
    final foodDatabase = jsonDecode(foodDatabaseJson) as List<dynamic>;
    return foodDatabase.cast<Map<String, dynamic>>();
  }

  List<Map<String, dynamic>> generateRecommendations(
      List<Map<String, dynamic>> foodDatabase, Map<String, dynamic> preferences) {
    final goal = preferences['goal'] as String? ?? 'maintain';
    final dietaryPreference = preferences['dietaryPreference'] as String? ?? 'none';
    final macroGoals = preferences['macroGoals'] as Map<String, dynamic>? ?? {'protein': 25, 'carbs': 50, 'fat': 25};
    final allergies = preferences['allergies'] as List<dynamic>? ?? [];

    List<Map<String, dynamic>> recommendations = [];
    for (var food in foodDatabase) {
      final suitableFor = food['suitable_for'] as List<dynamic>? ?? [];
      final foodAllergies = food['allergies'] as List<dynamic>? ?? [];

      // Check for allergies
      bool hasAllergy = false;
      for (var allergy in allergies) {
        if (foodAllergies.contains(allergy)) {
          hasAllergy = true;
          break;
        }
      }
      if (hasAllergy) continue;

      // Check dietary preferences
      if (dietaryPreference != 'none' && !suitableFor.contains(dietaryPreference)) continue;

      // Prioritize based on goal
      bool isRecommended = false;
      if (goal == 'lose' && suitableFor.contains('low-carb')) {
        isRecommended = true;
      } else if (goal == 'gain' && suitableFor.contains('high-protein')) {
        isRecommended = true;
      } else if (goal == 'maintain' && suitableFor.contains('balanced')) {
        isRecommended = true;
      }

      if (isRecommended) {
        recommendations.add(food);
      }
    }

    // Sort by relevance to macro goals (e.g., prioritize high protein if protein goal is high)
    final proteinGoal = macroGoals['protein'] as int? ?? 25;
    recommendations.sort((a, b) {
      final aProtein = a['protein'] as num? ?? 0;
      final bProtein = b['protein'] as num? ?? 0;
      if (proteinGoal > 30) {
        return bProtein.compareTo(aProtein); // Prioritize high protein
      }
      return 0;
    });

    return recommendations.take(5).toList();
  }

  List<Map<String, dynamic>> generateShoppingList(List<Meal> meals) {
    final now = DateTime.now();
    final startOfPeriod = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 7)).millisecondsSinceEpoch;
    final endOfPeriod = DateTime(now.year, now.month, now.day, 23, 59, 59).millisecondsSinceEpoch;

    final mealsInPeriod = meals.where((meal) {
      final timestamp = meal.timestamp;
      return timestamp >= startOfPeriod && timestamp <= endOfPeriod;
    }).toList();

    // Aggregate ingredients
    final Map<String, double> ingredientQuantities = {};
    for (var meal in mealsInPeriod) {
      final servings = meal.servings;

      if (meal.isRecipe) {
        // For recipes, include all ingredients
        final ingredients = meal.ingredients ?? [];
        for (var ingredient in ingredients) {
          final foodName = ingredient['name'] as String;
          final ingredientServings = (ingredient['servings'] as double) * servings;
          ingredientQuantities[foodName] = (ingredientQuantities[foodName] ?? 0.0) + ingredientServings;
        }
      } else {
        // For single foods
        final foodName = meal.food;
        ingredientQuantities[foodName] = (ingredientQuantities[foodName] ?? 0.0) + servings;
      }
    }

    // Convert to shopping list format
    return ingredientQuantities.entries.map((entry) {
      return {
        'id': Uuid().v4(),
        'name': entry.key,
        'quantity': entry.value,
        'checked': false,
      };
    }).toList();
  }
}