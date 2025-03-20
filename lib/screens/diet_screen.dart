import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_trainer_app_clean/database_helper.dart';
import 'package:personal_trainer_app_clean/utils/cross_painter.dart';
import 'dart:convert';

class DietScreen extends StatefulWidget {
  const DietScreen({super.key});

  @override
  _DietScreenState createState() => _DietScreenState();
}

class _DietScreenState extends State<DietScreen> {
  List<Map<String, dynamic>> _meals = [];
  List<Map<String, dynamic>> _foodDatabase = [];
  List<Map<String, dynamic>> _waterIntake = [];
  Map<String, dynamic> _dietPreferences = {};
  double _dailyCalories = 0.0;
  double _dailyProtein = 0.0;
  double _dailyCarbs = 0.0;
  double _dailyFat = 0.0;
  double _dailyWater = 0.0;
  String _selectedMealType = 'Breakfast'; // Options: Breakfast, Lunch, Dinner, Snack
  List<Map<String, dynamic>> _recommendedFoods = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    print('Loading data...');
    // Load meals
    final meals = await DatabaseHelper.getMeals();
    final waterIntake = await DatabaseHelper.getWaterIntake();
    var dietPreferences = await DatabaseHelper.getDietPreferences();

    // Ensure dietPreferences is not null and has default values
    if (dietPreferences == null || dietPreferences.isEmpty) {
      dietPreferences = {
        'goal': 'maintain',
        'dietaryPreference': 'none',
        'calorieGoal': 2000,
        'macroGoals': {'protein': 25, 'carbs': 50, 'fat': 25},
        'allergies': [],
      };
      await DatabaseHelper.setDietPreferences(dietPreferences);
    }

    // Load food database
    final foodDatabaseJson = await DefaultAssetBundle.of(context).loadString('assets/food_database.json');
    final foodDatabase = jsonDecode(foodDatabaseJson) as List<dynamic>;

