import 'package:flutter/material.dart';
import '../../core/data/models/meal.dart';
import '../../core/data/models/recipe.dart';
import '../../core/data/models/shopping_list_item.dart';

class DietScreenLogic {
  late TabController _tabController;
  List<Meal> _meals = [];
  List<Recipe> _recipes = [];
  List<ShoppingListItem> _shoppingList = [];
  DateTime _selectedDate = DateTime.now();
  String _selectedMealType = 'Breakfast';

  DietScreenLogic(TickerProvider vsync) {
    _tabController = TabController(length: 3, vsync: vsync);
  }

  TabController get tabController => _tabController;
  List<Meal> get meals => _meals;
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
  }

  void _onTabChanged() {}

  void _loadInitialData() {
    _meals = [];
    _recipes = [];
    _shoppingList = [];
  }

  void addMeal(BuildContext context) {
    _showAddMealDialog(context);
  }

  void addCustomFood() {
    // Placeholder for custom food logic
  }

  void addRecipe() {
    // Placeholder for recipe logic
  }

  void deleteMeal(String mealId) {
    _meals.removeWhere((meal) => meal.id == mealId);
  }

  void editMeal(Meal meal) {
    // Placeholder for edit logic
  }

  void deleteRecipe(String recipeId) {
    _recipes.removeWhere((recipe) => recipe.id == recipeId);
  }

  void addShoppingItem(ShoppingListItem item) {
    _shoppingList.add(item);
  }

  void toggleShoppingItem(String itemId, bool value) {
    // Placeholder for toggle logic
  }

  void generateShoppingList() {
    // Placeholder for generate logic
  }

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
    String food = '';
    String mealType = _selectedMealType;
    double calories = 0.0;
    double protein = 0.0;
    double carbs = 0.0;
    double fat = 0.0;
    double sodium = 0.0;
    double fiber = 0.0;
    double servings = 1.0;
    bool isRecipe = false;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Meal'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Food Name'),
                onChanged: (value) => food = value,
              ),
              DropdownButton<String>(
                value: mealType,
                items: ['Breakfast', 'Lunch', 'Dinner', 'Snack']
                    .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (value) => mealType = value ?? 'Breakfast',
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Calories'),
                keyboardType: TextInputType.number,
                onChanged: (value) => calories = double.tryParse(value) ?? 0.0,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Protein (g)'),
                keyboardType: TextInputType.number,
                onChanged: (value) => protein = double.tryParse(value) ?? 0.0,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Carbs (g)'),
                keyboardType: TextInputType.number,
                onChanged: (value) => carbs = double.tryParse(value) ?? 0.0,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Fat (g)'),
                keyboardType: TextInputType.number,
                onChanged: (value) => fat = double.tryParse(value) ?? 0.0,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Sodium (mg)'),
                keyboardType: TextInputType.number,
                onChanged: (value) => sodium = double.tryParse(value) ?? 0.0,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Fiber (g)'),
                keyboardType: TextInputType.number,
                onChanged: (value) => fiber = double.tryParse(value) ?? 0.0,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Servings'),
                keyboardType: TextInputType.number,
                onChanged: (value) => servings = double.tryParse(value) ?? 1.0,
              ),
              CheckboxListTile(
                title: const Text('Is Recipe?'),
                value: isRecipe,
                onChanged: (value) => isRecipe = value ?? false,
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
            onPressed: () {
              if (food.isNotEmpty) {
                final meal = Meal(
                  id: DateTime.now().toString(),
                  food: food,
                  mealType: mealType,
                  calories: calories,
                  protein: protein,
                  carbs: carbs,
                  fat: fat,
                  sodium: sodium,
                  fiber: fiber,
                  timestamp: _selectedDate.millisecondsSinceEpoch,
                  servings: servings,
                  isRecipe: isRecipe,
                );
                _meals.add(meal);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
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