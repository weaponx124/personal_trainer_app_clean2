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
import 'package:personal_trainer_app_clean/main.dart';
import 'package:personal_trainer_app_clean/widgets/common/app_snack_bar.dart';
import 'package:share_plus/share_plus.dart'; // Import share_plus
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

class _DietScreenState extends State<DietScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
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
  double _proteinGoal = 0.0;
  double _carbsGoal = 0.0;
  double _fatGoal = 0.0;
  String _selectedMealType = 'Breakfast';
  List<Map<String, dynamic>> _recommendedFoods = [];
  List<ShoppingListItem> _shoppingList = [];
  bool _isLoading = true;
  String? _errorMessage;
  DateTime _selectedDate = DateTime.now();

  static const String _customFoodsKey = 'customFoods';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('Loading data... Step 1: Fetching meals');
      final meals = await _mealRepository.getMeals();
      print('Step 2: Fetching water intake');
      final waterIntake = await _waterIntakeRepository.getWaterIntake();
      print('Step 3: Loading food database');
      final foodDatabaseFoods = await _dietService.loadFoodDatabase(context);
      print('Step 4: Loading custom foods');
      final prefs = await SharedPreferences.getInstance();
      final customFoodsJson = prefs.getString(_customFoodsKey);
      final customFoods = customFoodsJson != null
          ? (jsonDecode(customFoodsJson) as List<dynamic>).cast<Map<String, dynamic>>()
          : [];
      print('Step 5: Fetching recipes');
      final recipes = await _recipeRepository.getRecipes();
      print('Step 6: Fetching shopping list');
      final shoppingList = await _shoppingListRepository.getShoppingList();
      print('Step 7: Fetching diet preferences');
      var dietPreferences = prefs.getString('dietPreferences') != null
          ? jsonDecode(prefs.getString('dietPreferences')!) as Map<String, dynamic>
          : {
        'goal': 'maintain',
        'dietaryPreference': 'none',
        'calorieGoal': 2000,
        'macroGoals': {'protein': 25, 'carbs': 50, 'fat': 25},
        'waterGoal': 64,
        'allergies': [],
      };

      if (prefs.getString('dietPreferences') == null) {
        print('Step 8: Saving default diet preferences');
        await prefs.setString('dietPreferences', jsonEncode(dietPreferences));
      }

      final Map<String, Map<String, dynamic>> uniqueFoodDatabase = {};
      for (var food in foodDatabaseFoods) {
        final name = food['name'] as String;
        if (!uniqueFoodDatabase.containsKey(name)) {
          uniqueFoodDatabase[name] = food;
        } else {
          print('Warning: Duplicate food name "$name" found in food_database.json. Keeping the first occurrence.');
        }
      }
      final deduplicatedFoodDatabase = uniqueFoodDatabase.values.toList();

      final Map<String, Map<String, dynamic>> uniqueCustomFoods = {};
      for (var food in customFoods) {
        final name = food['name'] as String;
        if (!uniqueFoodDatabase.containsKey(name)) {
          uniqueFoodDatabase[name] = food;
        } else {
          print('Warning: Duplicate food name "$name" found in customFoods. Keeping the first occurrence.');
        }
      }
      final deduplicatedCustomFoods = uniqueCustomFoods.values.toList();

      print('Step 9: Calculating daily totals');
      double calories = 0.0;
      double protein = 0.0;
      double carbs = 0.0;
      double fat = 0.0;
      double water = 0.0;

      final startOfDay = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day).millisecondsSinceEpoch;
      final endOfDay = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 23, 59, 59).millisecondsSinceEpoch;

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

      final calorieGoal = (dietPreferences['calorieGoal'] as int? ?? 2000).toDouble();
      final macroGoals = dietPreferences['macroGoals'] as Map<String, dynamic>? ?? {'protein': 25, 'carbs': 50, 'fat': 25};
      final proteinPercentage = (macroGoals['protein'] as int? ?? 25).toDouble();
      final carbsPercentage = (macroGoals['carbs'] as int? ?? 50).toDouble();
      final fatPercentage = (macroGoals['fat'] as int? ?? 25).toDouble();

      final proteinGoal = (calorieGoal * (proteinPercentage / 100)) / 4;
      final carbsGoal = (calorieGoal * (carbsPercentage / 100)) / 4;
      final fatGoal = (calorieGoal * (fatPercentage / 100)) / 9;

      print('Step 10: Generating recommendations');
      final recommendedFoods = _dietService.generateRecommendations(deduplicatedFoodDatabase, dietPreferences);

      print('Step 11: Updating state');
      setState(() {
        _meals = meals;
        _waterIntake = waterIntake;
        _customFoods = deduplicatedCustomFoods;
        _recipes = recipes;
        _shoppingList = shoppingList;
        _dietPreferences = dietPreferences;
        _foodDatabase = deduplicatedFoodDatabase;
        _dailyCalories = calories;
        _dailyProtein = protein;
        _dailyCarbs = carbs;
        _dailyFat = fat;
        _dailyWater = water;
        _proteinGoal = proteinGoal;
        _carbsGoal = carbsGoal;
        _fatGoal = fatGoal;
        _recommendedFoods = recommendedFoods;
        _isLoading = false;
        print('Data loaded: ${meals.length} meals, ${recommendedFoods.length} recommendations, ${shoppingList.length} shopping list items, ${recipes.length} recipes');
      });
    } catch (e, stackTrace) {
      print('Error in _loadData: $e');
      print('Stack trace: $stackTrace');
      await _mealRepository.clearMeals();
      await _recipeRepository.clearRecipes();
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load diet data: $e\nCleared meal and recipe data. Please try again.';
      });
    }
  }

  Future<void> _generateShoppingList() async {
    final newShoppingList = _dietService.generateShoppingList(_meals);
    await _shoppingListRepository.saveShoppingList(
      newShoppingList.map((item) => ShoppingListItem.fromMap(item)).toList(),
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
    try {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AddCustomFoodDialog(
          onSave: (customFood) async {
            try {
              final foodName = customFood['name'] as String;
              final existsInDatabase = _foodDatabase.any((food) => food['name'] == foodName);
              final existsInCustom = _customFoods.any((food) => food['name'] == foodName);
              if (existsInDatabase || existsInCustom) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('A food with the name "$foodName" already exists.')),
                );
                return;
              }
              print('Saving custom food: $customFood');
              setState(() {
                _customFoods.add(customFood);
              });
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString(_customFoodsKey, jsonEncode(_customFoods));
              print('Saved custom foods to SharedPreferences: $_customFoods');
              Navigator.pop(context, true);
            } catch (e, stackTrace) {
              print('Error in AddCustomFoodDialog onSave: $e');
              print('Stack trace: $stackTrace');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to save custom food: $e')),
              );
            }
          },
        ),
      );

      if (result == true) {
        print('Custom food saved successfully, calling _loadData');
        await _loadData();
      } else {
        print('Custom food dialog closed without saving');
      }
    } catch (e, stackTrace) {
      print('Error in _addCustomFood: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        _errorMessage = 'Failed to add custom food: $e';
      });
    }
  }

  Future<void> _addRecipe() async {
    final combinedFoods = [..._foodDatabase, ..._customFoods];
    final Map<String, Map<String, dynamic>> uniqueFoods = {};
    for (var food in combinedFoods) {
      final name = food['name'] as String;
      if (!uniqueFoods.containsKey(name)) {
        uniqueFoods[name] = food;
      } else {
        print('Warning: Duplicate food name "$name" found in combined foods for recipe dialog. Keeping the first occurrence.');
      }
    }
    final deduplicatedFoods = uniqueFoods.values.toList();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AddRecipeDialog(
        allFoods: deduplicatedFoods,
        onSave: (recipe) async {
          try {
            final recipeName = recipe['name'] as String;
            final existsInRecipes = _recipes.any((r) => r.name == recipeName);
            if (existsInRecipes) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('A recipe with the name "$recipeName" already exists.')),
              );
              return;
            }
            await _recipeRepository.addRecipe(recipe);
            final updatedRecipes = await _recipeRepository.getRecipes();
            setState(() {
              _recipes = updatedRecipes;
            });
            await _loadData();
          } catch (e, stackTrace) {
            print('Error saving recipe: $e');
            print('Stack trace: $stackTrace');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to save recipe: $e')),
            );
          }
        },
      ),
    );

    if (result != true) {
      await _loadData();
    }
  }

  Future<void> _deleteRecipe(String recipeId) async {
    try {
      await _recipeRepository.deleteRecipe(recipeId);
      await _loadData();
    } catch (e, stackTrace) {
      print('Error deleting recipe: $e');
      print('Stack trace: $stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete recipe: $e')),
      );
    }
  }

  Future<void> _addMeal() async {
    final combinedFoods = [
      ..._foodDatabase.map((food) => ({...food, 'isRecipe': false})),
      ..._customFoods.map((food) => ({...food, 'isRecipe': false})),
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

    final Map<String, List<Map<String, dynamic>>> groupedFoods = {};
    for (var food in combinedFoods) {
      final name = food['name'] as String;
      final key = '$name:${food['isRecipe'] ? 'recipe' : 'food'}';
      if (!groupedFoods.containsKey(key)) {
        groupedFoods[key] = [];
      }
      groupedFoods[key]!.add(food);
    }
    final deduplicatedFoods = groupedFoods.values.expand((list) => list).toList();

    final allFoods = deduplicatedFoods.asMap().entries.map((entry) {
      final index = entry.key;
      final food = entry.value;
      final type = food['isRecipe'] == true ? 'recipe' : (food.containsKey('uniqueId') && (food['uniqueId'] as String).startsWith('custom') ? 'custom' : 'food');
      return {
        ...food,
        'uniqueId': '$type:$index:${food['name']}',
      };
    }).toList();

    String? selectedFoodId = allFoods.isNotEmpty ? allFoods[0]['uniqueId'] as String : null;
    final TextEditingController amountController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Log $_selectedMealType for ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<String>.empty();
                  }
                  return allFoods.where((food) {
                    final name = food['name'] as String;
                    return name.toLowerCase().contains(textEditingValue.text.toLowerCase());
                  }).map((food) => food['uniqueId'] as String);
                },
                displayStringForOption: (String uniqueId) {
                  final food = allFoods.firstWhere((f) => f['uniqueId'] == uniqueId);
                  return food['isRecipe'] == true ? '${food['name']} (Recipe)' : food['name'] as String;
                },
                onSelected: (String uniqueId) {
                  setDialogState(() {
                    selectedFoodId = uniqueId;
                  });
                },
                fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      labelText: 'Select Food or Recipe',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (value) => onFieldSubmitted(),
                  );
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
                if (selectedFoodId != null && amountController.text.isNotEmpty) {
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
      final food = allFoods.firstWhere((f) => f['uniqueId'] == selectedFoodId);
      final meal = Meal(
        id: '',
        food: food['name'],
        mealType: _selectedMealType,
        calories: ((food['calories'] as num?)?.toDouble() ?? 0.0) * servings,
        protein: ((food['protein'] as num?)?.toDouble() ?? 0.0) * servings,
        carbs: ((food['carbs'] as num?)?.toDouble() ?? 0.0) * servings,
        fat: ((food['fat'] as num?)?.toDouble() ?? 0.0) * servings,
        sodium: ((food['sodium'] as num?)?.toDouble() ?? 0.0) * servings,
        fiber: ((food['fiber'] as num?)?.toDouble() ?? 0.0) * servings,
        timestamp: DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 12).millisecondsSinceEpoch,
        servings: servings,
        isRecipe: food['isRecipe'] as bool? ?? false,
        ingredients: food['ingredients'] as List<Map<String, dynamic>>?,
      );
      await _mealRepository.insertMeal(meal);
      await _loadData();
    }
  }

  Future<void> _editMeal(Meal meal) async {
    final combinedFoods = [
      ..._foodDatabase.map((food) => ({...food, 'isRecipe': false})),
      ..._customFoods.map((food) => ({...food, 'isRecipe': false})),
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

    final Map<String, List<Map<String, dynamic>>> groupedFoods = {};
    for (var food in combinedFoods) {
      final name = food['name'] as String;
      final key = '$name:${food['isRecipe'] ? 'recipe' : 'food'}';
      if (!groupedFoods.containsKey(key)) {
        groupedFoods[key] = [];
      }
      groupedFoods[key]!.add(food);
    }
    final deduplicatedFoods = groupedFoods.values.expand((list) => list).toList();

    final allFoods = deduplicatedFoods.asMap().entries.map((entry) {
      final index = entry.key;
      final food = entry.value;
      final type = food['isRecipe'] == true ? 'recipe' : (food.containsKey('uniqueId') && (food['uniqueId'] as String).startsWith('custom') ? 'custom' : 'food');
      return {
        ...food,
        'uniqueId': '$type:$index:${food['name']}',
      };
    }).toList();

    String? selectedFoodId;
    for (var food in allFoods) {
      if (food['name'] == meal.food && food['isRecipe'] == meal.isRecipe) {
        selectedFoodId = food['uniqueId'] as String;
        break;
      }
    }
    if (selectedFoodId == null && allFoods.isNotEmpty) {
      selectedFoodId = allFoods[0]['uniqueId'] as String;
    }
    final TextEditingController amountController = TextEditingController(text: meal.servings.toString());
    String selectedMealType = meal.mealType;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Meal'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                value: selectedMealType,
                isExpanded: true,
                items: <String>['Breakfast', 'Lunch', 'Dinner', 'Snack'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setDialogState(() {
                      selectedMealType = newValue;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<String>.empty();
                  }
                  return allFoods.where((food) {
                    final name = food['name'] as String;
                    return name.toLowerCase().contains(textEditingValue.text.toLowerCase());
                  }).map((food) => food['uniqueId'] as String);
                },
                displayStringForOption: (String uniqueId) {
                  final food = allFoods.firstWhere((f) => f['uniqueId'] == uniqueId);
                  return food['isRecipe'] == true ? '${food['name']} (Recipe)' : food['name'] as String;
                },
                onSelected: (String uniqueId) {
                  setDialogState(() {
                    selectedFoodId = uniqueId;
                  });
                },
                fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                  controller.text = allFoods.firstWhere((f) => f['uniqueId'] == selectedFoodId)['name'] as String;
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      labelText: 'Select Food or Recipe',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (value) => onFieldSubmitted(),
                  );
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
                if (selectedFoodId != null && amountController.text.isNotEmpty) {
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
      await _mealRepository.deleteMeal(meal.id);
      final servings = double.tryParse(amountController.text) ?? 1.0;
      final food = allFoods.firstWhere((f) => f['uniqueId'] == selectedFoodId);
      final updatedMeal = Meal(
        id: '',
        food: food['name'],
        mealType: selectedMealType,
        calories: ((food['calories'] as num?)?.toDouble() ?? 0.0) * servings,
        protein: ((food['protein'] as num?)?.toDouble() ?? 0.0) * servings,
        carbs: ((food['carbs'] as num?)?.toDouble() ?? 0.0) * servings,
        fat: ((food['fat'] as num?)?.toDouble() ?? 0.0) * servings,
        sodium: ((food['sodium'] as num?)?.toDouble() ?? 0.0) * servings,
        fiber: ((food['fiber'] as num?)?.toDouble() ?? 0.0) * servings,
        timestamp: meal.timestamp,
        servings: servings,
        isRecipe: food['isRecipe'] as bool? ?? false,
        ingredients: food['ingredients'] as List<Map<String, dynamic>>?,
      );
      await _mealRepository.insertMeal(updatedMeal);
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
        title: Text('Log Water Intake for ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
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
      await _waterIntakeRepository.addWaterIntakeWithTimestamp(
        amount,
        DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 12).millisecondsSinceEpoch,
      );
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
    final TextEditingController waterController = TextEditingController(
      text: (_dietPreferences['waterGoal'] as int? ?? 64).toString(),
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
                  controller: waterController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Daily Water Goal (oz)',
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
        'waterGoal': int.tryParse(waterController.text) ?? 64,
        'allergies': allergies,
      };
      print('Saving diet preferences: $updatedPreferences');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('dietPreferences', jsonEncode(updatedPreferences));
      await _loadData();
    }
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
      await _loadData();
    }
  }

  Future<void> _shareDietSummary() async {
    final totalCalories = _dailyCalories;
    final mealSummary = _meals
        .where((meal) {
      final timestamp = meal.timestamp;
      final startOfDay = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day).millisecondsSinceEpoch;
      final endOfDay = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 23, 59, 59).millisecondsSinceEpoch;
      return timestamp >= startOfDay && timestamp <= endOfDay;
    })
        .map((meal) => '- ${meal.food} (${meal.mealType}): ${meal.calories} kcal')
        .join('\n');
    final shareText = '''
Diet Summary for ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}
Total Calories: $totalCalories kcal
Meals:
$mealSummary
''';
    await Share.share(shareText, subject: 'My Diet Summary');
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Color>(
      valueListenable: accentColorNotifier,
      builder: (context, accentColor, child) {
        return Container(
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
              Scaffold(
                backgroundColor: Colors.transparent,
                floatingActionButton: FloatingActionButton(
                  onPressed: _shareDietSummary,
                  backgroundColor: accentColor,
                  child: const Icon(Icons.share),
                  tooltip: 'Share Diet Summary',
                ),
                body: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _errorMessage != null
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
                    : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Selected Date: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              color: const Color(0xFF1C2526),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: Icon(Icons.calendar_today, color: accentColor),
                            onPressed: _pickDate,
                          ),
                        ],
                      ),
                    ),
                    TabBar(
                      controller: _tabController,
                      labelColor: accentColor,
                      unselectedLabelColor: const Color(0xFF808080),
                      indicatorColor: accentColor,
                      tabs: const [
                        Tab(text: 'Daily Summary'),
                        Tab(text: 'Meal Log'),
                        Tab(text: 'Recipes'),
                        Tab(text: 'Shopping List'),
                        Tab(text: 'Preferences'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          // Daily Summary Tab
                          DailySummary(
                            dailyCalories: _dailyCalories,
                            calorieGoal: _dietPreferences['calorieGoal']?.toDouble() ?? 2000,
                            dailyProtein: _dailyProtein,
                            dailyCarbs: _dailyCarbs,
                            dailyFat: _dailyFat,
                            dailyWater: _dailyWater,
                            proteinGoal: _proteinGoal,
                            carbsGoal: _carbsGoal,
                            fatGoal: _fatGoal,
                            waterGoal: _dietPreferences['waterGoal']?.toDouble() ?? 64,
                            selectedDate: _selectedDate,
                            onAddWater: _addWater,
                          ),
                          // Meal Log Tab
                          MealLog(
                            meals: _meals,
                            onDelete: _deleteMeal,
                            onEdit: _editMeal,
                            onAddCustomFood: _addCustomFood,
                            onAddRecipe: _addRecipe,
                            onAddMeal: _addMeal,
                            selectedMealType: _selectedMealType,
                            onMealTypeChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedMealType = newValue;
                                });
                              }
                            },
                            selectedDate: _selectedDate,
                          ),
                          // Saved Recipes Tab
                          SavedRecipes(
                            recipes: _recipes,
                            onDelete: _deleteRecipe,
                            onAddRecipe: _addRecipe,
                          ),
                          // Shopping List Tab
                          ShoppingList(
                            shoppingList: _shoppingList,
                            onToggle: _toggleShoppingItem,
                            onGenerate: _generateShoppingList,
                            onClear: _clearShoppingList,
                          ),
                          // Preferences Tab
                          SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Diet Preferences
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.settings, size: 24),
                                    label: const Text('Edit Diet Preferences', style: TextStyle(fontSize: 18)),
                                    onPressed: _editDietPreferences,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: accentColor,
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
                                              color: accentColor,
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
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Extension to capitalize strings
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}