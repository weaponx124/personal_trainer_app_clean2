import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/data/models/meal.dart';
import '../../core/data/models/recipe.dart';
import '../../core/data/models/shopping_list_item.dart';
import './diet_profile.dart';

class DietScreenLogic {
  late TabController _tabController;
  final ValueNotifier<List<Meal>> _meals = ValueNotifier([]);
  List<Recipe> _recipes = [];
  List<ShoppingListItem> _shoppingList = [];
  DateTime _selectedDate = DateTime.now();
  String _selectedMealType = 'Breakfast';
  final ValueNotifier<DietProfile> _dietProfile = ValueNotifier(DietProfile.profiles[0]);

  // Mock fallback database
  final List<Map<String, dynamic>> _foodDatabase = [
    {'food': 'Chicken Breast', 'calories': 165.0, 'protein': 31.0, 'carbs': 0.0, 'fat': 3.6, 'sodium': 74.0, 'fiber': 0.0, 'servings': 1.0, 'isRecipe': false},
    {'food': 'Broccoli', 'calories': 35.0, 'protein': 3.0, 'carbs': 7.0, 'fat': 0.4, 'sodium': 33.0, 'fiber': 3.0, 'servings': 1.0, 'isRecipe': false},
    {'food': 'Avocado', 'calories': 160.0, 'protein': 2.0, 'carbs': 9.0, 'fat': 15.0, 'sodium': 7.0, 'fiber': 7.0, 'servings': 1.0, 'isRecipe': false},
  ];

  DietScreenLogic(TickerProvider vsync) {
    _tabController = TabController(length: 3, vsync: vsync);
  }

  TabController get tabController => _tabController;
  ValueNotifier<List<Meal>> get meals => _meals;
  List<Recipe> get recipes => _recipes;
  List<ShoppingListItem> get shoppingList => _shoppingList;
  DateTime get selectedDate => _selectedDate;
  String get selectedMealType => _selectedMealType;
  ValueNotifier<DietProfile> get dietProfile => _dietProfile;

  void init() {
    _tabController.addListener(_onTabChanged);
    _loadInitialData();
  }

  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _meals.dispose();
    _dietProfile.dispose();
  }

  void _onTabChanged() {}

  void _loadInitialData() {
    _meals.value = [];
    _recipes = [];
    _shoppingList = [];
  }

  void addMeal(BuildContext context) {
    _showAddMealDialog(context);
  }

  void addCustomFood() {}

  void addRecipe() {}

  void deleteMeal(String mealId) {
    _meals.value = _meals.value.where((meal) => meal.id != mealId).toList();
  }

  void editMeal(Meal meal) {}

  void deleteRecipe(String recipeId) {
    _recipes.removeWhere((recipe) => recipe.id == recipeId);
  }

  void addShoppingItem(ShoppingListItem item) {
    _shoppingList.add(item);
  }

  void toggleShoppingItem(String itemId, bool value) {}

  void generateShoppingList() {}

  void clearShoppingList() {
    _shoppingList.clear();
  }

  void setMealType(String? type) {
    if (type != null) _selectedMealType = type;
  }

  void setDietProfile(DietProfile profile) {
    _dietProfile.value = profile;
  }

  // Calculate logged macro totals for the selected date
  double get loggedProtein => _meals.value
      .where((meal) => meal.timestamp >= _selectedDate.millisecondsSinceEpoch && meal.timestamp < _selectedDate.add(const Duration(days: 1)).millisecondsSinceEpoch)
      .fold(0.0, (sum, meal) => sum + (meal.protein * meal.servings));
  double get loggedCarbs => _meals.value
      .where((meal) => meal.timestamp >= _selectedDate.millisecondsSinceEpoch && meal.timestamp < _selectedDate.add(const Duration(days: 1)).millisecondsSinceEpoch)
      .fold(0.0, (sum, meal) => sum + (meal.carbs * meal.servings));
  double get loggedFat => _meals.value
      .where((meal) => meal.timestamp >= _selectedDate.millisecondsSinceEpoch && meal.timestamp < _selectedDate.add(const Duration(days: 1)).millisecondsSinceEpoch)
      .fold(0.0, (sum, meal) => sum + (meal.fat * meal.servings));

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

  Future<List<Map<String, dynamic>>> _fetchFoods(String query) async {
    const apiKey = '4a4f7fd3016e4cedba709f38af5e7b7d';
    final url = 'https://platform.fatsecret.com/rest/foods/search/v1?method=foods.search&search_expression=$query&format=json&max_results=10';
    try {
      final response = await http.get(Uri.parse(url), headers: {
        'Authorization': 'Bearer $apiKey',
      });
      print('FatSecret Response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final foods = data['foods']?['food'] as List? ?? [];
        return foods.map((food) {
          return {
            'food': food['food_name'],
            'calories': double.tryParse(food['food_description']?.split(' - ')[1]?.split(' | ')[0]?.replaceAll('Calories: ', '')?.replaceAll('kcal', '') ?? '0') ?? 0.0,
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
        print('API Failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching FatSecret foods: $e');
    }
    return _foodDatabase;
  }

  void _showAddMealDialog(BuildContext context) {
    String searchQuery = '';
    List<Map<String, dynamic>> filteredFoods = _foodDatabase;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Meal'),
          content: SizedBox(
            height: 300,
            width: 280,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'Search Food'),
                  onChanged: (value) {
                    searchQuery = value;
                    filteredFoods = _foodDatabase
                        .where((food) => food['food'].toString().toLowerCase().contains(searchQuery.toLowerCase()))
                        .toList();
                    print('Search: "$searchQuery", Filtered: ${filteredFoods.map((f) => f['food']).toList()}');
                    setState(() {});
                  },
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredFoods.length,
                    itemBuilder: (context, index) {
                      final food = filteredFoods[index];
                      return ListTile(
                        title: Text(food['food']),
                        subtitle: Text('Calories: ${food['calories']}'),
                        onTap: () {
                          final meal = Meal(
                            id: DateTime.now().toString(),
                            food: food['food'],
                            mealType: _selectedMealType,
                            calories: food['calories'],
                            protein: food['protein'],
                            carbs: food['carbs'],
                            fat: food['fat'],
                            sodium: food['sodium'],
                            fiber: food['fiber'],
                            timestamp: _selectedDate.millisecondsSinceEpoch,
                            servings: food['servings'],
                            isRecipe: food['isRecipe'],
                          );
                          _meals.value = [..._meals.value, meal];
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddRecipeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AlertDialog(
        title: Text('Add Recipe'),
        content: Text('Placeholder for recipe input form'),
        actions: [],
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