import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:personal_trainer_app_clean/core/data/repositories/meal_repository.dart';
import 'package:personal_trainer_app_clean/core/data/repositories/recipe_repository.dart';
import 'package:personal_trainer_app_clean/core/data/repositories/shopping_list_repository.dart';
import 'package:personal_trainer_app_clean/core/data/repositories/water_intake_repository.dart';
import 'package:personal_trainer_app_clean/core/data/models/meal.dart';
import 'package:personal_trainer_app_clean/core/data/models/recipe.dart';
import 'package:personal_trainer_app_clean/core/data/models/shopping_list_item.dart';
import 'package:personal_trainer_app_clean/core/data/models/water_intake.dart';
import 'package:personal_trainer_app_clean/core/services/diet_service.dart';
import 'package:personal_trainer_app_clean/core/utils/cross_painter.dart';
import 'widgets/daily_summary.dart';
import 'widgets/saved_recipes.dart';
import 'widgets/shopping_list.dart';
import 'widgets/meal_log.dart';
import 'widgets/add_custom_food_dialog.dart';
import 'widgets/add_recipe_dialog.dart';

class DietScreen extends StatefulWidget {
  const DietScreen({super.key});

  @override
  _DietScreenState createState() => _DietScreenState();
}

class _DietScreenState extends State<DietScreen> {
  final MealRepository _mealRepository = MealRepository();
  final RecipeRepository _recipeRepository = RecipeRepository();
  final ShoppingListRepository _shoppingListRepository = ShoppingListRepository();
  final WaterIntakeRepository _waterIntakeRepository = WaterIntakeRepository();
  final DietService _dietService = DietService();

  List<Meal> _meals = [];
  List<Map<String, dynamic>> _foodDatabase = [];
  List<Map<String, dynamic>> _customFoods = [];
  List<Recipe> _recipes = [];
  List<WaterIntake> _waterIntake = [];
  Map<String, dynamic> _dietPreferences = {};
  double _dailyCalories = 0.0;
  double _dailyProtein = 0.0;
  double _dailyCarbs = 0.0;
  double _dailyFat = 0.0;
  double _dailyWater = 0.0;
  String _selectedMealType = 'Breakfast'; // Options: Breakfast, Lunch, Dinner, Snack
  List<Map<String, dynamic>> _recommendedFoods = [];
  List<ShoppingListItem> _shoppingList = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    print('Loading data...');
    // Load meals
    final meals = await _mealRepository.getMeals();
    final waterIntake = await _waterIntakeRepository.getWaterIntake();
    final customFoods = await _dietService.loadFoodDatabase();
    final recipes = await _recipeRepository.getRecipes();
    final shoppingList = await _shoppingListRepository.getShoppingList();
    final prefs = await SharedPreferences.getInstance();
    var dietPreferences = prefs.getString('dietPreferences') != null
        ? jsonDecode(prefs.getString('dietPreferences')!) as Map<String, dynamic>
        : {
      'goal': 'maintain',
      'dietaryPreference': 'none',
      'calorieGoal': 2000,
      'macroGoals': {'protein': 25, 'carbs': 50, 'fat': 25},
      'allergies': [],
    };

