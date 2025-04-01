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
  final String? servingSizeUnit; // New field for user-specified serving size unit

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
    this.servingSizeUnit,
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
      'isRecipe': isRecipe ? 1 : 0,
      'ingredients': ingredients != null ? jsonEncode(ingredients) : null,
      'servingSizeUnit': servingSizeUnit,
    };
  }

  factory Meal.fromMap(Map<String, dynamic> map) {
    return Meal(
      id: map['id'] as String,
      food: map['food'] as String,
      mealType: map['mealType'] as String,
      calories: map['calories'] as double,
      protein: map['protein'] as double,
      carbs: map['carbs'] as double,
      fat: map['fat'] as double,
      sodium: map['sodium'] as double,
      fiber: map['fiber'] as double,
      timestamp: map['timestamp'] as int,
      servings: map['servings'] as double,
      isRecipe: (map['isRecipe'] as int) == 1,
      ingredients: map['ingredients'] != null
          ? (jsonDecode(map['ingredients']) as List<dynamic>)
          .cast<Map<String, dynamic>>()
          : null,
      servingSizeUnit: map['servingSizeUnit'] as String?,
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory Meal.fromJson(Map<String, dynamic> json) => Meal.fromMap(json);

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
    String? servingSizeUnit,
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
      servingSizeUnit: servingSizeUnit ?? this.servingSizeUnit,
    );
  }
}