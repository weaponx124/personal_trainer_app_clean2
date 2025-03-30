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

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'] as String? ?? '',
      food: json['food'] as String? ?? '',
      mealType: json['mealType'] as String? ?? '',
      calories: (json['calories'] as num?)?.toDouble() ?? 0.0,
      protein: (json['protein'] as num?)?.toDouble() ?? 0.0,
      carbs: (json['carbs'] as num?)?.toDouble() ?? 0.0,
      fat: (json['fat'] as num?)?.toDouble() ?? 0.0,
      sodium: (json['sodium'] as num?)?.toDouble() ?? 0.0,
      fiber: (json['fiber'] as num?)?.toDouble() ?? 0.0,
      timestamp: (json['timestamp'] as num?)?.toInt() ?? 0,
      servings: (json['servings'] as num?)?.toDouble() ?? 1.0,
      isRecipe: (json['isRecipe'] as bool?) ?? false,
      ingredients: (json['ingredients'] as List<dynamic>?)
          ?.map((item) => Map<String, dynamic>.from(item as Map))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
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
      'isRecipe': isRecipe,
      'ingredients': ingredients,
    };
  }

  factory Meal.fromMap(Map<String, dynamic> map) {
    return Meal(
      id: map['id'] as String? ?? '',
      food: map['food'] as String? ?? '',
      mealType: map['mealType'] as String? ?? '',
      calories: (map['calories'] as num?)?.toDouble() ?? 0.0,
      protein: (map['protein'] as num?)?.toDouble() ?? 0.0,
      carbs: (map['carbs'] as num?)?.toDouble() ?? 0.0,
      fat: (map['fat'] as num?)?.toDouble() ?? 0.0,
      sodium: (map['sodium'] as num?)?.toDouble() ?? 0.0,
      fiber: (map['fiber'] as num?)?.toDouble() ?? 0.0,
      timestamp: (map['timestamp'] as num?)?.toInt() ?? 0,
      servings: (map['servings'] as num?)?.toDouble() ?? 1.0,
      isRecipe: (map['isRecipe'] == 1 || map['isRecipe'] == true),
      ingredients: (map['ingredients'] != null && map['ingredients'] is String)
          ? (jsonDecode(map['ingredients']) as List<dynamic>)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList()
          : null,
    );
  }

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
    };
  }
}