class CustomFood {
  final String id;
  final String name;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  CustomFood({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
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
    );
  }
}