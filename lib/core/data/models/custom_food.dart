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
  final String? servingSizeUnit; // New field for serving size unit

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
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory CustomFood.fromJson(Map<String, dynamic> json) => CustomFood.fromMap(json);
}