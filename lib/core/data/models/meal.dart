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
    this.isRecipe = false,
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
      'isRecipe': isRecipe,
      'ingredients': ingredients,
    };
  }

  factory Meal.fromMap(Map<String, dynamic> map) {
    return Meal(
      id: map['id'] as String,
      food: map['food'] as String,
      mealType: map['mealType'] as String,
      calories: (map['calories'] as num?)?.toDouble() ?? 0.0,
      protein: (map['protein'] as num?)?.toDouble() ?? 0.0,
      carbs: (map['carbs'] as num?)?.toDouble() ?? 0.0,
      fat: (map['fat'] as num?)?.toDouble() ?? 0.0,
      sodium: (map['sodium'] as num?)?.toDouble() ?? 0.0,
      fiber: (map['fiber'] as num?)?.toDouble() ?? 0.0,
      timestamp: map['timestamp'] as int? ?? 0,
      servings: (map['servings'] as num?)?.toDouble() ?? 1.0,
      isRecipe: map['isRecipe'] as bool? ?? false,
      ingredients: map['ingredients'] != null ? List<Map<String, dynamic>>.from(map['ingredients']) : null,
    );
  }
}