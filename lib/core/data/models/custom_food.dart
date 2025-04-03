import 'dart:convert';

class CustomFood {
  final String id;
  final String name;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double sodium;
  final double fiber;
  final String? servingSizeUnit;
  final double quantityPerServing; // New field for quantity per serving

  CustomFood({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.sodium,
    required this.fiber,
    this.servingSizeUnit,
    this.quantityPerServing = 1.0, // Default to 1 unit per serving
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
      'servingSizeUnit': servingSizeUnit,
      'quantityPerServing': quantityPerServing,
    };
  }

  factory CustomFood.fromMap(Map<String, dynamic> map) {
    return CustomFood(
      id: map['id'] as String,
      name: map['name'] as String,
      calories: map['calories'] as double,
      protein: map['protein'] as double,
      carbs: map['carbs'] as double,
      fat: map['fat'] as double,
      sodium: map['sodium'] as double,
      fiber: map['fiber'] as double,
      servingSizeUnit: map['servingSizeUnit'] as String?,
      quantityPerServing: map['quantityPerServing'] as double? ?? 1.0,
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory CustomFood.fromJson(Map<String, dynamic> json) => CustomFood.fromMap(json);
}