    // Ensure diet preferences are saved
    if (prefs.getString('dietPreferences') == null) {
      await prefs.setString('dietPreferences', jsonEncode(dietPreferences));
    }

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
      final timestamp = meal.timestamp;
      if (timestamp < startOfDay || timestamp > endOfDay) continue;
      calories += meal.calories;
      protein += meal.protein;
      carbs += meal.carbs;
      fat += meal.fat;
    }

    for (var entry in waterIntake) {
      final timestamp = entry.timestamp;
      if (timestamp < startOfDay || timestamp > endOfDay) continue;
      water += entry.amount;
    }

    // Generate food recommendations
    final foodDatabase = await _dietService.loadFoodDatabase();
    final recommendedFoods = _dietService.generateRecommendations(foodDatabase, dietPreferences);

    setState(() {
      _meals = meals;
      _waterIntake = waterIntake;
      _customFoods = customFoods;
      _recipes = recipes;
      _shoppingList = shoppingList;
      _dietPreferences = dietPreferences;
      _foodDatabase = foodDatabase;
      _dailyCalories = calories;
      _dailyProtein = protein;
      _dailyCarbs = carbs;
      _dailyFat = fat;
      _dailyWater = water;
      _recommendedFoods = recommendedFoods;
      print('Data loaded: ${meals.length} meals, ${recommendedFoods.length} recommendations, ${shoppingList.length} shopping list items, ${recipes.length} recipes');
    });
  }

  Future<void> _generateShoppingList() async {
    final newShoppingList = _dietService.generateShoppingList(_meals);
    await _shoppingListRepository.saveShoppingList(
      newShoppingList.map((item) {
        final map = item as Map<String, dynamic>;
        return ShoppingListItem.fromMap(map);
      }).toList(),
    );
    await _loadData();
  }

  Future<void> _toggleShoppingItem(String itemId, bool checked) async {
    final updatedShoppingList = _shoppingList.map((item) {
      if (item.id == itemId) {
        return ShoppingListItem(
          id: item.id,
          name: item.name,
          quantity: item.quantity,
          checked: checked,
        );
      }
      return item;
    }).toList();
    await _shoppingListRepository.saveShoppingList(updatedShoppingList);
    await _loadData();
  }

  Future<void> _clearShoppingList() async {
    await _shoppingListRepository.clearShoppingList();
    await _loadData();
  }

  Future<void> _addCustomFood() async {
    await showDialog(
      context: context,
      builder: (context) => AddCustomFoodDialog(
        onSave: (customFood) async {
          print('Saving custom food: $customFood');
          setState(() {
            _foodDatabase.add(customFood);
          });
        },
      ),
    );
    await _loadData();
  }

  Future<void> _addRecipe() async {
    await showDialog(
      context: context,
      builder: (context) => AddRecipeDialog(
        allFoods: [..._foodDatabase, ..._customFoods],
        onSave: (recipe) async {
          await _recipeRepository.addRecipe(Recipe.fromMap(recipe));
          await _loadData();
        },
      ),
    );
  }

  Future<void> _deleteRecipe(String recipeId) async {
    await _recipeRepository.deleteRecipe(recipeId);
    await _loadData();
  }

  Future<void> _addMeal() async {
    final allFoods = [
      ..._foodDatabase,
      ..._customFoods,
      ..._recipes.map((recipe) => ({
        'name': recipe.name,
        'calories': recipe.calories,
        'protein': recipe.protein,
        'carbs': recipe.carbs,
        'fat': recipe.fat,
        'sodium': recipe.sodium,
        'fiber': recipe.fiber,
        'suitable_for': ['recipe'],
        'isRecipe': true,
        'ingredients': recipe.ingredients,
      })),
    ];
    String? selectedFood = allFoods.isNotEmpty ? allFoods[0]['name'] as String : null;
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
                hint: const Text('Select Food or Recipe'),
                isExpanded: true,
                items: allFoods.map((food) {
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
                    const SnackBar(content: Text('Please select a food or recipe and enter servings')),
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
      final food = allFoods.firstWhere((f) => f['name'] == selectedFood);
      final meal = Meal(
        id: '', // Will be set in the repository
        food: food['name'] as String,
        mealType: _selectedMealType,
        calories: ((food['calories'] as num?)?.toDouble() ?? 0.0) * servings,
        protein: ((food['protein'] as num?)?.toDouble() ?? 0.0) * servings,
        carbs: ((food['carbs'] as num?)?.toDouble() ?? 0.0) * servings,
        fat: ((food['fat'] as num?)?.toDouble() ?? 0.0) * servings,
        sodium: ((food['sodium'] as num?)?.toDouble() ?? 0.0) * servings,
        fiber: ((food['fiber'] as num?)?.toDouble() ?? 0.0) * servings,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        servings: servings,
        isRecipe: food['isRecipe'] as bool? ?? false,
        ingredients: food['ingredients'] as List<Map<String, dynamic>>?,
      );
      await _mealRepository.insertMeal(meal);
      await _loadData();
    }
  }

  Future<void> _deleteMeal(String mealId) async {
    await _mealRepository.deleteMeal(mealId);
    await _loadData();
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
      await _waterIntakeRepository.addWaterIntake(amount);
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
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('dietPreferences', jsonEncode(updatedPreferences));
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
                    DailySummary(
                      dailyCalories: _dailyCalories,
                      calorieGoal: _dietPreferences['calorieGoal']?.toDouble() ?? 2000,
                      dailyProtein: _dailyProtein,
                      dailyCarbs: _dailyCarbs,
                      dailyFat: _dailyFat,
                      dailyWater: _dailyWater,
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
                    // Add Custom Food
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add_circle, size: 24),
                      label: const Text('Add Custom Food', style: TextStyle(fontSize: 18)),
                      onPressed: _addCustomFood,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB22222),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Add Recipe
                    ElevatedButton.icon(
                      icon: const Icon(Icons.kitchen, size: 24),
                      label: const Text('Create Recipe', style: TextStyle(fontSize: 18)),
                      onPressed: _addRecipe,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB22222),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Saved Recipes
                    SavedRecipes(
                      recipes: _recipes,
                      onDelete: _deleteRecipe,
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
                    MealLog(
                      meals: _meals,
                      onDelete: _deleteMeal,
                    ),
                    const SizedBox(height: 16),
                    // Shopping List
                    ShoppingList(
                      shoppingList: _shoppingList,
                      onToggle: _toggleShoppingItem,
                      onGenerate: _generateShoppingList,
                      onClear: _clearShoppingList,
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