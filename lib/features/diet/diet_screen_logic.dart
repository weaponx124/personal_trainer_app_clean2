import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:personal_trainer_app_clean/core/data/models/meal.dart';
import 'package:personal_trainer_app_clean/core/data/models/recipe.dart';
import 'package:personal_trainer_app_clean/core/data/models/shopping_list_item.dart';
import 'package:personal_trainer_app_clean/features/diet/diet_profile.dart';
import 'package:personal_trainer_app_clean/core/data/models/custom_food.dart';
import 'package:personal_trainer_app_clean/core/data/repositories/custom_food_repository.dart';
import 'package:personal_trainer_app_clean/core/data/repositories/shopping_list_repository.dart';
import 'package:personal_trainer_app_clean/core/data/repositories/meal_repository.dart';
import 'dart:convert' show utf8, base64;

class DietScreenLogic {
  late TabController _tabController;
  final ValueNotifier<List<Meal>> _meals = ValueNotifier([]);
  final ValueNotifier<List<Recipe>> _recipes = ValueNotifier([]);
  final ValueNotifier<List<ShoppingListItem>> _shoppingList = ValueNotifier([]);
  List<CustomFood> _customFoods = [];
  List<Map<String, dynamic>> allFoods = [];
  DateTime _selectedDate = DateTime.now();
  String _selectedMealType = 'Meal 1';
  final ValueNotifier<DietProfile> _dietProfile = ValueNotifier(DietProfile.profiles[0]);
  int? _customCalories;
  final ValueNotifier<List<String>> _mealNames = ValueNotifier(['Breakfast', 'Lunch', 'Dinner']);
  final CustomFoodRepository _customFoodRepository = CustomFoodRepository();
  final ShoppingListRepository _shoppingListRepository = ShoppingListRepository();
  final MealRepository _mealRepository = MealRepository();
  String? _fatSecretAccessToken;

  final List<Map<String, dynamic>> _foodDatabase = [
    {
      'food': 'Chicken Breast',
      'measurement': '4oz',
      'calories': 165.0,
      'protein': 31.0,
      'carbs': 0.0,
      'fat': 3.6,
      'sodium': 74.0,
      'fiber': 0.0,
      'servings': 1.0,
      'isRecipe': false
    },
    {
      'food': 'Broccoli',
      'measurement': '1 cup',
      'calories': 35.0,
      'protein': 3.0,
      'carbs': 7.0,
      'fat': 0.4,
      'sodium': 33.0,
      'fiber': 3.0,
      'servings': 1.0,
      'isRecipe': false
    },
    {
      'food': 'Avocado',
      'measurement': '1 medium',
      'calories': 160.0,
      'protein': 2.0,
      'carbs': 9.0,
      'fat': 15.0,
      'sodium': 7.0,
      'fiber': 7.0,
      'servings': 1.0,
      'isRecipe': false
    },
  ];

  DietScreenLogic(TickerProvider vsync) {
    _tabController = TabController(length: 3, vsync: vsync);
  }

  TabController get tabController => _tabController;
  ValueNotifier<List<Meal>> get meals => _meals;
  ValueNotifier<List<Recipe>> get recipes => _recipes;
  ValueNotifier<List<ShoppingListItem>> get shoppingList => _shoppingList;
  DateTime get selectedDate => _selectedDate;
  String get selectedMealType => _selectedMealType;
  ValueNotifier<DietProfile> get dietProfile => _dietProfile;
  int? get customCalories => _customCalories;
  ValueNotifier<List<String>> get mealNames => _mealNames;
  List<Map<String, dynamic>> get foodDatabase => _foodDatabase;

