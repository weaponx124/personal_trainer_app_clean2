import 'dart:convert';

class Meal {
  final String id;
  final String food;
  final String mealType;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double sodium;
  final double fiber;
  final int timestamp;
  final double servings;
  final bool isRecipe;
  final List<Map<String, dynamic>>? ingredients;

  Meal({
    required this.id,
    required this.food,
    required this.mealType,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.sodium,
    required this.fiber,
    required this.timestamp,
    required this.servings,
    required this.isRecipe,
    this.ingredients,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'food': food,
      'mealType': mealType,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'sodium': sodium,
      'fiber': fiber,
      'timestamp': timestamp,
      'servings': servings,
      'isRecipe': isRecipe ? 1 : 0, // Convert bool to int
      'ingredients': ingredients != null ? jsonEncode(ingredients) : null, // Serialize to JSON string
    };
  }

  factory Meal.fromMap(Map<String, dynamic> map) {
    // Provide default values for required String fields if they are null
    final String id = map['id'] as String? ?? 'unknown_id';
    final String food = map['food'] as String? ?? 'Unknown Food';
    final String mealType = map['mealType'] as String? ?? 'Unknown Meal Type';

    // Log warnings if any required field is null
    if (map['id'] == null) print('Warning: Meal map has null id: $map');
    if (map['food'] == null) print('Warning: Meal map has null food: $map');
    if (map['mealType'] == null) print('Warning: Meal map has null mealType: $map');

    // Handle isRecipe as either bool (from SharedPreferences) or int (from SQLite)
    bool isRecipeValue;
    if (map['isRecipe'] is bool) {
      isRecipeValue = map['isRecipe'] as bool;
    } else {
      isRecipeValue = (map['isRecipe'] as int? ?? 0) == 1;
    }

    // Handle ingredients as either List<dynamic> (from SharedPreferences) or JSON string (from SQLite)
    List<Map<String, dynamic>>? ingredientsValue;
    if (map['ingredients'] is String) {
      ingredientsValue = (jsonDecode(map['ingredients'] as String) as List<dynamic>)
          .map((item) => item as Map<String, dynamic>)
          .toList();
    } else {
      ingredientsValue = (map['ingredients'] as List<dynamic>?)
          ?.map((item) => item as Map<String, dynamic>)
          .toList();
    }

    return Meal(
      id: id,
      food: food,
      mealType: mealType,
      calories: (map['calories'] as num?)?.toDouble() ?? 0.0,
      protein: (map['protein'] as num?)?.toDouble() ?? 0.0,
      carbs: (map['carbs'] as num?)?.toDouble() ?? 0.0,
      fat: (map['fat'] as num?)?.toDouble() ?? 0.0,
      sodium: (map['sodium'] as num?)?.toDouble() ?? 0.0,
      fiber: (map['fiber'] as num?)?.toDouble() ?? 0.0,
      timestamp: map['timestamp'] as int? ?? 0,
      servings: (map['servings'] as num?)?.toDouble() ?? 1.0,
      isRecipe: isRecipeValue,
      ingredients: ingredientsValue,
    );
  }

  // Added for SharedPreferences JSON compatibility
  Map<String, dynamic> toJson() => toMap();

  factory Meal.fromJson(Map<String, dynamic> json) => Meal.fromMap(json);

  // Add copyWith method
  Meal copyWith({
    String? id,
    String? food,
    String? mealType,
    double? calories,
    double? protein,
    double? carbs,
    double? fat,
    double? sodium,
    double? fiber,
    int? timestamp,
    double? servings,
    bool? isRecipe,
    List<Map<String, dynamic>>? ingredients,
  }) {
    return Meal(
      id: id ?? this.id,
      food: food ?? this.food,
      mealType: mealType ?? this.mealType,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      sodium: sodium ?? this.sodium,
      fiber: fiber ?? this.fiber,
      timestamp: timestamp ?? this.timestamp,
      servings: servings ?? this.servings,
      isRecipe: isRecipe ?? this.isRecipe,
      ingredients: ingredients ?? this.ingredients,
    );
  }
}