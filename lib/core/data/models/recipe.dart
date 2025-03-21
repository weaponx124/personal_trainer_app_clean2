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
      'ingredients': ingredients,
    };
  }

  factory Recipe.fromMap(Map<String, dynamic> map) {
    // Provide default values for required String fields if they are null
    final String id = map['id'] as String? ?? 'unknown_id';
    final String name = map['name'] as String? ?? 'Unknown Recipe';

    // Log warnings if any required field is null
    if (map['id'] == null) print('Warning: Recipe map has null id: $map');
    if (map['name'] == null) print('Warning: Recipe map has null name: $map');

    return Recipe(
      id: id,
      name: name,
      calories: (map['calories'] as num?)?.toDouble() ?? 0.0,
      protein: (map['protein'] as num?)?.toDouble() ?? 0.0,
      carbs: (map['carbs'] as num?)?.toDouble() ?? 0.0,
      fat: (map['fat'] as num?)?.toDouble() ?? 0.0,
      sodium: (map['sodium'] as num?)?.toDouble() ?? 0.0,
      fiber: (map['fiber'] as num?)?.toDouble() ?? 0.0,
      ingredients: (map['ingredients'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [],
    );
  }
}