  Future<void> init() async {
    _tabController.addListener(_onTabChanged);
    await _loadCustomFoods(); // Load custom foods
    await _fetchFatSecretAccessToken(); // Fetch FatSecret access token
    _loadInitialData();
    // Migrate meals from SharedPreferences to SQLite
    await _mealRepository.migrateFromSharedPreferences();
    final prefs = await SharedPreferences.getInstance();
    print('Prefs loaded');
    _customCalories = prefs.getInt('customCalories');
    final profileName = prefs.getString('profileName');
    print('Loaded profileName: $profileName, customCalories: $_customCalories');
    if (profileName != null) {
      final profile = DietProfile.profiles.firstWhere(
            (p) => p.name == profileName,
        orElse: () => DietProfile.profiles[0],
      );
      final customProtein = prefs.getDouble('customProtein');
      final customCarbs = prefs.getDouble('customCarbs');
      final customFat = prefs.getDouble('customFat');
      if (profileName == 'Custom' &&
          customProtein != null &&
          customCarbs != null &&
          customFat != null) {
        _dietProfile.value = DietProfile(
          name: 'Custom',
          proteinPercentage: customProtein,
          carbsPercentage: customCarbs,
          fatPercentage: customFat,
          defaultCalories: _customCalories ?? 2000,
          scripture:
          'Proverbs 16:3 - "Commit to the Lord whatever you do, and he will establish your plans."',
        );
      } else {
        _dietProfile.value = profile;
      }
    }
    // Load meals from repository
    try {
      _meals.value = await _mealRepository.getMeals();
      print('Loaded meals from repository: ${_meals.value.length}');
      for (var meal in _meals.value) {
        print('Loaded meal: ${meal.toJson()}');
      }
    } catch (e) {
      print('Error loading meals from repository: $e');
      _meals.value = [];
    }
    // Load recipes
    final savedRecipes = prefs.getString('recipes');
    print('Raw saved recipes from SharedPreferences: $savedRecipes');
    if (savedRecipes != null && savedRecipes.isNotEmpty) {
      try {
        final List<dynamic> jsonList = json.decode(savedRecipes);
        print('Decoded recipes JSON: $jsonList');
        _recipes.value = jsonList.map((json) {
          try {
            return Recipe.fromJson(json as Map<String, dynamic>);
          } catch (e) {
            print('Error parsing recipe from JSON: $json, error: $e');
            return null;
          }
        }).where((recipe) => recipe != null).cast<Recipe>().toList();
        print('Loaded recipes: ${_recipes.value.length}');
        for (var recipe in _recipes.value) {
          print('Loaded recipe: ${recipe.toJson()}');
        }
      } catch (e) {
        print('Error loading recipes from SharedPreferences: $e');
        _recipes.value = [];
      }
    } else {
      print('No saved recipes found in SharedPreferences or empty string');
      _recipes.value = [];
    }
    // Load shopping list from repository
    try {
      _shoppingList.value = await _shoppingListRepository.getShoppingList();
      print('Loaded shopping list items from repository: ${_shoppingList.value.length}');
      for (var item in _shoppingList.value) {
        print('Loaded shopping list item: ${item.toJson()}');
      }
    } catch (e) {
      print('Error loading shopping list from repository: $e');
      _shoppingList.value = [];
    }
    final savedMealNames = prefs.getStringList('mealNames');
    if (savedMealNames != null && savedMealNames.isNotEmpty) {
      _mealNames.value = savedMealNames;
      _selectedMealType = _mealNames.value[0];
      print('Loaded mealNames: ${_mealNames.value}');
    } else {
      _mealNames.value = ['Meal 1', 'Meal 2', 'Meal 3'];
      _selectedMealType = _mealNames.value[0];
      print('Initialized default mealNames: ${_mealNames.value}');
    }
    if (_customCalories != null) {
      print('Applied customCalories: $_customCalories');
    } else {
      print(
          'No customCalories found, using default: ${_dietProfile.value.defaultCalories}');
    }
    // Initialize allFoods with _foodDatabase
    allFoods = List.from(_foodDatabase);
    // Add custom foods to allFoods
    for (var customFood in _customFoods) {
      allFoods.add({
        'food': customFood.name,
        'measurement': 'Per serving', // Default measurement for custom foods
        'calories': customFood.calories,
        'protein': customFood.protein,
        'carbs': customFood.carbs,
        'fat': customFood.fat,
        'sodium': 0.0,
        'fiber': 0.0,
        'servings': 1.0,
        'isRecipe': false,
      });
    }
  }

  Future<void> _fetchFatSecretAccessToken() async {
    const clientId = '4a4f7fd3016e4cedba709f38af5e7b7d';
    const clientSecret = 'e1796e15fba294a3a59a88642f3e975a'; // Update if reset
    const tokenUrl = 'https://oauth.fatsecret.com/connect/token';

    // Encode Client ID and Client Secret for Basic Authentication
    final auth = base64.encode(utf8.encode('$clientId:$clientSecret'));

    try {
      final response = await http.post(
        Uri.parse(tokenUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Basic $auth',
        },
        body: {
          'grant_type': 'client_credentials',
          'scope': 'basic',
        },
      );

      print('FatSecret Token Response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _fatSecretAccessToken = data['access_token'];
        print('FatSecret Access Token: $_fatSecretAccessToken');
      } else {
        print('Failed to fetch FatSecret access token: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error fetching FatSecret access token: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchFoods(String query) async {
    if (_fatSecretAccessToken == null) {
      print('No FatSecret access token available. Attempting to fetch a new one.');
      await _fetchFatSecretAccessToken();
      if (_fatSecretAccessToken == null) {
        print('Failed to obtain FatSecret access token. Using mock response.');
        return [
          {
            'food': 'Apple',
            'measurement': '1 medium',
            'calories': 95.0,
            'protein': 0.5,
            'carbs': 25.0,
            'fat': 0.3,
            'sodium': 1.0,
            'fiber': 4.4,
            'servings': 1.0,
            'isRecipe': false,
          },
          {
            'food': 'Banana',
            'measurement': '1 medium',
            'calories': 90.0,
            'protein': 1.1,
            'carbs': 23.0,
            'fat': 0.3,
            'sodium': 1.0,
            'fiber': 2.6,
            'servings': 1.0,
            'isRecipe': false,
          },
        ];
      }
    }

    final url =
        'https://platform.fatsecret.com/rest/foods/search/v1?method=foods.search&search_expression=$query&format=json&max_results=10';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $_fatSecretAccessToken',
        },
      );
      print('FatSecret Response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['error'] != null) {
          print('FatSecret API Error: ${data['error']}');
          return [];
        }
        final foods = data['foods']?['food'] as List? ?? [];
        return foods.map((food) {
          final description = food['food_description']?.split(' - ')[0] ?? 'Per serving';
          return {
            'food': food['food_name'],
            'measurement': description,
            'calories': double.tryParse(food['food_description']
                ?.split(' - ')[1]
                ?.split(' | ')[0]
                ?.replaceAll('Calories: ', '')
                ?.replaceAll('kcal', '') ??
                '0') ??
                0.0,
            'protein': 0.0,
            'carbs': 0.0,
            'fat': 0.0,
            'sodium': 0.0,
            'fiber': 0.0,
            'servings': 1.0,
            'isRecipe': food['food_type'] == 'Recipe',
          };
        }).toList();
      } else {
        print('API Failed with status: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error fetching FatSecret foods: $e');
      return [];
    }
  }