    // Calculate daily totals with null checks
    double calories = 0.0;
    double protein = 0.0;
    double carbs = 0.0;
    double fat = 0.0;
    double water = 0.0;

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59).millisecondsSinceEpoch;

    for (var meal in meals) {
      final timestamp = meal['timestamp'] as int?;
      if (timestamp == null || timestamp < startOfDay || timestamp > endOfDay) continue;
      calories += (meal['calories'] as num?)?.toDouble() ?? 0.0;
      protein += (meal['protein'] as num?)?.toDouble() ?? 0.0;
      carbs += (meal['carbs'] as num?)?.toDouble() ?? 0.0;
      fat += (meal['fat'] as num?)?.toDouble() ?? 0.0;
    }

    for (var entry in waterIntake) {
      final timestamp = entry['timestamp'] as int?;
      if (timestamp == null || timestamp < startOfDay || timestamp > endOfDay) continue;
      water += (entry['amount'] as num?)?.toDouble() ?? 0.0;
    }

    // Generate food recommendations
    final recommendedFoods = _generateRecommendations(foodDatabase, dietPreferences);

    setState(() {
      _meals = meals;
      _waterIntake = waterIntake;
      _dietPreferences = dietPreferences;
      _foodDatabase = foodDatabase.cast<Map<String, dynamic>>();
      _dailyCalories = calories;
      _dailyProtein = protein;
      _dailyCarbs = carbs;
      _dailyFat = fat;
      _dailyWater = water;
      _recommendedFoods = recommendedFoods;
      print('Data loaded: ${meals.length} meals, ${recommendedFoods.length} recommendations');
    });
  }

  List<Map<String, dynamic>> _generateRecommendations(List<dynamic> foodDatabase, Map<String, dynamic> preferences) {
    final goal = preferences['goal'] as String? ?? 'maintain';
    final dietaryPreference = preferences['dietaryPreference'] as String? ?? 'none';
    final macroGoals = preferences['macroGoals'] as Map<String, dynamic>? ?? {'protein': 25, 'carbs': 50, 'fat': 25};
    final allergies = preferences['allergies'] as List<dynamic>? ?? [];

    // Simple recommendation logic based on goals and preferences
    List<Map<String, dynamic>> recommendations = [];
    for (var food in foodDatabase) {
      final suitableFor = food['suitable_for'] as List<dynamic>? ?? [];
      final foodAllergies = food['allergies'] as List<dynamic>? ?? [];

      // Check for allergies
      bool hasAllergy = false;
      for (var allergy in allergies) {
        if (foodAllergies.contains(allergy)) {
          hasAllergy = true;
          break;
        }
      }
      if (hasAllergy) continue;

      // Check dietary preferences
      if (dietaryPreference != 'none' && !suitableFor.contains(dietaryPreference)) continue;

      // Prioritize based on goal
      bool isRecommended = false;
      if (goal == 'lose' && suitableFor.contains('low-carb')) {
        isRecommended = true;
      } else if (goal == 'gain' && suitableFor.contains('high-protein')) {
        isRecommended = true;
      } else if (goal == 'maintain' && suitableFor.contains('balanced')) {
        isRecommended = true;
      }

      if (isRecommended) {
        recommendations.add(food);
      }
    }

    // Sort by relevance to macro goals (e.g., prioritize high protein if protein goal is high)
    final proteinGoal = macroGoals['protein'] as int? ?? 25;
    recommendations.sort((a, b) {
      final aProtein = a['protein'] as num? ?? 0;
      final bProtein = b['protein'] as num? ?? 0;
      if (proteinGoal > 30) {
        return bProtein.compareTo(aProtein); // Prioritize high protein
      }
      return 0;
    });

    return recommendations.take(5).toList(); // Limit to top 5 recommendations
  }

  Future<void> _addMeal() async {
    String? selectedFood = _foodDatabase.isNotEmpty ? _foodDatabase[0]['name'] as String : null;
    final TextEditingController amountController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Log $_selectedMealType'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                value: selectedFood,
                hint: const Text('Select Food'),
                isExpanded: true,
                items: _foodDatabase.map((food) {
                  return DropdownMenuItem<String>(
                    value: food['name'] as String,
                    child: Text(food['name'] as String),
                  );
                }).toList(),
                onChanged: (value) {
                  setDialogState(() {
                    selectedFood = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount (servings)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (selectedFood != null && amountController.text.isNotEmpty) {
                  Navigator.pop(context, true);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a food and enter servings')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      final servings = double.tryParse(amountController.text) ?? 1.0;
      final food = _foodDatabase.firstWhere((f) => f['name'] == selectedFood);
      final meal = {
        'food': food['name'],
        'mealType': _selectedMealType,
        'calories': (food['calories'] as num?)?.toDouble() ?? 0.0,
        'protein': (food['protein'] as num?)?.toDouble() ?? 0.0,
        'carbs': (food['carbs'] as num?)?.toDouble() ?? 0.0,
        'fat': (food['fat'] as num?)?.toDouble() ?? 0.0,
        'sodium': (food['sodium'] as num?)?.toDouble() ?? 0.0,
        'fiber': (food['fiber'] as num?)?.toDouble() ?? 0.0,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      print('Saving meal: $meal');
      await DatabaseHelper.insertMeal(meal);
      await _loadData();
    }
  }

  Future<void> _addWater() async {
    final TextEditingController amountController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Water Intake'),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Amount (oz)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text) ?? 0.0;
              if (amount > 0) {
                Navigator.pop(context, true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid amount')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == true) {
      final amount = double.tryParse(amountController.text) ?? 0.0;
      await DatabaseHelper.addWaterIntake(amount);
      await _loadData();
    }
  }

  Future<void> _editDietPreferences() async {
    String goal = _dietPreferences['goal'] as String? ?? 'maintain';
    String dietaryPreference = _dietPreferences['dietaryPreference'] as String? ?? 'none';
    final TextEditingController calorieController = TextEditingController(
      text: (_dietPreferences['calorieGoal'] as int? ?? 2000).toString(),
    );
    final TextEditingController proteinController = TextEditingController(
      text: (_dietPreferences['macroGoals']?['protein'] as int? ?? 25).toString(),
    );
    final TextEditingController carbsController = TextEditingController(
      text: (_dietPreferences['macroGoals']?['carbs'] as int? ?? 50).toString(),
    );
    final TextEditingController fatController = TextEditingController(
      text: (_dietPreferences['macroGoals']?['fat'] as int? ?? 25).toString(),
    );
    List<String> allergies = List<String>.from(_dietPreferences['allergies'] as List<dynamic>? ?? []);
    final TextEditingController allergyController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Diet Preferences'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButton<String>(
                  value: goal,
                  isExpanded: true,
                  items: <String>['lose', 'gain', 'maintain'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value.capitalize()),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setDialogState(() {
                      goal = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButton<String>(
                  value: dietaryPreference,
                  isExpanded: true,
                  items: <String>['none', 'vegan', 'vegetarian', 'low-carb', 'high-protein'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value.capitalize()),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setDialogState(() {
                      dietaryPreference = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: calorieController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Daily Calorie Goal',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: proteinController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Protein Goal (%)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: carbsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Carbs Goal (%)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: fatController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Fat Goal (%)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: allergyController,
                  decoration: const InputDecoration(
                    labelText: 'Add Allergy (e.g., peanuts)',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      setDialogState(() {
                        allergies.add(value);
                        allergyController.clear();
                      });
                    }
                  },
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  children: allergies.map((allergy) => Chip(
                    label: Text(allergy),
                    onDeleted: () {
                      setDialogState(() {
                        allergies.remove(allergy);
                      });
                    },
                  )).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final totalMacros = (int.tryParse(proteinController.text) ?? 0) +
                    (int.tryParse(carbsController.text) ?? 0) +
                    (int.tryParse(fatController.text) ?? 0);
                if (totalMacros != 100) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Macro percentages must add up to 100%')),
                  );
                  return;
                }
                Navigator.pop(context, true);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      final updatedPreferences = {
        'goal': goal,
        'dietaryPreference': dietaryPreference,
        'calorieGoal': int.tryParse(calorieController.text) ?? 2000,
        'macroGoals': {
          'protein': int.tryParse(proteinController.text) ?? 25,
          'carbs': int.tryParse(carbsController.text) ?? 50,
          'fat': int.tryParse(fatController.text) ?? 25,
        },
        'allergies': allergies,
      };
      print('Saving diet preferences: $updatedPreferences');
      await DatabaseHelper.setDietPreferences(updatedPreferences);
      await _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diet'),
        backgroundColor: const Color(0xFF1C2526),
        foregroundColor: const Color(0xFFB0B7BF),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [const Color(0xFF87CEEB).withOpacity(0.2), const Color(0xFF1C2526)],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.1,
                child: CustomPaint(
                  painter: CrossPainter(),
                  child: Container(),
                ),
              ),
            ),
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Daily Summary
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      color: const Color(0xFFB0B7BF),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Daily Summary',
                              style: GoogleFonts.oswald(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFB22222),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Calories: ${_dailyCalories.toStringAsFixed(1)} / ${_dietPreferences['calorieGoal'] ?? 2000} kcal',
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                color: const Color(0xFF1C2526),
                              ),
                            ),
                            Text(
                              'Protein: ${_dailyProtein.toStringAsFixed(1)} g',
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                color: const Color(0xFF1C2526),
                              ),
                            ),
                            Text(
                              'Carbs: ${_dailyCarbs.toStringAsFixed(1)} g',
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                color: const Color(0xFF1C2526),
                              ),
                            ),
                            Text(
                              'Fat: ${_dailyFat.toStringAsFixed(1)} g',
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                color: const Color(0xFF1C2526),
                              ),
                            ),
                            Text(
                              'Water: ${_dailyWater.toStringAsFixed(1)} oz',
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                color: const Color(0xFF1C2526),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Diet Preferences
                    ElevatedButton.icon(
                      icon: const Icon(Icons.settings, size: 24),
                      label: const Text('Edit Diet Preferences', style: TextStyle(fontSize: 18)),
                      onPressed: _editDietPreferences,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB22222),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Food Recommendations
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      color: const Color(0xFFB0B7BF),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Recommended Foods',
                              style: GoogleFonts.oswald(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFB22222),
                              ),
                            ),
                            const SizedBox(height: 8),
                            _recommendedFoods.isEmpty
                                ? const Text('No recommendations available.')
                                : Column(
                              children: _recommendedFoods.map((food) => ListTile(
                                title: Text(
                                  food['name'] as String,
                                  style: GoogleFonts.roboto(
                                    fontSize: 16,
                                    color: const Color(0xFF1C2526),
                                  ),
                                ),
                                subtitle: Text(
                                  '${food['calories']} kcal, ${food['protein']}g protein',
                                  style: GoogleFonts.roboto(
                                    fontSize: 14,
                                    color: const Color(0xFF808080),
                                  ),
                                ),
                              )).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Meal Logging
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButton<String>(
                            value: _selectedMealType,
                            isExpanded: true,
                            items: <String>['Breakfast', 'Lunch', 'Dinner', 'Snack'].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: GoogleFonts.roboto(
                                    fontSize: 16,
                                    color: const Color(0xFF1C2526),
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedMealType = newValue;
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: _addMeal,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB22222),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Log Meal'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Water Logging
                    ElevatedButton.icon(
                      icon: const Icon(Icons.local_drink, size: 24),
                      label: const Text('Log Water', style: TextStyle(fontSize: 18)),
                      onPressed: _addWater,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB22222),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Meal Log
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      color: const Color(0xFFB0B7BF),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Today\'s Meals',
                              style: GoogleFonts.oswald(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFB22222),
                              ),
                            ),
                            const SizedBox(height: 8),
                            _meals.isEmpty
                                ? const Text('No meals logged yet.')
                                : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _meals.length,
                              itemBuilder: (context, index) {
                                final meal = _meals[index];
                                final timestamp = meal['timestamp'] as int?;
                                if (timestamp == null) return const SizedBox.shrink();
                                final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
                                final now = DateTime.now();
                                final startOfDay = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
                                final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59).millisecondsSinceEpoch;
                                if (timestamp < startOfDay || timestamp > endOfDay) return const SizedBox.shrink();
                                return ListTile(
                                  title: Text(
                                    '${meal['mealType']}: ${meal['food']}',
                                    style: GoogleFonts.roboto(
                                      fontSize: 16,
                                      color: const Color(0xFF1C2526),
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${meal['calories']} kcal, ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                                    style: GoogleFonts.roboto(
                                      fontSize: 14,
                                      color: const Color(0xFF808080),
                                    ),
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete, color: Color(0xFFB22222)),
                                    onPressed: () async {
                                      await DatabaseHelper.deleteMeal(meal['id'] as String);
                                      await _loadData();
                                    },
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMeal,
        backgroundColor: const Color(0xFFB22222),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// Extension to capitalize strings
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}