import 'package:flutter/material.dart';
import '../../core/data/models/meal.dart';
import '../../core/data/models/recipe.dart';
import '../../core/data/models/shopping_list_item.dart';

class DietScreenLogic {
  late TabController _tabController;
  final ValueNotifier<List<Meal>> _meals = ValueNotifier([]);
  List<Recipe> _recipes = [];
  List<ShoppingListItem> _shoppingList = [];
  DateTime _selectedDate = DateTime.now();
  String _selectedMealType = 'Breakfast';

  final List<Map<String, dynamic>> _foodDatabase = [
    {'food': 'Chicken Breast', 'calories': 165.0, 'protein': 31.0, 'carbs': 0.0, 'fat': 3.6, 'sodium': 74.0, 'fiber': 0.0, 'servings': 1.0, 'isRecipe': false},
    {'food': 'Broccoli', 'calories': 35.0, 'protein': 3.0, 'carbs': 7.0, 'fat': 0.4, 'sodium': 33.0, 'fiber': 3.0, 'servings': 1.0, 'isRecipe': false},
    {'food': 'Avocado', 'calories': 160.0, 'protein': 2.0, 'carbs': 9.0, 'fat': 15.0, 'sodium': 7.0, 'fiber': 7.0, 'servings': 1.0, 'isRecipe': false},
  ];

  DietScreenLogic(TickerProvider vsync) {
    _tabController = TabController(length: 3, vsync: vsync);
  }

  TabController get tabController => _tabController;
  ValueNotifier<List<Meal>> get meals => _meals; // Now a ValueNotifier
  List<Recipe> get recipes => _recipes;
  List<ShoppingListItem> get shoppingList => _shoppingList;
  DateTime get selectedDate => _selectedDate;
  String get selectedMealType => _selectedMealType;

  void init() {
    _tabController.addListener(_onTabChanged);
    _loadInitialData();
  }

  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _meals.dispose();
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
                    setState(() {
                      searchQuery = value;
                      filteredFoods = _foodDatabase
                          .where((food) => food['food'].toString().toLowerCase().contains(value.toLowerCase()))
                          .toList();
                    });
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
                          _meals.value = [..._meals.value, meal]; // Update notifier
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