  Future<void> _loadCustomFoods() async {
    _customFoods = await _customFoodRepository.getCustomFoods();
    print('Loaded custom foods: ${_customFoods.length}');
  }

  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _meals.dispose();
    _recipes.dispose();
    _shoppingList.dispose();
    _dietProfile.dispose();
    _mealNames.dispose();
  }

  void _onTabChanged() {}

  void _loadInitialData() {
    _meals.value = [];
    _recipes.value = [];
    _shoppingList.value = [];
  }

  void addMeal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _AddMealDialog(
        logic: this,
        onMealAdded: (meal) async {
          _meals.value = [..._meals.value, meal];
          await _mealRepository.insertMeal(meal);
        },
      ),
    );
  }

  void addCustomFood(BuildContext context) {
    final nameController = TextEditingController();
    final measurementController = TextEditingController();
    final caloriesController = TextEditingController();
    final proteinController = TextEditingController();
    final carbsController = TextEditingController();
    final fatController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Custom Food'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Food Name'),
              ),
              TextField(
                controller: measurementController,
                decoration: const InputDecoration(labelText: 'Measurement (e.g., 4oz, 1 cup)'),
              ),
              TextField(
                controller: caloriesController,
                decoration: const InputDecoration(labelText: 'Calories (kcal)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: proteinController,
                decoration: const InputDecoration(labelText: 'Protein (g)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: carbsController,
                decoration: const InputDecoration(labelText: 'Carbs (g)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: fatController,
                decoration: const InputDecoration(labelText: 'Fat (g)'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final name = nameController.text;
              final measurement = measurementController.text;
              final calories = double.tryParse(caloriesController.text) ?? 0.0;
              final protein = double.tryParse(proteinController.text) ?? 0.0;
              final carbs = double.tryParse(carbsController.text) ?? 0.0;
              final fat = double.tryParse(fatController.text) ?? 0.0;

              if (name.isNotEmpty) {
                final customFood = CustomFood(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: name,
                  calories: calories,
                  protein: protein,
                  carbs: carbs,
                  fat: fat,
                );
                _customFoods.add(customFood);
                await _customFoodRepository.addCustomFood(customFood);
                // Add to allFoods with measurement
                allFoods.add({
                  'food': customFood.name,
                  'measurement': measurement.isNotEmpty ? measurement : 'Per serving',
                  'calories': customFood.calories,
                  'protein': customFood.protein,
                  'carbs': customFood.carbs,
                  'fat': customFood.fat,
                  'sodium': 0.0,
                  'fiber': 0.0,
                  'servings': 1.0,
                  'isRecipe': false,
                });
                Navigator.pop(context);
                // Show confirmation
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Custom food "$name" added successfully!'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void addRecipe(BuildContext context) {
    _showAddRecipeDialog(context);
  }

  void editMeal(BuildContext context, Meal meal) {
    showDialog(
      context: context,
      builder: (context) => _AddMealDialog(
        logic: this,
        onMealAdded: (updatedMeal) async {
          _meals.value = _meals.value.map((m) {
            if (m.id == meal.id) {
              return updatedMeal.copyWith(id: meal.id, timestamp: meal.timestamp);
            }
            return m;
          }).toList();
          await _mealRepository.insertMeal(updatedMeal); // Use insertMeal for updates (it handles conflicts)
        },
        initialMeal: meal,
      ),
    );
  }

  void editRecipe(BuildContext context, Recipe recipe) {
    final nameController = TextEditingController(text: recipe.name);
    final List<Map<String, dynamic>> ingredients = List.from(recipe.ingredients);
    String searchQuery = '';
    List<Map<String, dynamic>> filteredFoods = [];
    filteredFoods = allFoods;

    double totalCalories = recipe.calories;
    double totalProtein = recipe.protein;
    double totalCarbs = recipe.carbs;
    double totalFat = recipe.fat;
    double totalSodium = recipe.sodium;
    double totalFiber = recipe.fiber;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Recipe'),
          content: SizedBox(
            height: 400, // Set a fixed height for the dialog content
            width: 300,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Recipe Name'),
                  ),
                  const SizedBox(height: 16),
                  const Text('Add Ingredient from Food Database'),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Search Food',
                      labelStyle: TextStyle(color: Color(0xFF1C2526)),
                    ),
                    style: const TextStyle(color: Color(0xFF1C2526)),
                    onChanged: (value) async {
                      searchQuery = value;
                      List<Map<String, dynamic>> apiFoods = [];
                      if (value.isNotEmpty) {
                        apiFoods = await _fetchFoods(value);
                      }
                      setState(() {
                        filteredFoods = allFoods
                            .where((food) => food['food']
                            .toString()
                            .toLowerCase()
                            .contains(searchQuery.toLowerCase()))
                            .toList();
                        filteredFoods.addAll(apiFoods);
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 150, // Ensure the ListView has a bounded height
                    child: ListView.builder(
                      itemCount: filteredFoods.length,
                      itemBuilder: (context, index) {
                        final food = filteredFoods[index];
                        return ListTile(
                          title: Text(
                            '${food['food']} ${food['measurement']}',
                            style: const TextStyle(color: Color(0xFF1C2526)),
                          ),
                          subtitle: Wrap(
                            spacing: 8.0,
                            children: [
                              Text(
                                '${food['calories'].toStringAsFixed(1)} kcal',
                                style: const TextStyle(color: Color(0xFF808080)),
                              ),
                              Text(
                                '${food['protein'].toStringAsFixed(1)}g protein',
                                style: const TextStyle(color: Color(0xFF808080)),
                              ),
                              Text(
                                '${food['carbs'].toStringAsFixed(1)}g carbs',
                                style: const TextStyle(color: Color(0xFF808080)),
                              ),
                              Text(
                                '${food['fat'].toStringAsFixed(1)}g fat',
                                style: const TextStyle(color: Color(0xFF808080)),
                              ),
                              Text(
                                '${food['sodium'].toStringAsFixed(1)}mg sodium',
                                style: const TextStyle(color: Color(0xFF808080)),
                              ),
                              Text(
                                '${food['fiber'].toStringAsFixed(1)}g fiber',
                                style: const TextStyle(color: Color(0xFF808080)),
                              ),
                            ],
                          ),
                          onTap: () async {
                            final servingsController = TextEditingController();
                            final result = await showDialog<Map<String, dynamic>>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Add ${food['food']}'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextField(
                                      controller: servingsController,
                                      decoration: const InputDecoration(labelText: 'Servings'),
                                      keyboardType: TextInputType.number,
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      final servings = double.tryParse(servingsController.text) ?? 1.0;
                                      Navigator.pop(context, {
                                        'food': food['food'],
                                        'measurement': food['measurement'],
                                        'calories': food['calories'],
                                        'protein': food['protein'],
                                        'carbs': food['carbs'],
                                        'fat': food['fat'],
                                        'sodium': food['sodium'],
                                        'fiber': food['fiber'],
                                        'servings': servings,
                                      });
                                    },
                                    child: const Text('Add'),
                                  ),
                                ],
                              ),
                            );
                            if (result != null) {
                              setState(() {
                                ingredients.add(result);
                                totalCalories += result['calories'] * result['servings'];
                                totalProtein += result['protein'] * result['servings'];
                                totalCarbs += result['carbs'] * result['servings'];
                                totalFat += result['fat'] * result['servings'];
                                totalSodium += result['sodium'] * result['servings'];
                                totalFiber += result['fiber'] * result['servings'];
                              });
                            }
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Ingredients Added:'),
                  ...ingredients.asMap().entries.map((entry) {
                    final index = entry.key;
                    final ingredient = entry.value;
                    return Row(
                      children: [
                        Expanded(
                          child: Text(
                            '- ${ingredient['food']} ${ingredient['measurement']}: ${ingredient['servings']} servings',
                            style: const TextStyle(color: Color(0xFF808080)),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Color(0xFF808080)),
                          onPressed: () {
                            setState(() {
                              final removedIngredient = ingredients.removeAt(index);
                              totalCalories -= removedIngredient['calories'] * removedIngredient['servings'];
                              totalProtein -= removedIngredient['protein'] * removedIngredient['servings'];
                              totalCarbs -= removedIngredient['carbs'] * removedIngredient['servings'];
                              totalFat -= removedIngredient['fat'] * removedIngredient['servings'];
                              totalSodium -= removedIngredient['sodium'] * removedIngredient['servings'];
                              totalFiber -= removedIngredient['fiber'] * removedIngredient['servings'];
                            });
                          },
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 16),
                  Text('Total Calories: ${totalCalories.toStringAsFixed(1)} kcal'),
                  Text('Total Protein: ${totalProtein.toStringAsFixed(1)} g'),
                  Text('Total Carbs: ${totalCarbs.toStringAsFixed(1)} g'),
                  Text('Total Fat: ${totalFat.toStringAsFixed(1)} g'),
                  Text('Total Sodium: ${totalSodium.toStringAsFixed(1)} mg'),
                  Text('Total Fiber: ${totalFiber.toStringAsFixed(1)} g'),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final name = nameController.text;
                if (name.isNotEmpty && ingredients.isNotEmpty) {
                  final updatedRecipe = Recipe(
                    id: recipe.id,
                    name: name,
                    calories: totalCalories,
                    protein: totalProtein,
                    carbs: totalCarbs,
                    fat: totalFat,
                    sodium: totalSodium,
                    fiber: totalFiber,
                    ingredients: ingredients,
                  );
                  _recipes.value = _recipes.value.map((r) {
                    if (r.id == recipe.id) {
                      return updatedRecipe;
                    }
                    return r;
                  }).toList();
                  await _saveRecipes();
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void deleteMeal(String mealId) async {
    _meals.value = _meals.value.where((meal) => meal.id != mealId).toList();
    await _mealRepository.deleteMeal(mealId);
  }

  void deleteRecipe(String recipeId) async {
    _recipes.value = _recipes.value.where((recipe) => recipe.id != recipeId).toList();
    await _saveRecipes();
  }

  void addShoppingItem(ShoppingListItem item) async {
    _shoppingList.value = [..._shoppingList.value, item];
    await _shoppingListRepository.saveShoppingList(_shoppingList.value);
  }

  void toggleShoppingItem(String itemId, bool value) async {
    _shoppingList.value = _shoppingList.value.map((item) {
      if (item.id == itemId) {
        return ShoppingListItem(
          id: item.id,
          name: item.name,
          quantity: item.quantity,
          checked: value,
        );
      }
      return item;
    }).toList();
    await _shoppingListRepository.saveShoppingList(_shoppingList.value);
  }

  void generateShoppingList() async {
    // Generate shopping list based on meals in the last 7 days
    final now = DateTime.now();
    final startOfPeriod = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 7)).millisecondsSinceEpoch;
    final endOfPeriod = DateTime(now.year, now.month, now.day, 23, 59, 59).millisecondsSinceEpoch;

    final mealsInPeriod = _meals.value.where((meal) {
      final timestamp = meal.timestamp;
      return timestamp >= startOfPeriod && timestamp <= endOfPeriod;
    }).toList();

    // Aggregate ingredients
    final Map<String, double> ingredientQuantities = {};
    for (var meal in mealsInPeriod) {
      final servings = meal.servings;
      if (meal.isRecipe) {
        // Find the recipe
        final recipe = _recipes.value.firstWhere(
              (r) => r.id == meal.food,
          orElse: () => Recipe(
            id: '',
            name: meal.food,
            calories: meal.calories,
            protein: meal.protein,
            carbs: meal.carbs,
            fat: meal.fat,
            sodium: meal.sodium,
            fiber: meal.fiber,
            ingredients: [],
          ),
        );
        for (var ingredient in recipe.ingredients) {
          final foodName = ingredient['food'] as String;
          final ingredientServings = (ingredient['servings'] as double) * servings;
          ingredientQuantities[foodName] = (ingredientQuantities[foodName] ?? 0.0) + ingredientServings;
        }
      } else {
        // For single foods
        final foodName = meal.food;
        ingredientQuantities[foodName] = (ingredientQuantities[foodName] ?? 0.0) + servings;
      }
    }

    // Convert to shopping list format
    _shoppingList.value = ingredientQuantities.entries.map((entry) {
      return ShoppingListItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: entry.key,
        quantity: entry.value,
        checked: false,
      );
    }).toList();
    await _shoppingListRepository.saveShoppingList(_shoppingList.value);
  }

  void clearShoppingList() async {
    _shoppingList.value = [];
    await _shoppingListRepository.clearShoppingList();
  }

  void setMealType(String? type) {
    if (type != null && _mealNames.value.contains(type)) {
      _selectedMealType = type;
    }
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
  }

  Future<void> setDietProfile(DietProfile profile, int customCalories) async {
    _dietProfile.value = profile;
    _customCalories = customCalories;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('customCalories', customCalories);
    await prefs.setString('profileName', profile.name);
    if (profile.name == 'Custom') {
      await prefs.setDouble('customProtein', profile.proteinPercentage);
      await prefs.setDouble('customCarbs', profile.carbsPercentage);
      await prefs.setDouble('customFat', profile.fatPercentage);
    } else {
      await prefs.remove('customProtein');
      await prefs.remove('customCarbs');
      await prefs.remove('customFat');
    }
    print('Saved: customCalories=$customCalories, profileName=${profile.name}');
  }

  Future<void> setMealNames(List<String> names) async {
    _mealNames.value = names.isNotEmpty ? names : ['Meal 1'];
    _selectedMealType = _mealNames.value[0];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('mealNames', _mealNames.value);
    print('Saved mealNames: ${_mealNames.value}');
  }

  Future<void> _saveRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final jsonList = _recipes.value.map((recipe) {
        try {
          final json = recipe.toJson();
          print('Serialized recipe to JSON: $json');
          return json;
        } catch (e) {
          print('Error serializing recipe to JSON: $recipe, error: $e');
          return null;
        }
      }).where((json) => json != null).toList();
      final jsonString = json.encode(jsonList);
      print('Saving recipes JSON string to SharedPreferences: $jsonString');
      await prefs.setString('recipes', jsonString);
      print('Saved recipes: ${_recipes.value.length}');
      for (var recipe in _recipes.value) {
        print('Saved recipe: ${recipe.toJson()}');
      }
    } catch (e) {
      print('Error saving recipes to SharedPreferences: $e');
    }
  }

  // Helper method to get meals for a specific date
  List<Meal> getMealsForDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day).millisecondsSinceEpoch;
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59).millisecondsSinceEpoch;
    return _meals.value.where((meal) {
      return meal.timestamp >= startOfDay && meal.timestamp <= endOfDay;
    }).toList();
  }

  double get loggedProtein => getMealsForDate(_selectedDate)
      .fold(0.0, (sum, meal) => sum + (meal.protein * meal.servings));
  double get loggedCarbs => getMealsForDate(_selectedDate)
      .fold(0.0, (sum, meal) => sum + (meal.carbs * meal.servings));
  double get loggedFat => getMealsForDate(_selectedDate)
      .fold(0.0, (sum, meal) => sum + (meal.fat * meal.servings));

  int get effectiveCalories => _customCalories ?? _dietProfile.value.defaultCalories;

  FloatingActionButton buildFAB(BuildContext context) {
    switch (_tabController.index) {
      case 0:
        return FloatingActionButton(
          onPressed: () => addMeal(context),
          child: const Icon(Icons.add),
        );
      case 1:
        return FloatingActionButton(
          onPressed: () => _showAddRecipeDialog(context),
          child: const Icon(Icons.add),
        );
      case 2:
        return FloatingActionButton(
          onPressed: () => _showAddShoppingItemDialog(context),
          child: const Icon(Icons.add),
        );
      default:
        return FloatingActionButton(
          onPressed: () {},
          child: const Icon(Icons.error),
        );
    }
  }

  void _showAddMealDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _AddMealDialog(
        logic: this,
        onMealAdded: (meal) async {
          _meals.value = [..._meals.value, meal];
          await _mealRepository.insertMeal(meal);
        },
      ),
    );
  }

  void _showAddRecipeDialog(BuildContext context) {
    final nameController = TextEditingController();
    final List<Map<String, dynamic>> ingredients = [];
    String searchQuery = '';
    List<Map<String, dynamic>> filteredFoods = [];
    filteredFoods = allFoods;

    double totalCalories = 0.0;
    double totalProtein = 0.0;
    double totalCarbs = 0.0;
    double totalFat = 0.0;
    double totalSodium = 0.0;
    double totalFiber = 0.0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Recipe'),
          content: SizedBox(
            height: 400, // Set a fixed height for the dialog content
            width: 300,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Recipe Name'),
                  ),
                  const SizedBox(height: 16),
                  const Text('Add Ingredient from Food Database'),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Search Food',
                      labelStyle: TextStyle(color: Color(0xFF1C2526)),
                    ),
                    style: const TextStyle(color: Color(0xFF1C2526)),
                    onChanged: (value) async {
                      searchQuery = value;
                      List<Map<String, dynamic>> apiFoods = [];
                      if (value.isNotEmpty) {
                        apiFoods = await _fetchFoods(value);
                      }
                      setState(() {
                        filteredFoods = allFoods
                            .where((food) => food['food']
                            .toString()
                            .toLowerCase()
                            .contains(searchQuery.toLowerCase()))
                            .toList();
                        filteredFoods.addAll(apiFoods);
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 150, // Ensure the ListView has a bounded height
                    child: ListView.builder(
                      itemCount: filteredFoods.length,
                      itemBuilder: (context, index) {
                        final food = filteredFoods[index];
                        return ListTile(
                          title: Text(
                            '${food['food']} ${food['measurement']}',
                            style: const TextStyle(color: Color(0xFF1C2526)),
                          ),
                          subtitle: Wrap(
                            spacing: 8.0,
                            children: [
                              Text(
                                '${food['calories'].toStringAsFixed(1)} kcal',
                                style: const TextStyle(color: Color(0xFF808080)),
                              ),
                              Text(
                                '${food['protein'].toStringAsFixed(1)}g protein',
                                style: const TextStyle(color: Color(0xFF808080)),
                              ),
                              Text(
                                '${food['carbs'].toStringAsFixed(1)}g carbs',
                                style: const TextStyle(color: Color(0xFF808080)),
                              ),
                              Text(
                                '${food['fat'].toStringAsFixed(1)}g fat',
                                style: const TextStyle(color: Color(0xFF808080)),
                              ),
                              Text(
                                '${food['sodium'].toStringAsFixed(1)}mg sodium',
                                style: const TextStyle(color: Color(0xFF808080)),
                              ),
                              Text(
                                '${food['fiber'].toStringAsFixed(1)}g fiber',
                                style: const TextStyle(color: Color(0xFF808080)),
                              ),
                            ],
                          ),
                          onTap: () async {
                            final servingsController = TextEditingController();
                            final result = await showDialog<Map<String, dynamic>>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Add ${food['food']}'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextField(
                                      controller: servingsController,
                                      decoration: const InputDecoration(labelText: 'Servings'),
                                      keyboardType: TextInputType.number,
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      final servings = double.tryParse(servingsController.text) ?? 1.0;
                                      Navigator.pop(context, {
                                        'food': food['food'],
                                        'measurement': food['measurement'],
                                        'calories': food['calories'],
                                        'protein': food['protein'],
                                        'carbs': food['carbs'],
                                        'fat': food['fat'],
                                        'sodium': food['sodium'],
                                        'fiber': food['fiber'],
                                        'servings': servings,
                                      });
                                    },
                                    child: const Text('Add'),
                                  ),
                                ],
                              ),
                            );
                            if (result != null) {
                              setState(() {
                                ingredients.add(result);
                                totalCalories += result['calories'] * result['servings'];
                                totalProtein += result['protein'] * result['servings'];
                                totalCarbs += result['carbs'] * result['servings'];
                                totalFat += result['fat'] * result['servings'];
                                totalSodium += result['sodium'] * result['servings'];
                                totalFiber += result['fiber'] * result['servings'];
                              });
                            }
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Ingredients Added:'),
                  ...ingredients.map((ingredient) => Text(
                    '- ${ingredient['food']} ${ingredient['measurement']}: ${ingredient['servings']} servings',
                    style: const TextStyle(color: Color(0xFF808080)),
                  )),
                  const SizedBox(height: 16),
                  Text('Total Calories: ${totalCalories.toStringAsFixed(1)} kcal'),
                  Text('Total Protein: ${totalProtein.toStringAsFixed(1)} g'),
                  Text('Total Carbs: ${totalCarbs.toStringAsFixed(1)} g'),
                  Text('Total Fat: ${totalFat.toStringAsFixed(1)} g'),
                  Text('Total Sodium: ${totalSodium.toStringAsFixed(1)} mg'),
                  Text('Total Fiber: ${totalFiber.toStringAsFixed(1)} g'),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final name = nameController.text;
                if (name.isNotEmpty && ingredients.isNotEmpty) {
                  final recipe = Recipe(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: name,
                    calories: totalCalories,
                    protein: totalProtein,
                    carbs: totalCarbs,
                    fat: totalFat,
                    sodium: totalSodium,
                    fiber: totalFiber,
                    ingredients: ingredients,
                  );
                  _recipes.value = [..._recipes.value, recipe];
                  await _saveRecipes();
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddShoppingItemDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AlertDialog(
        title: Text('Add Shopping Item'),
        content: Text('Placeholder for shopping item input form'),
        actions: [],
      ),
    );
  }

  Future<List<FoodItem>> getFoodMacros(String query) async {
    return [];
  }

  void addFoodToMeal(String foodId, Meal meal) {}
}

class _AddMealDialog extends StatefulWidget {
  final DietScreenLogic logic;
  final Function(Meal) onMealAdded;
  final Meal? initialMeal;

  const _AddMealDialog({
    required this.logic,
    required this.onMealAdded,
    this.initialMeal,
  });

  @override
  _AddMealDialogState createState() => _AddMealDialogState();
}

class _AddMealDialogState extends State<_AddMealDialog> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String searchQuery = '';
  List<Map<String, dynamic>> filteredFoods = [];
  List<Map<String, dynamic>> allFoods = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Initialize allFoods with _foodDatabase and _customFoods
    allFoods = List.from(widget.logic.foodDatabase);
    for (var customFood in widget.logic._customFoods) {
      allFoods.add({
        'food': customFood.name,
        'measurement': 'Per serving', // Default measurement for custom foods
        'calories': customFood.calories,
        'protein': customFood.protein,
        'carbs': customFood.carbs,
        'fat': customFood.fat,
        'sodium': 0.0,
        'fiber': 0.0,
        'servings': 1.0,
        'isRecipe': false,
      });
    }
    filteredFoods = allFoods;

    // If editing a meal, set the initial meal type
    if (widget.initialMeal != null) {
      widget.logic.setMealType(widget.initialMeal!.mealType);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _updateFilteredFoods(String query) async {
    setState(() {
      searchQuery = query;
    });

    // Fetch foods from FatSecret API if query is not empty
    List<Map<String, dynamic>> apiFoods = [];
    if (query.isNotEmpty) {
      apiFoods = await widget.logic._fetchFoods(query);
    }

    // Combine _foodDatabase, _customFoods, and API results
    List<Map<String, dynamic>> combinedFoods = List.from(widget.logic.foodDatabase);
    for (var customFood in widget.logic._customFoods) {
      combinedFoods.add({
        'food': customFood.name,
        'measurement': 'Per serving', // Default measurement for custom foods
        'calories': customFood.calories,
        'protein': customFood.protein,
        'carbs': customFood.carbs,
        'fat': customFood.fat,
        'sodium': 0.0,
        'fiber': 0.0,
        'servings': 1.0,
        'isRecipe': false,
      });
    }
    combinedFoods.addAll(apiFoods);

    setState(() {
      allFoods = combinedFoods;
      filteredFoods = allFoods
          .where((food) => food['food']
          .toString()
          .toLowerCase()
          .contains(searchQuery.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.initialMeal != null ? 'Edit Meal' : 'Add Meal',
        style: const TextStyle(color: Color(0xFF1C2526)), // Dark gray
      ),
      content: SizedBox(
        height: 300,
        width: 280,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ValueListenableBuilder<List<String>>(
              valueListenable: widget.logic.mealNames,
              builder: (context, mealNames, _) {
                return DropdownButton<String>(
                  value: mealNames.contains(widget.logic.selectedMealType)
                      ? widget.logic.selectedMealType
                      : mealNames[0],
                  items: mealNames.map((name) => DropdownMenuItem(
                    value: name,
                    child: Text(
                      name,
                      style: const TextStyle(
                        color: Color(0xFF1C2526), // Dark gray
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      widget.logic.setMealType(value);
                      setState(() {});
                    }
                  },
                );
              },
            ),
            const SizedBox(height: 8),
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Foods'),
                Tab(text: 'Recipes'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Foods Tab
                  Column(
                    children: [
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Search Food',
                          labelStyle: TextStyle(color: Color(0xFF1C2526)),
                        ),
                        style: const TextStyle(color: Color(0xFF1C2526)),
                        onChanged: (value) {
                          _updateFilteredFoods(value);
                        },
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: filteredFoods.length,
                          itemBuilder: (context, index) {
                            final food = filteredFoods[index];
                            return ListTile(
                              title: Text(
                                '${food['food']} ${food['measurement']}',
                                style: const TextStyle(color: Color(0xFF1C2526)),
                              ),
                              subtitle: Wrap(
                                spacing: 8.0,
                                children: [
                                  Text(
                                    '${food['calories'].toStringAsFixed(1)} kcal',
                                    style: const TextStyle(color: Color(0xFF808080)),
                                  ),
                                  Text(
                                    '${food['protein'].toStringAsFixed(1)}g protein',
                                    style: const TextStyle(color: Color(0xFF808080)),
                                  ),
                                  Text(
                                    '${food['carbs'].toStringAsFixed(1)}g carbs',
                                    style: const TextStyle(color: Color(0xFF808080)),
                                  ),
                                  Text(
                                    '${food['fat'].toStringAsFixed(1)}g fat',
                                    style: const TextStyle(color: Color(0xFF808080)),
                                  ),
                                  Text(
                                    '${food['sodium'].toStringAsFixed(1)}mg sodium',
                                    style: const TextStyle(color: Color(0xFF808080)),
                                  ),
                                  Text(
                                    '${food['fiber'].toStringAsFixed(1)}g fiber',
                                    style: const TextStyle(color: Color(0xFF808080)),
                                  ),
                                ],
                              ),
                              onTap: () {
                                final meal = Meal(
                                  id: DateTime.now().toString(),
                                  food: food['food'],
                                  mealType: widget.logic.selectedMealType,
                                  calories: food['calories'],
                                  protein: food['protein'],
                                  carbs: food['carbs'],
                                  fat: food['fat'],
                                  sodium: food['sodium'],
                                  fiber: food['fiber'],
                                  timestamp: widget.logic.selectedDate.millisecondsSinceEpoch,
                                  servings: food['servings'],
                                  isRecipe: food['isRecipe'],
                                  ingredients: null,
                                );
                                widget.onMealAdded(meal);
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  // Recipes Tab
                  ValueListenableBuilder<List<Recipe>>(
                    valueListenable: widget.logic.recipes,
                    builder: (context, recipes, _) {
                      return ListView.builder(
                        itemCount: recipes.length,
                        itemBuilder: (context, index) {
                          final recipe = recipes[index];
                          return ListTile(
                            title: Text(
                              recipe.name,
                              style: const TextStyle(color: Color(0xFF1C2526)),
                            ),
                            subtitle: Wrap(
                              spacing: 8.0,
                              children: [
                                Text(
                                  '${recipe.calories.toStringAsFixed(1)} kcal',
                                  style: const TextStyle(color: Color(0xFF808080)),
                                ),
                                Text(
                                  '${recipe.protein.toStringAsFixed(1)}g protein',
                                  style: const TextStyle(color: Color(0xFF808080)),
                                ),
                                Text(
                                  '${recipe.carbs.toStringAsFixed(1)}g carbs',
                                  style: const TextStyle(color: Color(0xFF808080)),
                                ),
                                Text(
                                  '${recipe.fat.toStringAsFixed(1)}g fat',
                                  style: const TextStyle(color: Color(0xFF808080)),
                                ),
                                Text(
                                  '${recipe.sodium.toStringAsFixed(1)}mg sodium',
                                  style: const TextStyle(color: Color(0xFF808080)),
                                ),
                                Text(
                                  '${recipe.fiber.toStringAsFixed(1)}g fiber',
                                  style: const TextStyle(color: Color(0xFF808080)),
                                ),
                              ],
                            ),
                            onTap: () {
                              final meal = Meal(
                                id: DateTime.now().toString(),
                                food: recipe.id, // Store recipe ID as the "food"
                                mealType: widget.logic.selectedMealType,
                                calories: recipe.calories,
                                protein: recipe.protein,
                                carbs: recipe.carbs,
                                fat: recipe.fat,
                                sodium: recipe.sodium,
                                fiber: recipe.fiber,
                                timestamp: widget.logic.selectedDate.millisecondsSinceEpoch,
                                servings: 1.0,
                                isRecipe: true,
                                ingredients: recipe.ingredients,
                              );
                              widget.onMealAdded(meal);
                              Navigator.pop(context);
                            },
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancel',
            style: TextStyle(color: Color(0xFF1C2526)),
          ),
        ),
      ],
    );
  }
}

class FoodItem {
  final String id;
  final String name;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  FoodItem({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });
}