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

  // For SharedPreferences serialization (JSON)
  factory CustomFood.fromJson(Map<String, dynamic> json) {
    return CustomFood(
      id: json['id'] as String? ?? 'unknown_id',
      name: json['name'] as String? ?? 'Unknown Food',
      calories: (json['calories'] as num?)?.toDouble() ?? 0.0,
      protein: (json['protein'] as num?)?.toDouble() ?? 0.0,
      carbs: (json['carbs'] as num?)?.toDouble() ?? 0.0,
      fat: (json['fat'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
  }

  // For database serialization (Map)
  factory CustomFood.fromMap(Map<String, dynamic> map) {
    return CustomFood(
      id: map['id'] as String? ?? 'unknown_id',
      name: map['name'] as String? ?? 'Unknown Food',
      calories: (map['calories'] as num?)?.toDouble() ?? 0.0,
      protein: (map['protein'] as num?)?.toDouble() ?? 0.0,
      carbs: (map['carbs'] as num?)?.toDouble() ?? 0.0,
      fat: (map['fat'] as num?)?.toDouble() ?? 0.0,
    );
  }

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
}