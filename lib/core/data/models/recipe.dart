import 'dart:convert';

class Recipe {
  final String id;
  final String name;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double sodium;
  final double fiber;
  final List<Map<String, dynamic>> ingredients;
  final String? servingSizeUnit;

  Recipe({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.sodium,
    required this.fiber,
    required this.ingredients,
    this.servingSizeUnit,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'sodium': sodium,
      'fiber': fiber,
      'ingredients': jsonEncode(ingredients), // Encode ingredients as JSON string
      'servingSizeUnit': servingSizeUnit,
    };
  }

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'] as String,
      name: map['name'] as String,
      calories: map['calories'] as double,
      protein: map['protein'] as double,
      carbs: map['carbs'] as double,
      fat: map['fat'] as double,
      sodium: map['sodium'] as double,
      fiber: map['fiber'] as double,
      ingredients: map['ingredients'] != null
          ? (jsonDecode(map['ingredients']) as List<dynamic>).cast<Map<String, dynamic>>()
          : [],
      servingSizeUnit: map['servingSizeUnit'] as String?,
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory Recipe.fromJson(Map<String, dynamic> json) => Recipe.fromMap(json);

  Recipe copyWith({
    String? id,
    String? name,
    double? calories,
    double? protein,
    double? carbs,
    double? fat,
    double? sodium,
    double? fiber,
    List<Map<String, dynamic>>? ingredients,
    String? servingSizeUnit,
  }) {
    return Recipe(
      id: id ?? this.id,
      name: name ?? this.name,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      sodium: sodium ?? this.sodium,
      fiber: fiber ?? this.fiber,
      ingredients: ingredients ?? this.ingredients,
      servingSizeUnit: servingSizeUnit ?? this.servingSizeUnit,
    );
  }
}